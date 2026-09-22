# Skema Database (Supabase Postgres)

SQL lengkap ada di `database/schema.sql` — jalankan itu dulu sebelum mulai coding (via Supabase SQL editor, `supabase db push`, atau tool `mcp__Supabase__apply_migration` jika tersedia di Claude Code).

## Entity Relationship (ringkas)

```
profiles (1) ──< zones (1) ──< uploads (1) ── (1) diagnoses ── (1) recommendations
                                    │
                                    └── (1) vegetation_index_readings

zones (1) ──< zone_health_daily   (snapshot harian, untuk grafik tren)
disease_reference                 (knowledge base, di-lookup oleh diagnoses.disease_label)
```

## Tabel

### `profiles`
Extends `auth.users` bawaan Supabase. Dibuat otomatis lewat trigger saat user daftar.
- `role`: `admin_ppl` | `petani` — menentukan scope akses (lihat RLS).

### `zones`
Satu row = satu petak/lahan yang dipantau (contoh: "A3 — Blok Tomat").
- `crop_type`: `tomat` | `cabai` — **wajib salah satu**, sesuai scope project.
- `owner_id`: pemilik zona (petani atau admin_ppl yang mengelola).

### `uploads`
Setiap foto yang diunggah, terikat ke satu zona.
- `image_path`: path relatif di Supabase Storage bucket `plant-photos`, bukan URL penuh (generate signed URL saat dibutuhkan).

### `diagnoses`
Hasil inferensi model CNN — **relasi 1:1 dengan `uploads`**. Diisi oleh FastAPI service, bukan langsung dari client.
- `disease_label`: key internal (snake_case, contoh `tomato_early_blight`) — harus cocok dengan key di `disease_reference` dan dengan label output model.
- `severity`: `ringan` | `sedang` | `parah` — mapping dari confidence + affected_area_pct (aturan mapping didefinisikan di ML service, lihat `05-ml-pipeline.md`).

### `vegetation_index_readings`
Hasil modul monitoring (ExG/VARI) — **relasi 1:1 dengan `uploads`**, dihitung paralel dengan diagnosis di request yang sama.
- `health_score`: dinormalisasi 0–100, dipakai untuk grafik tren di dashboard.

### `disease_reference`
Knowledge base rule-based (modul rekomendasi). **Satu-satunya sumber teks rekomendasi** — jangan hardcode teks rekomendasi di frontend maupun backend, selalu lookup dari tabel ini.
- `is_verified`: `false` = konten masih draft dari literatur umum, belum diverifikasi ke dosen pembimbing/sumber agronomi terpercaya (lihat `05-ml-pipeline.md` Modul 3). Ini kolom data, bukan tag di dalam `recommendation_text`/`warning_note` — kedua field itu tampil langsung ke end user di aplikasi, jadi tidak boleh berisi catatan internal tim dev.

### `recommendations`
Snapshot rekomendasi per diagnosis (disalin dari `disease_reference` pada saat diagnosis dibuat). Alasan disimpan sebagai snapshot, bukan selalu join live ke `disease_reference`: jika teks rekomendasi di knowledge base diperbarui nanti, histori diagnosis lama tetap menampilkan rekomendasi yang benar-benar diberikan saat itu.

### `zone_health_daily`
Snapshot agregat harian per zona (dihitung oleh scheduled job atau on-the-fly saat diagnosis baru masuk) — sumber data untuk grafik tren dashboard "30 hari terakhir" dan status warna zona (hijau/kuning/merah).

## Row Level Security (RLS)

Prinsip: **petani hanya melihat data zona miliknya sendiri; `admin_ppl` melihat semua zona.** Semua tabel turunan (`uploads`, `diagnoses`, `vegetation_index_readings`, `recommendations`, `zone_health_daily`) mewarisi akses lewat relasi ke `zones.owner_id`.

**Penting:** insert ke `diagnoses`, `vegetation_index_readings`, `recommendations`, dan `zone_health_daily` dilakukan oleh FastAPI service memakai `SUPABASE_SERVICE_ROLE_KEY` (bypass RLS by design) — bukan langsung dari client. Ini mencegah hasil inferensi dipalsukan dari sisi frontend.

## Storage

Bucket `plant-photos`, **private** (bukan public). Upload lewat client SDK, path harus diawali `{user_id}/...` supaya RLS Storage bisa membatasi user hanya bisa upload ke folder miliknya sendiri. Baca foto lewat signed URL (berlaku sementara), baik dari frontend maupun dari FastAPI service.
