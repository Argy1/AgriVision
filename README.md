# AgriVision — Projek Akhir Computer Vision

Sistem Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat Berbasis Computer Vision untuk Precision Farming.
Tugas akhir mata kuliah Visual Komputer Cerdas — Argy Fawwaz Akbar, D4 TRPL, Sekolah Vokasi IPB University.

**Status (2026-10-24): sistem sudah dibangun, di-deploy, dan diuji end-to-end.** Yang tersisa: uji foto lapangan nyata, evaluasi akurasi lab vs lapangan, verifikasi konten rekomendasi, dan penulisan laporan. Rinciannya di [`docs/08-status-dan-progres.md`](docs/08-status-dan-progres.md).

## Cara kerja singkat

Pengguna memotret daun → foto ke Supabase Storage → FastAPI (Railway) menjalankan model CNN (diagnosis penyakit), menghitung ExG/VARI (skor kesehatan), dan mencari rekomendasi di tabel `disease_reference` → hasil tersimpan di Postgres → tampil di web (Next.js) dan app (Flutter). Siapa pun bisa mendaftar sendiri (akun otomatis "petani").

| Bagian | Teknologi | Live |
|---|---|---|
| Web | Next.js 16 + Tailwind v4 | https://agrivision-blond-nine.vercel.app |
| ML service | FastAPI + TFLite + OpenCV | https://agrivision-production.up.railway.app/api/health |
| App | Flutter + Riverpod | APK dipasang ke HP (`app/`) |
| Data | Supabase (Postgres/Auth/Storage) | project `ymfcrxymizwwolikgrhq` |

## Mulai dari mana?

- **Claude Code / Claude Cowork:** baca [`CLAUDE.md`](CLAUDE.md) dulu (aturan, scope, gotcha), lalu `docs/08` dan `docs/09`.
- **Manusia:** baca `docs/01-project-brief.md` untuk konteks, `docs/08` untuk progres, `docs/09` untuk menjalankan/deploy.

## Struktur Folder

```
├── CLAUDE.md                    ← orientasi lengkap (baca ini duluan)
├── docs/
│   ├── 01-project-brief.md      — judul, rumusan masalah, tujuan, scope, keputusan
│   ├── 02-tech-stack.md         — stack aktual + alur sistem
│   ├── 03-database-schema.md    — penjelasan skema, trigger, RLS
│   ├── 04-api-contract.md       — kontrak endpoint FastAPI (wajib diikuti web & app)
│   ├── 05-ml-pipeline.md        — dataset, model, vegetation index, evaluasi + status implementasi
│   ├── 06-roadmap.md            — rencana 14 minggu + status tiap minggu
│   ├── 07-referensi.md          — 22 referensi akademik
│   ├── 08-status-dan-progres.md — apa yang sudah/belum, keputusan, riwayat, keterbatasan
│   └── 09-operasional-dan-runbook.md — env var, jalankan lokal, deploy, pemulihan insiden, resep tes
├── design/                      — design-system.md + 8 mockup (HTML/PNG)
├── database/
│   ├── schema.sql               — skema lengkap (sumber kebenaran, sinkron dengan produksi)
│   └── migrations/              — migrasi tambahan (003 = pengerasan registrasi publik)
├── ml-service/                  — FastAPI, model .tflite, notebook training, tes E2E
├── web/                         — Next.js
└── app/                         — Flutter
```

## Menjalankan cepat

```bash
cd web && npm install && npm run dev                 # butuh web/.env.local (lihat web/.env.example)
cd ml-service && pip install -r requirements-dev.txt && uvicorn app.main:app   # butuh ml-service/.env
cd app && flutter pub get && flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=ML_API_URL=...
```
Detail lengkap, termasuk deploy dan pemulihan: [`docs/09-operasional-dan-runbook.md`](docs/09-operasional-dan-runbook.md).
