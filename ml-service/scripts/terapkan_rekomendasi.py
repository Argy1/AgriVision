"""Terapkan database/migrations/006_rekomendasi_bersumber.sql ke disease_reference lewat API Supabase.

Dipakai bila tidak memakai Supabase SQL Editor. Butuh ml-service/.env (service role). Langkah:
  1. cadangkan semua baris disease_reference ke JSON (untuk rollback),
  2. jalankan setiap UPDATE di file 006 (diurai dari SQL; hanya kolom teks + is_verified),
  3. baca ulang dan bandingkan.

    python scripts/terapkan_rekomendasi.py --backup results/disease_reference_backup_<tanggal>.json
    python scripts/terapkan_rekomendasi.py --rollback results/disease_reference_backup_<tanggal>.json
"""

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from app.supabase_client import get_client  # noqa: E402

SQL = Path(__file__).resolve().parents[2] / "database" / "migrations" / "006_rekomendasi_bersumber.sql"
COLS = ["disease_label", "disease_name", "crop_type", "description", "recommendation_text", "dosage",
        "application_schedule", "warning_note", "is_verified", "updated_at"]


def parse_updates(text: str) -> dict:
    out = {}
    for block in re.findall(r"update disease_reference set(.*?)where disease_label = '([^']+)';", text, re.S):
        body, label = block
        fields = {}
        for col, val in re.findall(r"(\w+)\s*=\s*('(?:[^']|'')*'|null|false|true|now\(\))", body):
            if col == "updated_at":
                continue
            if val == "null":
                fields[col] = None
            elif val in ("true", "false"):
                fields[col] = val == "true"
            else:
                fields[col] = val[1:-1].replace("''", "'")
        out[label] = fields
    return out


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--backup")
    g.add_argument("--rollback")
    a = ap.parse_args()
    db = get_client()

    if a.rollback:
        rows = json.loads(Path(a.rollback).read_text(encoding="utf-8"))
        for r in rows:
            db.table("disease_reference").update({k: r[k] for k in COLS[4:9]} | {"updated_at": datetime.now(timezone.utc).isoformat()}) \
                .eq("disease_label", r["disease_label"]).execute()
        print(f"Rollback {len(rows)} baris dari {a.rollback}")
        return

    before = db.table("disease_reference").select(",".join(COLS)).order("disease_label").execute().data
    Path(a.backup).parent.mkdir(parents=True, exist_ok=True)
    Path(a.backup).write_text(json.dumps(before, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Cadangan {len(before)} baris -> {a.backup}")

    updates = parse_updates(SQL.read_text(encoding="utf-8"))
    known = {r["disease_label"] for r in before}
    missing = set(updates) - known
    assert not missing, f"label tidak ada di database: {missing}"
    print(f"{len(updates)} UPDATE diurai dari {SQL.name}")

    now = datetime.now(timezone.utc).isoformat()
    for label, fields in updates.items():
        res = db.table("disease_reference").update(fields | {"updated_at": now}).eq("disease_label", label).execute()
        assert len(res.data) == 1, (label, res.data)

    after = {r["disease_label"]: r for r in db.table("disease_reference").select(",".join(COLS)).execute().data}
    bad = [(lbl, c) for lbl, f in updates.items() for c, v in f.items() if after[lbl][c] != v]
    print("Verifikasi:", "SEMUA COCOK" if not bad else f"TIDAK COCOK {bad}")
    for lbl in sorted(updates):
        r = after[lbl]
        print(f"  {lbl:45s} verified={r['is_verified']!s:5s} dosis={r['dosage']!s:40.40s} | {r['recommendation_text'][:60]}…")


if __name__ == "__main__":
    main()
