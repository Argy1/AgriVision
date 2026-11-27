"""Rentang kepercayaan 95% (CI) untuk hasil notebook v8 (diagnosis) dan v9.1 (penyaring daun tomat).

Kenapa: data uji lapangan kecil (PlantDoc 142 foto, beberapa kelas hanya 11-21 foto), jadi akurasi
satu angka bisa menyesatkan. CI menunjukkan seberapa besar angka itu bisa bergeser bila foto ujinya
lain.

Metode
- v8: bootstrap persentil, 10.000 kali. Setiap ulangan mengambil ulang foto uji secara acak
  (dengan pengembalian), menghitung akurasi tiap seed pada foto yang sama, lalu dirata-rata 3 seed
  -> CI mencerminkan ketidakpastian karena SAMPEL FOTO UJI (bukan variasi antar-seed; itu sudah
  dilaporkan sebagai ± SD). Juga CI selisih gabungan - lab saja (berpasangan, foto yang sama).
- v9.1: interval Wilson untuk proporsi (tomat diterima / bukan-tomat ditolak) pada ambang terpasang.

Jalankan dari folder ml-service:
    python scripts/ci_hasil.py results/v8/hasil_mentah_v8.json results/v9_1/skor_potongan_uji.csv results
"""

import csv
import json
import math
import sys
from pathlib import Path

import numpy as np

N_BOOT = 10_000
RNG = np.random.default_rng(42)
TEST_NAME = {"uji_lab": "Uji lab (PlantVillage)", "uji_plantdoc": "Uji PlantDoc",
             "uji_tomato_village": "Uji Tomato-Village", "uji_gabungan": "Uji gabungan (semua)"}
SCEN_NAME = {"lab_saja": "Skenario 1: lab saja", "gabungan": "Skenario 2: gabungan"}


def koma(x, d=1):
    return f"{x:.{d}f}".replace(".", ",")


def v8_ci(raw_path: Path):
    raw = json.loads(raw_path.read_text(encoding="utf-8"))
    seeds = sorted({v["seed"] for v in raw.values()})
    rows = []
    for t in TEST_NAME:
        correct = {}
        for sc in SCEN_NAME:
            mats = []
            for s in seeds:
                r = raw[f"{sc}_seed{s}"]
                y = np.frombuffer(r["y_true"][t].encode(), dtype=np.uint8) - 48
                p = np.frombuffer(r["pred"][t].encode(), dtype=np.uint8) - 48
                mats.append(y == p)
            correct[sc] = np.stack(mats)  # (seed, foto)
        n = correct["lab_saja"].shape[1]
        idx = RNG.integers(0, n, size=(N_BOOT, n))
        boot = {sc: correct[sc][:, idx].mean(axis=2).mean(axis=0) for sc in SCEN_NAME}  # (N_BOOT,)
        for sc in SCEN_NAME:
            mean = correct[sc].mean()
            lo, hi = np.percentile(boot[sc], [2.5, 97.5])
            rows.append({"data_uji": TEST_NAME[t], "skenario": SCEN_NAME[sc], "n_foto": n,
                         "akurasi_pct": round(mean * 100, 2), "ci95_bawah": round(lo * 100, 1), "ci95_atas": round(hi * 100, 1)})
        diff = boot["gabungan"] - boot["lab_saja"]
        lo, hi = np.percentile(diff, [2.5, 97.5])
        rows.append({"data_uji": TEST_NAME[t], "skenario": "Selisih (gabungan - lab saja)", "n_foto": n,
                     "akurasi_pct": round((correct["gabungan"].mean() - correct["lab_saja"].mean()) * 100, 2),
                     "ci95_bawah": round(lo * 100, 1), "ci95_atas": round(hi * 100, 1)})
    return rows


def wilson(k, n, z=1.96):
    if n == 0:
        return float("nan"), float("nan")
    p = k / n
    den = 1 + z * z / n
    centre = (p + z * z / (2 * n)) / den
    half = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / den
    return centre - half, centre + half


def v91_ci(scores_path: Path, threshold: float):
    with open(scores_path, encoding="utf-8") as f:
        data = list(csv.DictReader(f))
    groups = {"Tomat (semua sumber) — diterima": [r for r in data if r["kind"] == "tomat"],
              "Tomat PlantDoc — diterima": [r for r in data if r["kind"] == "tomat" and r["src"] == "PlantDoc"],
              "Tomat selain PlantDoc — diterima": [r for r in data if r["kind"] == "tomat" and r["src"] != "PlantDoc"],
              "Bukan tomat (semua) — ditolak": [r for r in data if r["kind"] == "bukan"]}
    for jenis in ["Cabai", "Paprika", "Kentang", "Terong", "Benda umum", "Tekstur"]:
        groups[f"{jenis} — ditolak"] = [r for r in data if r["kind"] == "bukan" and r["jenis"] == jenis]
    rows = []
    for name, rs in groups.items():
        ok = sum((float(r["s0"]) >= threshold) if r["kind"] == "tomat" else (float(r["s0"]) < threshold) for r in rs)
        lo, hi = wilson(ok, len(rs))
        rows.append({"kelompok": name, "n_foto": len(rs), "benar_pct": round(ok / len(rs) * 100, 1),
                     "ci95_bawah": round(lo * 100, 1), "ci95_atas": round(hi * 100, 1)})
    return rows


def write(rows, path: Path):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader(); w.writerows(rows)


def main():
    raw_v8, scores_v91, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    threshold = json.loads((Path(__file__).resolve().parent.parent / "models" / "gate_config.json").read_text(encoding="utf-8"))["threshold"]
    r8 = v8_ci(raw_v8)
    write(r8, out / "v8" / "ci95_akurasi_v8.csv")
    print("v8 — akurasi rata-rata 3 seed, CI 95% bootstrap foto uji (%)")
    for r in r8:
        print(f"  {r['data_uji']:24s} {r['skenario']:32s} n={r['n_foto']:5d}  {koma(r['akurasi_pct'], 2):>6s}  [{koma(r['ci95_bawah'])} – {koma(r['ci95_atas'])}]")
    r9 = v91_ci(scores_v91, threshold)
    write(r9, out / "v9_1" / "ci95_penyaring_v91.csv")
    print(f"\nv9.1 penyaring (foto utuh, ambang {threshold}) — CI 95% Wilson (%)")
    for r in r9:
        print(f"  {r['kelompok']:36s} n={r['n_foto']:5d}  {koma(r['benar_pct'])}  [{koma(r['ci95_bawah'])} – {koma(r['ci95_atas'])}]")


if __name__ == "__main__":
    main()
