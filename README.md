# AgriVision — Projek Akhir Computer Vision

Sistem Diagnosis Penyakit Daun Tomat berbasis Computer Vision (klasifikasi CNN) dengan skor kesehatan tanaman (ExG/VARI) dan rekomendasi penanganan, untuk precision farming.
Tugas akhir mata kuliah Visual Komputer Cerdas — Argy Fawwaz Akbar, TRPL, Sekolah Vokasi IPB University.

**Status (2026-11-28): sistem sudah dibangun, di-deploy, dan diuji end-to-end; model diagnosis v8 + penyaring daun tomat v9.1 (branch `fitur/model-v8-penyaring-v9`, menunggu merge).** Yang tersisa: foto lapangan berlabel untuk evaluasi, verifikasi isi rekomendasi, uji aplikasi HP, dan penulisan laporan/naskah. Rincian di [`docs/08-status-dan-progres.md`](docs/08-status-dan-progres.md).

> **Fokus tomat saja** (arahan pembimbing, 2026-11-12). Model hanya mengenal 10 kelas daun tomat; foto tanaman lain tidak didukung.

## Cara kerja singkat

Pengguna memotret daun → foto ke Supabase Storage → FastAPI (Railway) menjalankan model CNN (diagnosis penyakit), menghitung ExG/VARI (skor kesehatan), dan mencari rekomendasi di tabel `disease_reference` → hasil tersimpan di Postgres → tampil di web (Next.js) dan app (Flutter). Siapa pun bisa mendaftar sendiri (akun otomatis "petani"). Sebelum diagnosis, pengguna bisa memotong foto ke satu daun; model penyaring menolak foto yang bukan daun tomat; foto tanpa daun atau berkeyakinan < 30% ditolak, keyakinan 30–60% diberi peringatan "model ragu".

| Bagian | Teknologi | Live |
|---|---|---|
| Web | Next.js 16 + Tailwind v4 | https://agrivision-blond-nine.vercel.app |
| ML service | FastAPI + TFLite + OpenCV | https://agrivision-production.up.railway.app/api/health |
| App | Flutter + Riverpod | APK dipasang ke HP (`app/`) |
| Data | Supabase (Postgres/Auth/Storage) | project `ymfcrxymizwwolikgrhq` |
| Model | Diagnosis: MobileNetV2 v8 (lab + PlantDoc + Tomato-Village digabung per kelas, 70/10/20), TFLite float16 4,5 MB; penyaring daun tomat: MobileNetV2 biner v9.1, 4,5 MB | `ml-service/models/` |

## Mulai dari mana?

- **Ingin mencoba/menjalankan sendiri (anggota kelompok):** [`docs/10-panduan-setup-mandiri.md`](docs/10-panduan-setup-mandiri.md) — uji model tanpa akun, Docker Compose, tanpa Docker, app Flutter, dan membuat project Supabase sendiri.
- **Dataset, notebook training, melatih ulang model:** [`docs/11-dataset-dan-notebook.md`](docs/11-dataset-dan-notebook.md).
- **Claude Code / Claude Cowork:** baca [`CLAUDE.md`](CLAUDE.md) dulu (aturan, scope, gotcha), lalu `docs/08` dan `docs/09`.
- **Manusia (konteks):** `docs/01-project-brief.md`; progres di `docs/08`; deploy/pemulihan produksi di `docs/09`.

## Menjalankan cepat

```bash
# 1) Uji model pada foto sendiri, tanpa akun apa pun
cd ml-service && python -m venv .venv && .venv/Scripts/activate && pip install -r requirements.txt
python scripts/predict_local.py foto_daun.jpg

# 2) Seluruh sistem dengan Docker (butuh project Supabase sendiri; langkahnya di docs/10)
cp .env.example .env            # isi SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
docker compose up --build       # web http://localhost:3000 · ml-service http://localhost:8000

# 3) Tanpa Docker (tiga terminal)
cd web && npm install && npm run dev                                           # butuh web/.env.local
cd ml-service && pip install -r requirements-dev.txt && uvicorn app.main:app   # butuh ml-service/.env
cd app && flutter pub get && flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=ML_API_URL=...
```

Produksi (deploy, pemulihan insiden, resep tes): [`docs/09-operasional-dan-runbook.md`](docs/09-operasional-dan-runbook.md).

## Struktur Folder

```
├── CLAUDE.md                    ← orientasi lengkap (baca ini duluan)
├── docker-compose.yml           ← web + ml-service untuk dijalankan lokal (docker/ berisi Dockerfile)
├── .env.example                 ← variabel untuk docker compose (salin ke .env)
├── docs/
│   ├── 01-project-brief.md      — judul, rumusan masalah, tujuan, scope, keputusan
│   ├── 02-tech-stack.md         — stack aktual + alur sistem
│   ├── 03-database-schema.md    — penjelasan skema, trigger, RLS
│   ├── 04-api-contract.md       — kontrak endpoint FastAPI (wajib diikuti web & app)
│   ├── 05-ml-pipeline.md        — dataset, model, vegetation index, hasil semua eksperimen
│   ├── 06-roadmap.md            — rencana 14 minggu + status tiap minggu
│   ├── 07-referensi.md          — referensi akademik
│   ├── 08-status-dan-progres.md — apa yang sudah/belum, keputusan, riwayat, keterbatasan
│   ├── 09-operasional-dan-runbook.md — env var produksi, deploy, pemulihan insiden, resep tes
│   ├── 10-panduan-setup-mandiri.md   — menjalankan sendiri: lokal, Docker, Supabase sendiri, app
│   └── 11-dataset-dan-notebook.md    — sumber dataset, peta notebook, melatih ulang, memasang model
├── design/                      — design-system.md + 8 mockup (HTML/PNG)
├── database/
│   ├── schema.sql               — skema lengkap (sumber kebenaran, sudah memuat migrasi 003)
│   └── migrations/              — 003 pengerasan registrasi, 004 hapus data cabai, 005 bucket+kebijakan Storage (instalasi baru)
├── ml-service/                  — FastAPI, model .tflite, 9 notebook, hasil mentah, tes, skrip (predict_local.py)
├── web/                         — Next.js 16
└── app/                         — Flutter
```

Tidak ada di repositori (sengaja): dataset mentah (notebook mengunduhnya sendiri), foto lapangan pribadi, naskah/PPT, dan semua kunci. Alasannya di `docs/10` bagian 8 dan `docs/11` bagian 1.
