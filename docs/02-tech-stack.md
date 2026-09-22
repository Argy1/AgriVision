# Tech Stack

## Ringkasan

| Layer | Teknologi | Alasan |
|---|---|---|
| Web | Next.js (React) + Tailwind CSS | SSR, deploy mudah ke Vercel, cocok untuk dashboard admin/PPL |
| Mobile App | Flutter (Dart) | Native feel, akses kamera matang (`image_picker`/`camera`), package resmi `supabase_flutter` |
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
Frontend → panggil FastAPI (Railway) dengan image_url
FastAPI  → download foto dari Supabase Storage
         → jalankan model CNN (diagnosis) → label + confidence + severity
         → hitung ExG/VARI (OpenCV) → health_score
         → lookup rule-based recommendation dari disease_reference
         → return JSON gabungan
Frontend → simpan hasil ke Supabase Postgres (diagnoses, vegetation_index_readings, recommendations)
         → render hasil ke user
Dashboard → query Supabase langsung (tren, status zona, histori)
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

**ML Service (FastAPI) — `.env`:**
```
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=     # untuk baca Storage dari backend
MODEL_PATH=./models/disease_classifier.tflite
```

## Deployment
- Web → Vercel
- Mobile App → build APK/IPA lokal untuk demo sidang (tidak perlu publish ke Play Store/App Store untuk scope tugas akhir)
- ML Service → Railway
- Database → Supabase (managed)
