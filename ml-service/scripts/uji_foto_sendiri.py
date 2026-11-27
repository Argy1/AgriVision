"""Uji model (penyaring v9.1 + diagnosis v8) pada foto SENDIRI yang sudah diberi label lewat nama folder.

Tidak butuh Supabase/jaringan; tidak menyimpan apa pun. Dipakai untuk mendapat angka akurasi di
kebun sendiri (sumber yang tidak pernah dipakai melatih model).

Susun foto per folder (nama folder = label; huruf besar/kecil bebas):
    foto_uji/
      sehat/               daun tomat sehat
      early_blight/        bercak kering          late_blight/   busuk daun
      bacterial_spot/      bercak bakteri         leaf_mold/     jamur daun
      septoria/            bercak septoria        spider_mites/  tungau
      target_spot/         bercak target          tylcv/         virus keriting kuning
      tomv/                virus mosaik
      tomat_lain/          daun tomat, penyakit tidak diketahui / di luar 10 kelas (hanya cek penyaring)
      bukan_cabai/ bukan_terong/ bukan_.../       daun BUKAN tomat (cek penolakan penyaring)

Jalankan dari folder ml-service:
    python scripts/uji_foto_sendiri.py foto_uji/
    python scripts/uji_foto_sendiri.py foto_uji/ --csv hasil_uji_sendiri.csv
"""

import argparse
import csv
import os
import sys
from collections import Counter, defaultdict
from pathlib import Path

os.environ.setdefault("SUPABASE_URL", "http://localhost")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "tidak-dipakai")
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.cv.analyzer import analyze_image  # noqa: E402
from app.cv.photo_quality import assess_photo  # noqa: E402
from app.imaging import decode_image  # noqa: E402
from app.ml.gate import check_tomato  # noqa: E402
from app.ml.inference import classify  # noqa: E402
from app.ml.model_loader import model_registry  # noqa: E402

LABEL = {
    "sehat": "tomato_healthy", "healthy": "tomato_healthy",
    "early_blight": "tomato_early_blight", "late_blight": "tomato_late_blight",
    "bacterial_spot": "tomato_bacterial_spot", "leaf_mold": "tomato_leaf_mold",
    "septoria": "tomato_septoria_leaf_spot", "spider_mites": "tomato_spider_mites_two_spotted_spider_mite",
    "target_spot": "tomato_target_spot", "tylcv": "tomato_tomato_yellow_leaf_curl_virus",
    "tomv": "tomato_tomato_mosaic_virus",
}
EXT = {".jpg", ".jpeg", ".png", ".webp"}


def wilson(k, n, z=1.96):
    if n == 0:
        return 0.0, 0.0
    p = k / n
    d = 1 + z * z / n
    c = (p + z * z / (2 * n)) / d
    h = z * ((p * (1 - p) / n + z * z / (4 * n * n)) ** 0.5) / d
    return max(0.0, c - h), min(1.0, c + h)


def fmt(k, n):
    if n == 0:
        return "-"
    lo, hi = wilson(k, n)
    return f"{k}/{n} = {k / n * 100:.0f}% (CI95 {lo * 100:.0f}-{hi * 100:.0f}%)"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("root")
    ap.add_argument("--csv", help="simpan hasil per foto ke CSV")
    a = ap.parse_args()
    model_registry.load_all()

    rows = []
    for folder in sorted(p for p in Path(a.root).iterdir() if p.is_dir()):
        name = folder.name.lower()
        kind = "bukan" if name.startswith("bukan") else "tomat"
        truth = LABEL.get(name)
        if kind == "tomat" and truth is None and name != "tomat_lain":
            print(f"Lewati folder tak dikenal: {folder.name} (lihat daftar nama folder di atas)")
            continue
        for f in sorted(p for p in folder.rglob("*") if p.suffix.lower() in EXT):
            image = decode_image(f.read_bytes())
            gate = check_tomato(image)
            cls = classify("tomat", image, crops=gate.accepted_crops)
            cv = analyze_image(image)
            m = cv["masks"]
            q = assess_photo(m["green"], m["lesion"], m["nonleaf"], cv["scene_fraction"], cls["confidence"])
            status = "ditolak_penyaring" if not gate.is_tomato else ("ditolak_keyakinan" if q.rejected else "didiagnosis")
            rows.append({"folder": folder.name, "file": f.name, "kelompok": kind, "label_benar": truth or "",
                         "p_tomat": round(gate.p_tomat, 3), "status": status, "prediksi": cls["disease_label"],
                         "keyakinan": cls["confidence"], "benar": (truth == cls["disease_label"]) if truth else "",
                         "health_score": cv["vegetation_index"]["health_score"], "severity": cv["severity"]})
    if not rows:
        print("Tidak ada foto ditemukan."); return 1

    tom = [r for r in rows if r["kelompok"] == "tomat"]; buk = [r for r in rows if r["kelompok"] == "bukan"]
    print(f"\n{len(rows)} foto ({len(tom)} tomat, {len(buk)} bukan tomat)\n")
    print("PENYARING")
    print("  Daun tomat diterima        :", fmt(sum(r["status"] != "ditolak_penyaring" for r in tom), len(tom)))
    print("  Bukan tomat ditolak        :", fmt(sum(r["status"] == "ditolak_penyaring" for r in buk), len(buk)))
    for fld in sorted({r["folder"] for r in buk}):
        rs = [r for r in buk if r["folder"] == fld]
        print(f"     {fld:22s}:", fmt(sum(r["status"] == "ditolak_penyaring" for r in rs), len(rs)))
    lab = [r for r in tom if r["label_benar"]]
    if lab:
        print("\nDIAGNOSIS (foto tomat berlabel, semua yang lolos penyaring)")
        lolos = [r for r in lab if r["status"] != "ditolak_penyaring"]
        print("  Akurasi                    :", fmt(sum(bool(r["benar"]) for r in lolos), len(lolos)))
        tampil = [r for r in lab if r["status"] == "didiagnosis"]
        print("  Akurasi (yang ditampilkan) :", fmt(sum(bool(r["benar"]) for r in tampil), len(tampil)))
        per = defaultdict(list)
        for r in lolos:
            per[r["folder"]].append(r)
        for fld, rs in sorted(per.items()):
            salah = Counter(r["prediksi"].replace("tomato_", "") for r in rs if not r["benar"]).most_common(2)
            print(f"     {fld:22s}: {fmt(sum(bool(r['benar']) for r in rs), len(rs))}"
                  + (f"  | salah paling sering: {salah}" if salah else ""))
    print("\nSKOR KESEHATAN (median) per folder tomat:")
    for fld in sorted({r["folder"] for r in tom}):
        hs = sorted(r["health_score"] for r in tom if r["folder"] == fld)
        print(f"     {fld:22s}: {hs[len(hs) // 2]:.0f}/100  (n={len(hs)})")
    if a.csv:
        with open(a.csv, "w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
        print(f"\nHasil per foto disimpan ke {a.csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
