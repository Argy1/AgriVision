"""Kalibrasi skor kesehatan (ExG/VARI) dan luas terdampak dengan foto berlabel sehat vs sakit.

Data: Tomato-Village (foto kebun asli; kelas Healthy, Early_blight, Late_blight). Folder train+val
dipakai untuk MENENTUKAN batas, folder test untuk MENGECEK hasilnya.

Jalankan dari folder ml-service:
    python scripts/kalibrasi_cv.py "<folder Variant-a(Multiclass Classification)>" [--max-side 1024] [--out results/kalibrasi_cv]

Keluaran: statistik per kelas (ExG, VARI, luas terdampak, severity), AUC sehat-vs-sakit, dan usulan
_EXG_MIN/_EXG_MAX (dicetak; tidak mengubah kode secara otomatis).
"""

import argparse
import csv
import os
import sys
from pathlib import Path

os.environ.setdefault("SUPABASE_URL", "http://localhost")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "tidak-dipakai")
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402

from app.cv.analyzer import analyze_image  # noqa: E402

KELAS = {"Healthy": "sehat", "Early_blight": "sakit", "Late_blight": "sakit"}


def auc(pos, neg):
    """Peluang skor acak 'pos' > skor acak 'neg' (Mann-Whitney)."""
    pos, neg = np.asarray(pos), np.asarray(neg)
    allv = np.concatenate([pos, neg])
    ranks = allv.argsort().argsort() + 1
    r_pos = ranks[: len(pos)].sum()
    return (r_pos - len(pos) * (len(pos) + 1) / 2) / (len(pos) * len(neg))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("root")
    ap.add_argument("--max-side", type=int, default=1024)
    ap.add_argument("--out", default="results/kalibrasi_cv")
    a = ap.parse_args()
    rows = []
    for split in ["train", "val", "test"]:
        for folder, label in KELAS.items():
            d = Path(a.root) / split / folder
            for p in sorted(d.glob("*")):
                if p.suffix.lower() not in (".jpg", ".jpeg", ".png"):
                    continue
                img = Image.open(p).convert("RGB")
                img.thumbnail((a.max_side, a.max_side))
                r = analyze_image(np.asarray(img))
                vi = r["vegetation_index"]
                rows.append({"split": split, "kelas": folder, "label": label, "file": p.name,
                             "exg": vi["exg_score"], "vari": vi["vari_score"], "health_score": vi["health_score"],
                             "affected_area_pct": r["affected_area_pct"], "severity": r["severity"]})
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    with open(out / "skor_cv_tomato_village.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)

    def col(sel, key):
        return np.array([r[key] for r in rows if sel(r)], dtype=float)

    print(f"{len(rows)} foto dianalisis\n")
    print("Median per kelas (semua split):")
    for k in KELAS:
        sel = lambda r, k=k: r["kelas"] == k
        sev = [r["severity"] for r in rows if sel(r)]
        print(f"  {k:13s} n={len(sev):4d}  ExG {np.median(col(sel, 'exg')):.3f}  VARI {np.median(col(sel, 'vari')):.3f}  "
              f"health {np.median(col(sel, 'health_score')):5.1f}  terdampak {np.median(col(sel, 'affected_area_pct')):5.1f}%  "
              f"severity ringan/sedang/parah = {sev.count('ringan')}/{sev.count('sedang')}/{sev.count('parah')}")
    for key in ["exg", "vari", "health_score"]:
        h = col(lambda r: r["label"] == "sehat", key); s = col(lambda r: r["label"] == "sakit", key)
        print(f"AUC {key:12s} (sehat > sakit): {auc(h, s):.3f}")
    h = col(lambda r: r["label"] == "sehat", "affected_area_pct"); s = col(lambda r: r["label"] == "sakit", "affected_area_pct")
    print(f"AUC affected_area (sakit > sehat): {auc(s, h):.3f}")

    fit = lambda r: r["split"] in ("train", "val")
    h_exg = col(lambda r: fit(r) and r["label"] == "sehat", "exg")
    s_exg = col(lambda r: fit(r) and r["label"] == "sakit", "exg")
    print(f"\nExG latih+val: sehat p5/p50/p95 = {np.percentile(h_exg, [5, 50, 95]).round(3)} | "
          f"sakit p5/p50/p95 = {np.percentile(s_exg, [5, 50, 95]).round(3)}")


if __name__ == "__main__":
    main()
