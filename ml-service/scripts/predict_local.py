"""Jalankan model + classical CV pada foto lokal TANPA Supabase / jaringan / .env.

Cocok untuk mencoba model sendiri: keluaran sama dengan yang dihitung /api/diagnose
(label penyakit, keyakinan, luas terdampak, severity, ExG/VARI, kelayakan foto), tetapi
tidak ada yang disimpan ke database dan tidak ada rekomendasi (itu butuh tabel
disease_reference di Supabase).

Jalankan dari folder ml-service (setelah `pip install -r requirements.txt`):
    python scripts/predict_local.py foto.jpg
    python scripts/predict_local.py folder_foto/            # semua .jpg/.jpeg/.png/.webp
    python scripts/predict_local.py folder_foto/ --json     # keluaran JSON per baris
"""

import argparse
import json
import os
import sys
from pathlib import Path

# app.config mewajibkan variabel Supabase; skrip ini tidak memakainya, jadi isi placeholder
# (nilai asli di environment/.env tetap dipakai bila ada).
os.environ.setdefault("SUPABASE_URL", "http://localhost")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "tidak-dipakai")

# supaya `import app...` bekerja saat dijalankan sebagai skrip dari folder ml-service
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.cv.analyzer import analyze_image  # noqa: E402
from app.cv.photo_quality import assess_photo  # noqa: E402
from app.imaging import decode_image  # noqa: E402
from app.ml.inference import classify  # noqa: E402
from app.ml.model_loader import model_registry  # noqa: E402

EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}


def collect(paths: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        p = Path(raw)
        if p.is_dir():
            files += sorted(f for f in p.rglob("*") if f.suffix.lower() in EXTENSIONS)
        elif p.is_file():
            files.append(p)
        else:
            print(f"Lewati (tidak ditemukan): {raw}", file=sys.stderr)
    return files


def analyze_file(path: Path) -> dict:
    image = decode_image(path.read_bytes())
    classification = classify("tomat", image)
    cv_result = analyze_image(image)
    masks = cv_result["masks"]
    quality = assess_photo(
        masks["green"],
        masks["lesion"],
        masks["nonleaf"],
        cv_result["scene_fraction"],
        classification["confidence"],
    )
    return {
        "file": str(path),
        "disease_label": classification["disease_label"],
        "confidence": classification["confidence"],
        "model_version": classification["model_version"],
        "severity": cv_result["severity"],
        "affected_area_pct": cv_result["affected_area_pct"],
        "vegetation_index": cv_result["vegetation_index"],
        # Pada /api/diagnose foto yang ditolak tidak disimpan; di sini tetap ditampilkan.
        "rejected": quality.rejected,
        "reject_reason": quality.reject_detail() if quality.rejected else None,
        "warning": quality.warning_text(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("paths", nargs="+", help="file gambar atau folder")
    parser.add_argument("--json", action="store_true", help="cetak satu objek JSON per baris")
    args = parser.parse_args()

    files = collect(args.paths)
    if not files:
        print("Tidak ada gambar ditemukan.", file=sys.stderr)
        return 1

    model_registry.load_all()
    for path in files:
        try:
            result = analyze_file(path)
        except Exception as exc:  # satu file rusak tidak boleh menghentikan batch
            print(f"{path}: GAGAL ({exc})", file=sys.stderr)
            continue
        if args.json:
            print(json.dumps(result, ensure_ascii=False))
            continue
        flag = "DITOLAK" if result["rejected"] else "ok"
        print(
            f"{path.name:40.40s} {result['disease_label']:45s} "
            f"yakin {result['confidence'] * 100:5.1f}%  {result['severity']:7s} "
            f"terdampak {result['affected_area_pct']:5.1f}%  [{flag}]"
        )
        if result["reject_reason"]:
            print(f"    ditolak: {result['reject_reason']}")
        if result["warning"]:
            print(f"    catatan: {result['warning']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
