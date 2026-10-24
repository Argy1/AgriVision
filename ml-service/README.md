# AgriVision — ML Service (FastAPI)

Backend inferensi: menerima `POST /api/diagnose`, menjalankan model CNN (tomat: MobileNetV2, cabai: EfficientNetB4, TFLite), menghitung `affected_area_pct`/`severity` (HSV) dan ExG/VARI → `health_score` (OpenCV), mencari rekomendasi di `disease_reference`, lalu menyimpan hasil ke Supabase dengan service role. Kontrak: `../docs/04-api-contract.md`. Konteks proyek: `../CLAUDE.md`.

Live: `https://agrivision-production.up.railway.app` (cek: `/api/health`). `/` mengembalikan `{"detail":"Not Found"}` — normal, API tidak punya halaman root.

## Menjalankan

```bash
python -m venv .venv && .venv/Scripts/activate      # Windows
pip install -r requirements-dev.txt
cp .env.example .env                                # isi SUPABASE_SERVICE_ROLE_KEY (RAHASIA) dan SUPABASE_ANON_KEY
uvicorn app.main:app --port 8000
pytest                                              # E2E: membuat user+zona sementara, memanggil diagnose, lalu membersihkan
```

## Struktur

```
app/main.py            — lifespan (muat model sekali), CORS dari ALLOWED_ORIGINS
app/routers/diagnose.py— alur utama; urutan insert (diagnoses → vegetation_index_readings → recommendations) PENTING untuk trigger zone_health_daily
app/auth.py            — validasi bearer token user via Supabase
app/ml/                — label_map, model_loader (TFLite, lock per model), inference
app/cv/                — segmentation, affected_area, severity, vegetation_index (ExG/VARI), analyzer
app/supabase_client.py — klien service role (insert + baca Storage)
models/                — *.tflite + label_map.json (ter-commit; Railway memakainya langsung)
agrivision_training.ipynb — training di Colab; evaluation/ — confusion matrix lab
tests/test_e2e_diagnose.py
```

## Deploy (Railway)

Root directory **`ml-service`**, start via `Procfile`, Python 3.11 (`.python-version`), healthcheck `/api/health`. Variable: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `STORAGE_BUCKET=plant-photos`, `MODEL_DIR=models`, `ALLOWED_ORIGINS`. Pemulihan jika service terhapus: `../docs/09-operasional-dan-runbook.md`.

## Catatan

- `agrivision_models.zip`, `kaggle.json`, `roboflow_key.txt`: artefak training lokal; kunci tidak boleh di-commit.
- Kalibrasi `_EXG_MIN/_EXG_MAX` di `app/cv/vegetation_index.py` masih placeholder.
