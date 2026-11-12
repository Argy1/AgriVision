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
Extends `auth.users` bawaan Supabase. Dibuat otomatis lewat trigger `handle_new_user()` saat user daftar (publik).
- `role`: `admin_ppl` | `petani` — menentukan scope akses (lihat RLS). **Pendaftaran selalu menghasilkan `petani`** (hardcode di trigger; metadata klien diabaikan). `full_name` dibatasi 1–100 karakter.
- Trigger `prevent_profile_role_change` menolak perubahan `role` dari request klien (`auth.uid()` terisi). Menaikkan ke `admin_ppl` hanya lewat SQL Editor/service role. Alasan: policy `profiles_update_own` tidak membatasi kolom, sehingga tanpa trigger ini siapa pun bisa menjadikan dirinya admin dan melihat data semua orang.

### `zones`
Satu row = satu petak/lahan yang dipantau (contoh: "A3 — Blok Tomat").
- `crop_type`: enum Postgres `tomat` | `cabai`, tetapi **hanya `tomat` yang dipakai** (proyek fokus ke tomat; `cabai` dibiarkan sebagai nilai mati karena enum tidak bisa di-drop dengan rapi). Klien selalu mengisi `tomat`. Data cabai lama dihapus lewat `database/migrations/004_remove_chili_data.sql` / `ml-service/scripts/purge_chili_data.py`.
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
Snapshot agregat harian per zona — sumber data untuk grafik tren dashboard dan status warna zona (sehat/waspada/perlu_tindakan). **Diisi on-the-fly oleh trigger `upsert_zone_health_daily`** (AFTER INSERT pada `vegetation_index_readings`, SECURITY DEFINER; fungsi tidak bisa dipanggil via RPC). Isi: rata-rata `health_score` hari itu + status dari severity terburuk hari itu (parah→perlu_tindakan, sedang→waspada, lainnya→sehat). "Hari" = kalender **Asia/Jakarta**. Trigger mengandalkan baris `diagnoses` sudah ada saat `vegetation_index_readings` di-insert (urutan di `ml-service/app/routers/diagnose.py`).

## Row Level Security (RLS)

Prinsip: **petani hanya melihat data zona miliknya sendiri; `admin_ppl` melihat semua zona.** Semua tabel turunan (`uploads`, `diagnoses`, `vegetation_index_readings`, `recommendations`, `zone_health_daily`) mewarisi akses lewat relasi ke `zones.owner_id`.

**Penting:** insert ke `diagnoses`, `vegetation_index_readings`, `recommendations`, dan `zone_health_daily` dilakukan oleh FastAPI service memakai `SUPABASE_SERVICE_ROLE_KEY` (bypass RLS by design) — bukan langsung dari client. Ini mencegah hasil inferensi dipalsukan dari sisi frontend.

## Migrasi
`database/schema.sql` adalah sumber kebenaran dan harus selalu sama dengan produksi. Perubahan tambahan dijalankan manual lewat `database/migrations/` lalu disalin ke `schema.sql`. Saat ini: `003_public_signup_hardening.sql` (trigger blokir ubah role, `handle_new_user` aman, constraint panjang nama). Perubahan historis (policy `uploads_insert` yang memverifikasi zona milik pengunggah, trigger `zone_health_daily`) sudah tergabung di `schema.sql`.

## Storage

Bucket `plant-photos`, **private** (bukan public). Upload lewat client SDK, path harus diawali `{user_id}/...` supaya RLS Storage bisa membatasi user hanya bisa upload ke folder miliknya sendiri. Baca foto lewat signed URL (berlaku sementara), baik dari frontend maupun dari FastAPI service.
