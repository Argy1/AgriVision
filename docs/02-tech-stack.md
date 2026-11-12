# Tech Stack

## Ringkasan

| Layer | Teknologi | Alasan |
|---|---|---|
| Web | Next.js 16 (App Router, `proxy.ts`) + React + Tailwind CSS v4 + `@supabase/ssr`, zod, react-hook-form, Recharts, Radix Dialog | SSR, deploy mudah ke Vercel, cocok untuk dashboard admin/PPL |
| Mobile App | Flutter 3.41 (Dart 3.11) + Riverpod 3 (tanpa codegen) + go_router + `supabase_flutter` + dio + fl_chart + image_picker + google_fonts | Native feel, akses kamera matang, package resmi Supabase |
| Database / Auth / Storage | Supabase (Postgres) | Auth, Storage, Postgres dalam satu paket terintegrasi; RLS built-in |
| ML Inference | FastAPI (Python) di Railway | Menjalankan model CNN (deteksi penyakit) + hitung ExG/VARI (classical CV) |
| Model | MobileNetV2 / EfficientNetB4 (transfer learning), TFLite/ONNX untuk inference ringan | Standar de-facto untuk klasifikasi penyakit daun (lihat `07-referensi.md`) |

## Kenapa dipisah Supabase vs Railway (bukan salah satu saja)

**Supabase TIDAK BISA menjalankan model deep learning.** Edge Functions Supabase berjalan di runtime Deno — tidak ada dukungan TensorFlow/PyTorch/ONNX runtime. Karena itu:

- **Supabase** menangani: Postgres (data), Auth (login), Storage (foto tanaman).
- **Railway (FastAPI)** menangani: inference model CNN + komputasi vegetation index (OpenCV/NumPy).

**Kenapa tidak full Railway juga:** Supabase memberi Auth + Storage + RLS + realtime siap pakai dengan SDK client-side yang matang (`@supabase/supabase-js`, `supabase_flutter`). Membangun semua itu dari nol di Railway membuang waktu development yang seharusnya dipakai untuk model CV dan fitur inti — tidak sepadan untuk scope tugas akhir satu semester.

## Alur Sistem

```
User (web/app) → upload foto → Supabase Storage
                              → Supabase Postgres (buat record uploads)
Frontend → cek diagnoses untuk upload_id (idempotensi) lalu POST FastAPI /api/diagnose (Bearer token user)
FastAPI  → download foto dari Supabase Storage (service role)
         → jalankan model CNN (diagnosis) → label + confidence
         → hitung affected_area_pct (HSV) → severity; hitung ExG/VARI (OpenCV) → health_score
         → lookup rule-based recommendation dari disease_reference
         → FastAPI SENDIRI insert diagnoses, vegetation_index_readings, recommendations (service role)
         → trigger DB upsert_zone_health_daily mengisi zone_health_daily
         → return JSON gabungan; frontend hanya menampilkan (TIDAK insert ulang)
Dashboard → query Supabase langsung (tren, status zona, histori) lewat RLS
```

## Kenapa Web ≠ App (Next.js vs Flutter), bukan port satu sama lain

Next.js (TypeScript/React) dan Flutter (Dart) adalah dua bahasa & framework berbeda total — tidak ada logic yang bisa di-share langsung antar keduanya. Ini keputusan sadar (user pede dengan waktu yang tersedia), bukan rekomendasi default. Konsekuensinya:

- Kontrak API (endpoint FastAPI) dan skema database (Supabase) adalah **satu-satunya sumber kebenaran bersama** — lihat `03-database-schema.md` dan `04-api-contract.md`. Keduanya HARUS diimplementasikan identik di web maupun app; jangan menyimpang.
- Pembagian peran: **web** = platform utama (dashboard lengkap, monitoring, histori — nyaman di layar besar, dipakai admin PPL). **app** = companion untuk upload cepat dari lapangan (kamera-first, dipakai petani).

## Environment Variables yang Dibutuhkan

**Web (Next.js) — `.env.local`:**
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
NEXT_PUBLIC_ML_API_URL=        # URL FastAPI di Railway
```

**App (Flutter) — melalui `--dart-define` atau file config:**
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
ML_API_URL=
```

**ML Service (FastAPI) — `.env` / Railway Variables:**
```
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=     # baca Storage + insert hasil; JANGAN ke klien
STORAGE_BUCKET=plant-photos
MODEL_DIR=models               # tomato_classifier.tflite, label_map.json
ALLOWED_ORIGINS=               # origin web, dipisah koma (jangan * di produksi)
```
(Daftar lengkap + cara pakai: `09-operasional-dan-runbook.md`.)

## Deployment (aktual)
- Web → Vercel (project `agrivision`, root `web`, auto-deploy dari `main`)
- Mobile App → build APK lokal (`flutter build apk --release`) lalu `adb install` ke HP; tidak dipublish ke Play Store/App Store
- ML Service → Railway (project `AgriVision`, root `ml-service`, auto-deploy dari `main`)
- Database → Supabase (managed, ap-southeast-1)

URL & ID konkret ada di `09-operasional-dan-runbook.md` bagian 1.
