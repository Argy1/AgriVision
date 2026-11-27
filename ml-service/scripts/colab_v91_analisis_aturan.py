# Analisis aturan penyaring (notebook v9.1) — jalankan di sesi Colab v9.1 yang SAMA (setelah Step 16).
# Klik "+ Code" di paling bawah, salin SELURUH isi file ini, lalu jalankan. Butuh ±3-5 menit.
# Membandingkan beberapa aturan keputusan pada foto utuh + 6 potongan (make_crops dari Step 14b):
#   utuh   = skor foto utuh saja
#   max    = skor potongan tertinggi
#   top2   = rata-rata 2 potongan tertinggi
#   top3   = rata-rata 3 potongan tertinggi
# Ambang tiap aturan dipilih di VALIDASI dengan 2 kriteria, lalu dilaporkan di UJI per jenis.

import numpy as np
import pandas as pd


def isi_skor_potongan(recs, chunk=256):
    for start in range(0, len(recs), chunk):
        part = recs[start : start + chunk]
        batch = []
        for r in part:
            img = np.asarray(Image.open(r["path"]).convert("RGB"))
            batch += [np.asarray(Image.fromarray(c).resize(IMG_SIZE, Image.BILINEAR), dtype=np.float32) for c in make_crops(img)]
        sc = gate.predict(np.stack(batch), verbose=0, batch_size=128).ravel().reshape(len(part), N_CROPS)
        for r, row in zip(part, sc):
            r["skor"] = row.astype(float)


for sp in ("val", "test"):
    if "skor" not in REC[sp][0]:
        isi_skor_potongan(REC[sp])

ATURAN_SKOR = {
    "utuh": lambda s: s[0],
    "max": lambda s: s.max(),
    "top2": lambda s: np.sort(s)[-2:].mean(),
    "top3": lambda s: np.sort(s)[-3:].mean(),
}
for sp in ("val", "test"):
    for r in REC[sp]:
        for nama, f in ATURAN_SKOR.items():
            r[f"a_{nama}"] = float(f(r["skor"]))

SUMBER_TOMAT = sorted({r["src"] for r in REC["val"] if r["kind"] == "tomat"})
JENIS_UTAMA = ["Cabai", "Paprika", "Kentang", "Terong", "Benda umum", "Tekstur"]


def ringkas(recs, key, t):
    tom = [r for r in recs if r["kind"] == "tomat"]
    buk = [r for r in recs if r["kind"] == "bukan"]
    out = {"tomat diterima": np.mean([r[key] >= t for r in tom]),
           "tomat PlantDoc diterima": np.mean([r[key] >= t for r in tom if r["src"] == "PlantDoc"]),
           "tomat sumber terendah": min(np.mean([r[key] >= t for r in tom if r["src"] == s]) for s in SUMBER_TOMAT),
           "bukan tomat ditolak": np.mean([r[key] < t for r in buk])}
    for j in JENIS_UTAMA:
        rs = [r for r in buk if r["jenis"] == j]
        if rs:
            out[f"{j} ditolak"] = np.mean([r[key] < t for r in rs])
    return out


KRITERIA = {
    "K1: total tomat >=98%, tiap sumber >=90%":
        lambda m: m["tomat diterima"] >= 0.98 and m["tomat sumber terendah"] >= 0.90,
    "K2: total tomat >=97%, tiap sumber >=85%":
        lambda m: m["tomat diterima"] >= 0.97 and m["tomat sumber terendah"] >= 0.85,
}
rows = []
for nama in ATURAN_SKOR:
    key = f"a_{nama}"
    for kname, kfun in KRITERIA.items():
        ok = [t for t in grid if kfun(ringkas(REC["val"], key, t))]
        if not ok:
            rows.append({"aturan": nama, "kriteria": kname, "ambang": None}); continue
        t = float(max(ok))
        m = ringkas(REC["test"], key, t)
        rows.append({"aturan": nama, "kriteria": kname, "ambang": t, **{k: round(v * 100, 1) for k, v in m.items()}})
TABEL_ATURAN = pd.DataFrame(rows)
pd.set_option("display.max_columns", 30); pd.set_option("display.width", 250)
print("Tabel 7. Perbandingan aturan (ambang dipilih di VALIDASI, angka di UJI, %)")
display(TABEL_ATURAN)
TABEL_ATURAN.to_csv(f"{OUT_DIR}/tabel_7_perbandingan_aturan.csv", index=False)

# Kurva lengkap per aturan (data validasi) untuk memilih ambang secara manual bila perlu
kurva = []
for nama in ATURAN_SKOR:
    for t in np.round(np.arange(0.05, 1.0, 0.05), 2):
        kurva.append({"aturan": nama, "ambang": t, **{k: round(v * 100, 1) for k, v in ringkas(REC["val"], f"a_{nama}", t).items()}})
pd.DataFrame(kurva).to_csv(f"{OUT_DIR}/tabel_8_kurva_aturan_validasi.csv", index=False)

# Skor potongan per foto uji (untuk analisis lanjutan di luar Colab)
pd.DataFrame([{"kind": r["kind"], "jenis": r["jenis"], "src": r["src"], **{f"s{i}": round(float(v), 4) for i, v in enumerate(r["skor"])}}
              for r in REC["test"]]).to_csv(f"{OUT_DIR}/skor_potongan_uji.csv", index=False)
pd.DataFrame([{"kind": r["kind"], "jenis": r["jenis"], "src": r["src"], **{f"s{i}": round(float(v), 4) for i, v in enumerate(r["skor"])}}
              for r in REC["val"]]).to_csv(f"{OUT_DIR}/skor_potongan_validasi.csv", index=False)

shutil.make_archive("/content/hasil_v91_analisis", "zip", OUT_DIR)
try:
    from google.colab import files
    files.download("/content/hasil_v91_analisis.zip")
except Exception as e:
    print("Unduh manual dari panel Files (/content/hasil_v91_analisis.zip):", e)
