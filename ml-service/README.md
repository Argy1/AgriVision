# AgriVision — ML Service (FastAPI)

Backend inferensi: menerima `POST /api/diagnose`, menjalankan model CNN (tomat: MobileNetV2, TFLite), menghitung `affected_area_pct`/`severity` (HSV) dan ExG/VARI → `health_score` (OpenCV), mencari rekomendasi di `disease_reference`, lalu menyimpan hasil ke Supabase dengan service role. Kontrak: `../docs/04-api-contract.md`. Konteks proyek: `../CLAUDE.md`.

Live: `https://agrivision-production.up.railway.app` (cek: `/api/health`). `/` mengembalikan `{"detail":"Not Found"}` — normal, API tidak punya halaman root.

Mencoba sendiri (tanpa menyentuh produksi): `../docs/10-panduan-setup-mandiri.md`. Dataset, notebook, dan melatih ulang model: `../docs/11-dataset-dan-notebook.md`.

## Menjalankan

```bash
python -m venv .venv && .venv/Scripts/activate      # Windows; Linux/macOS: source .venv/bin/activate. Gunakan Python 3.11
pip install -r requirements-dev.txt
cp .env.example .env                                # isi SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (RAHASIA), SUPABASE_ANON_KEY
uvicorn app.main:app --port 8000
```

Docker (dari root repo): `docker compose up --build ml-service` (lihat `../docker-compose.yml`, `../docker/ml-service.Dockerfile`).

**Tanpa Supabase sama sekali** — uji model pada foto lokal:
```bash
python scripts/predict_local.py foto.jpg            # atau folder; tambahkan --json untuk keluaran mesin
```

## Tes

```bash
pytest tests/test_schemas.py tests/test_cv_quality.py tests/test_enhance.py   # offline, tanpa .env/akun
pytest tests/test_e2e_diagnose.py                                              # E2E: butuh .env asli; membuat user+zona sementara, memanggil diagnose, lalu membersihkan
```
(`pytest` tanpa argumen menjalankan keduanya; E2E gagal bila `.env` belum terisi.)

## Struktur

```
app/main.py            — lifespan (muat model sekali), CORS dari ALLOWED_ORIGINS
app/routers/diagnose.py— alur utama; urutan insert (diagnoses → vegetation_index_readings → recommendations) PENTING untuk trigger zone_health_daily
app/auth.py            — validasi bearer token user via Supabase
app/ml/                — label_map, model_loader (TFLite, lock per model), inference, enhance (pra-pemrosesan untuk eksperimen)
app/cv/                — segmentation, leaf_region, affected_area, severity, vegetation_index (ExG/VARI), photo_quality (penolakan/peringatan), analyzer
app/supabase_client.py — klien service role (insert + baca Storage)
models/                — tomato_classifier.tflite (diagnosis v8) + label_map.json + tomato_gate.tflite (penyaring v9.1) + gate_config.json (ter-commit; Railway dan Docker memakainya langsung)
*.ipynb                — 9 notebook training/eksperimen (Colab); peta lengkapnya di ../docs/11-dataset-dan-notebook.md
results/               — hasil mentah eksperimen (CSV) + metrics_v6_prod_v2.json (model produksi)
evaluation/            — confusion matrix lab (model v1)
scripts/               — predict_local.py (uji model tanpa Supabase); purge_chili_data.py (sekali pakai, sudah dijalankan)
tests/                 — unit test offline + 1 tes E2E
```

## Environment variable

| Nama | Isi |
|---|---|
| `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | wajib; service role key RAHASIA, hanya di sini |
| `SUPABASE_ANON_KEY` | hanya untuk tes E2E |
| `STORAGE_BUCKET` | bawaan `plant-photos` |
| `MODEL_DIR` | bawaan `models` |
| `ALLOWED_ORIGINS` | origin yang boleh memanggil API (CORS), dipisah koma; `*` hanya untuk uji lokal |
| `REJECT_CONFIDENCE` | opsional, bawaan `0.30`: keyakinan penyakit tertinggi di bawah ini → ditolak (400); 30–60% didiagnosis dengan peringatan |
| `GATE_THRESHOLD` | opsional: ambang penyaring daun tomat (bawaan `models/gate_config.json`, 0.45) |
| `GATE_MULTICROP` | opsional: `1` = penyaring juga menilai 6 potongan foto (bawaan mati) |

## Deploy (Railway)

Root directory **`ml-service`**, start via `Procfile`, Python 3.11 (`.python-version`), healthcheck `/api/health`. Variable: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `STORAGE_BUCKET=plant-photos`, `MODEL_DIR=models`, `ALLOWED_ORIGINS`. Pemulihan jika service terhapus: `../docs/09-operasional-dan-runbook.md`. Jangan menaruh `Dockerfile` di folder ini: Railway akan beralih dari Procfile ke Dockerfile (berkas Docker lokal ada di `../docker/`).

## Catatan

- `agrivision_models.zip`, `kaggle.json`, `roboflow_key.txt`: artefak lokal lama yang di-gitignore; kunci tidak boleh di-commit.
- Foto bukan daun tomat ditolak oleh **penyaring v9.1** (`app/ml/gate.py`, `models/tomato_gate.tflite` + `gate_config.json`) sebelum diagnosis; data uji: tomat 98,2% diterima, cabai 91,9% ditolak (tidak sempurna). Lihat `../docs/05-ml-pipeline.md` dan `../docs/08-status-dan-progres.md` Fase 11.
- Kalibrasi `_EXG_MIN/_EXG_MAX` di `app/cv/vegetation_index.py` masih placeholder.
