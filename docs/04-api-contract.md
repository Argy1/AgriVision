# API Contract — FastAPI (ML Service di Railway)

Ini adalah **satu-satunya kontrak** antara backend ML dan kedua frontend (web & app). Implementasikan identik di kedua sisi klien — jangan menyimpang formatnya.

Base URL: `NEXT_PUBLIC_ML_API_URL` (web) / `ML_API_URL` (app). Produksi saat ini: `https://agrivision-production.up.railway.app` (berubah jika service Railway dibuat ulang — lihat runbook). Kontrak ini sudah **terimplementasi dan teruji** di `ml-service/app/schemas.py`, `web/lib/ml-service/client.ts`, dan `app/lib/data/sources/ml_service_client.dart`.

## Autentikasi
Request dari frontend ke FastAPI menyertakan header:
```
Authorization: Bearer <supabase_access_token>
```
FastAPI memvalidasi token ini ke Supabase Auth sebelum memproses (pastikan user yang request adalah pemilik zona terkait, atau `admin_ppl`).

## `POST /api/diagnose`

Dipanggil setelah foto berhasil diunggah ke Supabase Storage dan record `uploads` dibuat di Postgres.

**Request body:**
```json
{
  "upload_id": "uuid-dari-tabel-uploads",
  "image_path": "user_id/zone_id/1695365520.jpg",
  "crop_type": "tomat"
}
```

**Proses internal (urutan wajib):**
1. Ambil foto dari Supabase Storage via `image_path` (signed URL internal, pakai service role key).
2. Preprocess gambar (resize sesuai input model, normalisasi).
3. Jalankan model CNN tomat (`crop_type` selalu `tomat` — lihat `05-ml-pipeline.md`) → `disease_label`, `confidence`.
4. Hitung `affected_area_pct` (segmentasi area bercak/lesi terhadap total area daun).
5. Mapping `confidence` + `affected_area_pct` → `severity` (`ringan`/`sedang`/`parah`) — aturan mapping di `05-ml-pipeline.md`.
6. Hitung ExG & VARI dari gambar yang sama (OpenCV) → `health_score` (0–100).
7. Lookup `disease_reference` berdasarkan `disease_label` → teks rekomendasi.
8. Simpan hasil ke `diagnoses`, `vegetation_index_readings`, `recommendations` (pakai service role key, bypass RLS).
9. Return response gabungan ke frontend.

**Response body (200 OK):**
```json
{
  "diagnosis": {
    "id": "uuid",
    "disease_label": "tomato_early_blight",
    "disease_name": "Early Blight (Bercak Daun Awal)",
    "confidence": 0.92,
    "severity": "sedang",
    "affected_area_pct": 35.0
  },
  "vegetation_index": {
    "exg_score": 0.42,
    "vari_score": 0.31,
    "health_score": 68.5
  },
  "recommendation": {
    "recommendation_text": "Gunakan fungisida berbahan aktif klorotalonil...",
    "dosage": "2 g/L air",
    "application_schedule": "Semprotkan setiap 7-10 hari hingga gejala mereda",
    "warning_note": "Menyebar cepat pada kondisi lembap — segera pantau zona sekitar."
  }
}
```

**Error responses:**
- `400` — `image_path` tidak ditemukan di Storage, `upload_id` tidak ditemukan, file bukan gambar valid, atau **foto tidak memuat daun yang dapat dikenali** (wilayah daun < 3% foto; `detail` berisi saran mengambil foto satu daun dari dekat).
- `422` — body tidak valid, termasuk `crop_type` selain `tomat` (divalidasi sebagai `Literal["tomat"]`).
- `401` — token tidak valid/kedaluwarsa.
- `403` — user bukan pemilik zona terkait dan bukan `admin_ppl`.
- `500` — model gagal memuat / inference error (log detail di server, jangan expose stack trace ke client).

## `GET /api/health`

Health check untuk Railway (dipanggil otomatis oleh platform, bukan oleh frontend).

**Response:**
```json
{ "status": "ok", "model_loaded": true, "model_version": "v1" }
```

## Catatan Implementasi
- **Idempotensi:** `diagnoses.upload_id` UNIQUE. Memanggil endpoint ini dua kali untuk `upload_id` yang sama menghasilkan `500`. Klien WAJIB mengecek `diagnoses` by `upload_id` sebelum memanggil/mengulang.
- **CORS:** hanya origin di `ALLOWED_ORIGINS` yang diizinkan (aplikasi mobile native tidak terkena CORS).
- **Error body:** `{"detail": "pesan"}` (FastAPI `HTTPException`).
- **Penulisan DB dilakukan oleh FastAPI**; klien tidak meng-insert `diagnoses`/`vegetation_index_readings`/`recommendations`.
- Endpoint ini **tidak** menerima file upload langsung — foto sudah ada di Supabase Storage sebelum endpoint ini dipanggil (alur: upload ke Storage dulu dari client → baru panggil `/api/diagnose` dengan referensinya). Ini menghindari FastAPI menjadi bottleneck untuk transfer file besar.
- Response harus selalu berisi ketiga bagian (`diagnosis`, `vegetation_index`, `recommendation`) dalam satu request — sesuai keputusan "satu kali unggah foto = diagnosis + monitoring + rekomendasi sekaligus", bukan tiga endpoint terpisah.
- `disease_label` yang dikembalikan model **harus** match persis dengan key di tabel `disease_reference` — jaga konsistensi penamaan antara training label, kode inference, dan seed data SQL.

**Catatan kualitas foto (sejak 2026-11-12):** bila foto kurang layak untuk diagnosis, ml-service menambahkan kalimat "Perhatian kualitas foto: …" ke **`recommendation.warning_note`** (digabung dengan `warning_note` dari `disease_reference`, dipisah ` | `) dan ikut tersimpan di tabel `recommendations`. Tidak ada field baru; web dan app menampilkannya lewat kartu rekomendasi yang sudah ada. Penyebabnya: foto dipenuhi dedaunan/latar ramai (bukan close-up satu daun), ≥ 8% foto berupa objek non-daun (tangan, ajir, buah), daun terlalu kecil, atau keyakinan model < 60%.
