# Status & Progres Proyek (sumber kebenaran "sudah sampai mana")

> Terakhir diperbarui: **2026-10-24**. Dokumen ini dibuat agar siapa pun (Claude Code, Claude Cowork, atau manusia) yang membuka proyek dengan konteks kosong bisa langsung paham: apa yang sudah jadi, bagaimana cara kerjanya, apa yang belum, dan keputusan apa yang sudah diambil. Perbarui dokumen ini setiap ada perubahan besar.

## 1. Ringkasan satu paragraf

AgriVision adalah sistem computer vision untuk diagnosis penyakit & pemantauan kesehatan tanaman **tomat** (cabai dihapus 2026-11-12, lihat bagian 5 dan 10). Pengguna memotret daun → foto diunggah ke Supabase Storage → FastAPI (Railway) menjalankan model CNN (diagnosis), menghitung ExG/VARI (kesehatan), dan mencari rekomendasi di tabel `disease_reference` → hasil disimpan di Postgres dan ditampilkan di **web (Next.js)** dan **app (Flutter)**. Semua komponen sudah dibangun, di-deploy, dan diuji end-to-end. Yang tersisa terutama **evaluasi dengan foto lapangan nyata, verifikasi konten rekomendasi, dan penulisan laporan** (pekerjaan user).

## 2. Inventaris sistem (apa yang ada & di mana)

| Komponen | Teknologi | Lokasi | Deploy |
|---|---|---|---|
| Database/Auth/Storage | Supabase Postgres 17 | project ref `ymfcrxymizwwolikgrhq`, bucket privat `plant-photos` | Supabase (ap-southeast-1) |
| ML service | FastAPI + TensorFlow-CPU (TFLite) + OpenCV | `ml-service/` | Railway, project `AgriVision`, service `AgriVision`, domain `agrivision-production.up.railway.app` |
| Web | Next.js 16, React, Tailwind v4, Supabase SSR, Recharts, zod, react-hook-form, Radix Dialog | `web/` | Vercel project `agrivision` (team `argy-fawwazs-projects`), domain `agrivision-blond-nine.vercel.app` |
| Mobile app | Flutter 3.41 / Dart 3.11, Riverpod 3 (tanpa codegen), go_router, supabase_flutter, dio, fl_chart, image_picker, google_fonts | `app/` | APK release di-sideload ke HP via `adb` |
| Model | MobileNetV2 (tomat, 10 kelas, 224px), TFLite (model cabai EfficientNetB4 dihapus) | `ml-service/models/` | ikut ter-deploy bersama ml-service |
| Notebook training | Google Colab | `ml-service/agrivision_training.ipynb` | — |
| Desain | token + 8 mockup | `design/` | — |

Repo GitHub: `Argy1/AgriVision` (branch `main`, monorepo). Vercel & Railway melakukan auto-deploy dari push ke `main`.

## 3. Cara kerja end-to-end (alur nyata, bukan rencana)

1. Klien (web/app) mengunggah foto ke Storage: path `{user_id}/{zone_id}/{timestamp}.{ext}`.
2. Klien insert baris `uploads` (RLS: `uploaded_by = auth.uid()` DAN zona milik user).
3. Klien cek apakah `diagnoses` untuk `upload_id` itu sudah ada (idempotensi; kolom UNIQUE).
4. Klien `POST {ML_API}/api/diagnose` dengan `Authorization: Bearer <access_token user>`.
5. FastAPI memvalidasi token ke Supabase, memastikan user pemilik zona (atau admin_ppl), mengunduh foto (service role), menjalankan model sesuai `crop_type`, menghitung `affected_area_pct` (segmentasi HSV), `severity` (aturan: <15% ringan, <40% sedang, selain itu parah), ExG/VARI → `health_score`, lookup rekomendasi.
6. FastAPI insert `diagnoses` → `vegetation_index_readings` → `recommendations` (service role). Trigger DB `upsert_zone_health_daily` mengisi `zone_health_daily`.
7. Klien menampilkan hasil; dashboard/monitoring/zona/analitik membaca langsung dari Postgres (RLS).

Detail kontrak: `docs/04-api-contract.md`. Skema: `docs/03-database-schema.md` + `database/schema.sql`.

## 4. Fitur per platform

**Web (13 route):** login, register (publik), onboarding zona pertama, forgot/reset-password, upload (dropzone dengan retry idempoten), hasil diagnosis (ilustrasi daun SVG yang skalanya mengikuti `affected_area_pct`, severity meter, rekomendasi, konteks histori zona), dashboard (KPI, tren 30 hari, status zona, aktivitas), monitoring (tren multi-zona 7/30/90 hari + ranking kesehatan), detail zona (tren penuh, frekuensi penyakit, histori), analitik (frekuensi penyakit, tren severity mingguan, rata-rata confidence), riwayat (filter + paginasi), pengaturan (profil, kata sandi, kelola zona, keluar).

**App (13 route):** login, daftar, mulai (zona pertama), lupa-password + verifikasi kode OTP, beranda (KPI, sparkline, status zona), unggah (kamera-first, retry per-langkah, auto-resume saat koneksi kembali), hasil diagnosis (setara web), riwayat (filter + infinite scroll), detail zona, panduan penyakit (10 entri tomat dari `disease_reference`), notifikasi (dihitung saat layar dibuka dari zona `perlu_tindakan` + diagnosis `parah` 7 hari), profil (profil, kata sandi, tambah zona, keluar).

## 5. Keputusan penting yang sudah diambil (jangan dibalik tanpa tanya user)

| Keputusan | Alasan |
|---|---|
| **Hanya tomat** (cabai dihapus 2026-11-12), 3 modul | arahan pembimbing: fokus deteksi daun tomat; kedalaman evaluasi lebih penting. **Jangan mengembalikan cabai tanpa tanya user** |
| `crop_type` tetap ada di API/DB, selalu `tomat`; enum Postgres tetap memuat `cabai` (tak dipakai) | menjaga kontrak API stabil; enum tidak bisa di-drop dengan rapi |
| Inference di Railway, bukan Supabase Edge | Deno tidak bisa menjalankan TF/ONNX |
| Perluasan layar di atas mockup (web 13, app 13) | user minta kedua modul ML dimanfaatkan maksimal |
| Registrasi publik, role selalu `petani`, PPL dinaikkan manual | user ingin dipakai banyak orang; mencegah eskalasi hak akses |
| **Tanpa verifikasi email** | keputusan user (kesederhanaan). Konsekuensi: salah ketik email = tidak bisa pakai "lupa kata sandi"; "Confirm email" harus OFF |
| Reset password app = OTP 6 digit | menghindari konfigurasi deep link Android/iOS |
| Riverpod tanpa codegen | `riverpod_generator` bentrok dengan pin `meta` Flutter SDK |
| Notifikasi in-app (dihitung saat dibuka), bukan push | tanpa infra FCM; cukup untuk TA |
| Tanpa antrean upload offline penuh | terlalu besar untuk TA; yang ada: retry per-langkah + auto-resume saat online |
| Zona tidak bisa dihapus/diedit (selain nama di web) | menjaga histori diagnosis utuh (tidak ada policy DELETE) |
| Warna severity Moss/Ochre/Rust dicadangkan | konsistensi makna di seluruh UI |

## 6. Riwayat kronologis ringkas

- **2026-09 (awal):** perencanaan, dokumen 01–07, mockup, `schema.sql`.
- **2026-09-21/22:** project Supabase dibuat (org "Kuliah"), skema + seed 16 baris `disease_reference`; perbaikan RLS (rekursi tak hingga `42P17` → fungsi `current_user_role()`), pengerasan fungsi (`search_path`, revoke).
- **2026-09-22/23:** model dilatih di Colab & diekspor TFLite; ml-service dibangun, diuji (bug nyata: lazy import TF, VARI meledak, mask lesi, ambang HSV), di-deploy ke Railway.
- **2026-09-22:** web Next.js dibangun (13 route), trigger `zone_health_daily` + perbaikan RLS `uploads_insert` (migrasi 002), bug zona waktu (UTC vs Jakarta), deploy ke Vercel, Supabase Auth URL diatur.
- **2026-09-22/23:** app Flutter dibangun (13 route), diverifikasi di browser pane terhadap backend nyata.
- **2026-09-24:** APK dipasang ke HP Samsung; `schema.sql` disinkronkan dengan produksi.
- **2026-10-23:** insiden — service Railway terhapus tidak sengaja & project Supabase sempat tidak merespons (pause). Supabase dipulihkan user; service Railway dibuat ulang (URL baru `agrivision-production.up.railway.app`), diuji E2E tomat & cabai (cabai kemudian dihapus dari sistem).
- **2026-10-23/24:** registrasi publik web + app, migrasi 003 (blokir ubah role dari client, batasi panjang nama), pembersihan cache per-akun di app, APK dibangun ulang dengan URL baru dan dipasang ke HP.

## 7. Bukti verifikasi yang sudah dilakukan

- ml-service: `/api/health` → `{"status":"ok","model_loaded":true}`; E2E `/api/diagnose` (saat itu tomat & cabai; kini tomat saja) lewat URL produksi (status 200, header CORS cocok domain Vercel, trigger mengisi `zone_health_daily`).
- Isolasi RLS: dua akun berbeda tidak bisa melihat data satu sama lain (404 di web).
- Registrasi: signUp langsung mengembalikan sesi; role selalu `petani` walau metadata berisi `admin_ppl`; `PATCH profiles role` ditolak 403; nama dipotong 100 karakter; email duplikat ditolak.
- Web: `npm run lint` + `npm run build` lulus; alur daftar → onboarding → upload diuji di browser.
- App: `flutter analyze` (hanya 3 info lint), `flutter test` 20 tes lulus; alur daftar → mulai → unggah diuji di Flutter web; APK release terpasang di HP.
- **Tidak bisa diuji otomatis di lingkungan pengembangan:** pemilih file/kamera native (butuh perangkat/emulator nyata). Upload dengan foto sungguhan dari HP belum diuji oleh Claude — sebaiknya user mencobanya.

## 8. Yang BELUM selesai / perlu diperhatikan

**Pekerjaan user (tidak bisa dibuat Claude):**
1. **Uji foto lapangan nyata** (roadmap minggu 13). Semua uji Claude memakai gambar sintetis.
2. **Evaluasi akurasi lab vs lapangan** (minggu 14): akurasi/precision/recall/F1 dilaporkan terpisah (lab = PlantVillage held-out; lapangan = PlantDoc atau foto sendiri) + diskusi gap. Baru ada confusion matrix lab di `ml-service/evaluation/`. *Claude bisa membuatkan skrip evaluasi satu-perintah jika diminta.*
3. **Penulisan laporan** (bab hasil & pembahasan).
4. **Verifikasi isi rekomendasi:** hanya 2 dari 10 baris tomat `disease_reference` berstatus `is_verified=true`. Dosis pestisida tampil langsung ke petani → verifikasi ke dosen pembimbing/sumber agronomi sebelum demo/laporan.
5. **Rotasi service role key** Supabase (pernah ditempel di chat), lalu perbarui `ml-service/.env` + variable Railway.
6. **Set `NEXT_PUBLIC_ML_API_URL` di Vercel** ke URL Railway terbaru dan redeploy (jika belum).

**Keterbatasan teknis yang diketahui:**
- `health_score`: rentang ExG (`_EXG_MIN=-0.2`, `_EXG_MAX=0.6` di `ml-service/app/cv/vegetation_index.py`) masih **placeholder** — perlu dikalibrasi dengan foto sehat vs sakit nyata (roadmap minggu 5). Foto sintetis hijau murni menghasilkan 100.
- `affected_area_pct` berbasis ambang warna HSV; pada daun sehat yang berbayang/berwarna tidak merata nilainya bisa > 0 sehingga `severity` tidak nol walau diagnosis "Sehat". Validasi dengan foto nyata; pertimbangkan memaksa severity `ringan`/`0%` bila label `*_healthy` dengan confidence tinggi.
- Model tomat hanya dievaluasi pada foto lab; set validasi kemungkinan bocor (augmentasi offline sebelum split) dan dipakai juga untuk early stopping → 94,33% adalah batas atas. Training ulang v2 dengan data non-lab + set uji lapangan dijadwalkan (lihat bagian 10).
- Tanpa verifikasi email & tanpa CAPTCHA: rawan akun spam. Mitigasi cadangan: rate limit Supabase, Cloudflare Turnstile, atau menyalakan lagi Confirm email + SMTP sendiri (email bawaan Supabase hanya beberapa email/jam).
- iOS belum pernah dibangun/diuji (tidak ada Mac).
- Cakupan tes otomatis tipis (unit test fungsi murni di app; 1 tes E2E ml-service). Tidak ada tes integrasi web.
- Belum ada admin UI untuk menaikkan akun menjadi `admin_ppl` (manual via SQL: `update profiles set role='admin_ppl' where id='<uuid>'` di SQL Editor).
- Fitur ditunda sengaja: antrean upload offline penuh, push notification (FCM), custom domain Vercel.

**Housekeeping:**
- Lint info di app: `use_null_aware_elements` (auth_repository), `anonKey` deprecated (main.dart) — kosmetik.
- Peringatan LF/CRLF saat `git add` di Windows tidak berbahaya.

## 9. Langkah berikutnya yang disarankan (urutan)

1. User mencoba app di HP dengan foto daun asli (daftar → zona → foto → hasil) dan mencatat bug.
2. Kumpulkan foto lapangan berlabel → jalankan evaluasi lab vs lapangan → simpan angka & confusion matrix.
3. Verifikasi `disease_reference` dengan pembimbing → set `is_verified=true`.
4. Kalibrasi `health_score` dengan foto sehat vs sakit nyata.
5. Tulis laporan; ambil screenshot dari web & app (bisa dibuat Claude via browser pane).
6. Opsional: skrip evaluasi, tes integrasi, CAPTCHA, custom domain.

## 10. Perubahan scope: fokus tomat saja (2026-11-12)

Arahan pembimbing: fitur deteksi cabai dihapus, fokus ke daun tomat. Keputusan user: hapus UI + kode + model cabai (skema DB/enum tetap); data cabai di produksi dihapus; training ulang model tomat dengan dataset tambahan (hanya dataset publik, tanpa foto lapangan milik sendiri); naskah jurnal dan pptx direvisi setelah training.

**Fase 1 — pembersihan cabai (selesai di kode):**
- ml-service: `crop_type` hanya `Literal["tomat"]` (selain itu 422), model/label cabai dihapus (`chili_classifier.tflite`, kunci `chili` di `label_map.json`, `confusion_matrix_cabai.png`), tes offline `tests/test_schemas.py`.
- Web: pemilih jenis tanaman dihapus (form onboarding & modal zona), filter tanaman di Analitik/Riwayat dihapus, label zona hanya nama; insert zona selalu `crop_type = 'tomat'` (`ZONE_CROP_TYPE` di `web/lib/validation/zone.ts`).
- App: `CropType` hanya `tomat` dengan `fromJson` toleran; pemilih tanaman, chip filter tanaman, dan tab Panduan Penyakit cabai dihapus; Panduan hanya menampilkan label `tomato_*`.
- DB: seed `disease_reference` cabai dihapus dari `schema.sql`; `migrations/004_remove_chili_data.sql` dan `ml-service/scripts/purge_chili_data.py` (dry-run default; `--execute` menghapus Storage + zona + referensi cabai). Pra-cek produksi (2026-11-12): 0 zona cabai, 0 upload, 0 diagnosis, 6 baris `disease_reference` cabai. **Purge dijalankan 2026-11-12** (`--execute`): 6 baris `disease_reference` cabai dihapus; pasca-cek 0 zona cabai, `disease_reference` = 10 baris.

**Fase 2 — training ulang tomat v2:** notebook `ml-service/agrivision_training_tomato_v2.ipynb` sudah dibuat (split per daun, PlantVillage + PlantDoc, uji lab dan lapangan terpisah); **sudah dijalankan di Colab (T4) pada 2026-11-12**. Hasil: field_test (PlantDoc, n=216) v1 = 25,93% → v2 (EfficientNetB0) = 45,37%; lab_test v1 94,45% (tidak bersih) vs v2 85,90%. v2 belum di-deploy: akurasi lapangan masih rendah dan v2 kemungkinan under-trained; keputusan deploy/iterasi berikutnya ada di user. Detail dan caveat: `05-ml-pipeline.md`. **Fase 3 — revisi naskah & pptx:** setelah Fase 2.
