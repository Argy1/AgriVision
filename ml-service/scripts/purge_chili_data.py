"""Hapus semua data cabai dari produksi (proyek fokus ke tomat saja).

Urutan aman:
  1. Kumpulkan zona cabai + path foto uploads-nya (SEBELUM zona dihapus).
  2. Hapus objek Storage (cascade database TIDAK menghapus file di Storage).
  3. Hapus zones cabai (cascade ke uploads, diagnoses, recommendations,
     vegetation_index_readings, zone_health_daily) dan disease_reference cabai.

Default = DRY-RUN (hanya membaca dan menampilkan ringkasan). Penghapusan nyata
HANYA berjalan dengan --execute. Tidak bisa dibatalkan.

Jalankan dari folder ml-service (butuh .env berisi service role key):
    python scripts/purge_chili_data.py              # dry-run
    python scripts/purge_chili_data.py --execute    # hapus sungguhan
"""

import argparse
import sys
from pathlib import Path

# supaya `import app...` bekerja saat dijalankan sebagai skrip dari folder ml-service
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.config import settings  # noqa: E402
from app.supabase_client import get_client  # noqa: E402

CHUNK = 100


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--execute", action="store_true", help="hapus sungguhan (default: dry-run)")
    args = parser.parse_args()

    db = get_client()

    zones = db.table("zones").select("id, name, owner_id").eq("crop_type", "cabai").execute().data
    zone_ids = [z["id"] for z in zones]

    uploads: list[dict] = []
    for i in range(0, len(zone_ids), CHUNK):
        uploads += (
            db.table("uploads")
            .select("id, image_path")
            .in_("zone_id", zone_ids[i : i + CHUNK])
            .execute()
            .data
        )
    paths = [u["image_path"] for u in uploads if u.get("image_path")]
    upload_ids = [u["id"] for u in uploads]

    diagnosis_count = 0
    for i in range(0, len(upload_ids), CHUNK):
        diagnosis_count += (
            db.table("diagnoses")
            .select("id", count="exact")
            .in_("upload_id", upload_ids[i : i + CHUNK])
            .execute()
            .count
            or 0
        )

    refs = db.table("disease_reference").select("disease_label").eq("crop_type", "cabai").execute().data

    print(f"Zona cabai          : {len(zones)}")
    for z in zones:
        print(f"  - {z['name']} ({z['id']}) owner={z['owner_id']}")
    print(f"Uploads (foto)      : {len(uploads)}  -> objek Storage: {len(paths)}")
    print(f"Diagnosis           : {diagnosis_count}")
    print(f"disease_reference   : {len(refs)} baris cabai")

    if not args.execute:
        print("\nDRY-RUN: tidak ada yang dihapus. Tambahkan --execute untuk menghapus.")
        return 0

    print("\nMENGHAPUS...")
    removed = 0
    for i in range(0, len(paths), CHUNK):
        batch = paths[i : i + CHUNK]
        db.storage.from_(settings.storage_bucket).remove(batch)
        removed += len(batch)
    print(f"Storage: {removed} objek dihapus")

    for i in range(0, len(zone_ids), CHUNK):
        db.table("zones").delete().in_("id", zone_ids[i : i + CHUNK]).execute()
    print(f"zones: {len(zone_ids)} dihapus (cascade ke uploads/diagnoses/dst.)")

    db.table("disease_reference").delete().eq("crop_type", "cabai").execute()
    print("disease_reference: baris cabai dihapus")

    # pasca-cek
    left_zones = db.table("zones").select("id", count="exact").eq("crop_type", "cabai").execute().count
    left_refs = db.table("disease_reference").select("disease_label", count="exact").execute().count
    print(f"\nPASCA-CEK: zona cabai tersisa = {left_zones}; total disease_reference = {left_refs} (harus 10)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
