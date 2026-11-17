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

**Fase 4 — foto lapangan nyata (2026-11-12):** folder `Foto daun real/` (lokal, tidak di-commit; berisi 5 foto cabai dan 4 foto tomat dari kebun, belum berlabel). Model v1 memberi early/late blight 87–98% pada foto tomat yang tampak hampir sehat, dan menebak foto cabai sebagai penyakit tomat. Perbaikan di ml-service (`leaf_region.py`, `photo_quality.py`, ExG minimum): lihat `05-ml-pipeline.md`. Foto yang kurang layak mendapat catatan di `recommendation.warning_note`; foto tanpa daun ditolak (400). Belum ada label ground truth untuk foto-foto itu.

**Fase 5 — arahan dosen 14 Nov 2026 (keputusan user 15 Nov):** naskah fokus klasifikasi/diagnosis tomat; istilah "monitoring/pemantauan kesehatan" dihapus dari judul dan pembahasan (opsi A: sistem tidak diubah, modul ExG/VARI tetap sebagai fitur pendukung). Kebaruan = ablasi pra-pemrosesan citra pada MobileNetV2 (lab→lapangan), dengan tabel dataset per kelas, skema split, metrik akurasi/P/R/F1, dan model summary. Tenggat LoA > 1 bulan. Data lapangan: PlantDoc + 4 foto tomat user (belum berlabel). Naskah/pptx: hapus "D4", tanda afiliasi berbeda untuk dosen pembimbing, alamat kampus (menunggu nama/afiliasi dari user).

**Dataset lapangan tambahan (2026-11-15, disimpan lokal di `Dataset lapangan/`, di-gitignore, tidak didistribusikan):**
- **Tomato-Village** (Gehlot, Saxena & Gandhi 2023, Multimedia Systems; github.com/mamta-joshi-gehlot/Tomato-Village, repo tanpa lisensi tertulis → hanya riset + sitasi): foto kebun asli (Rajasthan). Varian-a multiclass; hanya 3 kelas yang bisa dipetakan ke 10 kelas kita: Early_blight (496), Late_blight (904), Healthy (216) = 1.616 gambar. Dipakai **hanya sebagai uji eksternal** (`ml-service/agrivision_experiment_external_v3b.ipynb`), tidak untuk melatih.
- **Mendeley "Tomato Leaf Dataset"** (Imtiaz dkk. 2025, CC BY 4.0, doi 10.17632/bpfd9cns5g.2): 731 foto mentah + anotasi gaya YOLO (kotak per bercak). Zip tidak menyertakan `data.yaml`, jadi id kelas tidak bisa dipetakan dengan pasti dan satu foto sering memuat beberapa kelas → **belum dipakai**; perlu pemetaan kelas yang diverifikasi (mis. dari makalah/penulis atau pakar).

**Fase 6 — eksperimen lanjutan dan naskah v2 (2026-11-15):**
- **Hasil** (detail dan angka: `05-ml-pipeline.md`): (1) pra-pemrosesan (CLAHE, Shades-of-Gray, unsharp, penekanan latar) tidak menaikkan akurasi lapangan di atas variasi antarseed (v3); (2) uji eksternal Tomato-Village (v3b, parsial karena kuota GPU Colab habis): model fine-tuning 41,17 ± 4,66%, di bawah tebakan mayoritas 55,9%; (3) komposisi data latih (v5/v5b, **backbone beku** karena tanpa GPU, MobileNetV2 dan EfficientNetB0, 5 seed): data dari domain yang sama dengan set uji menaikkan akurasi sumbernya 15–23 poin (PlantDoc) dan 45–48 poin (Tomato-Village), data lapangan dari sumber lain tidak menolong dan dapat menurunkan akurasi; (4) SE, CBAM, MobileNetV3-Large, EfficientNetB0 menaikkan akurasi lab 2–5 poin tetapi tidak akurasi lapangan. Notebook v4 (`agrivision_experiment_v4_data_arch.ipynb`, fine-tuning penuh, ±24 model GPU) sudah ada tetapi **belum dijalankan** (kuota GPU habis); versi mini yang disarankan: MobileNetV2 × 4 komposisi × 3 seed.
- **Telaah literatur:** `reports/Telaah literatur penyakit daun tomat.md` (35 butir dengan status verifikasi; pencarian lewat web terbuka). Klaim kebaruan harus berkualifikasi "sejauh pencarian kami"; split per daun sudah dipakai Mohanty 2016; modul perhatian pada MobileNetV2 tomat sudah ramai.
- **Naskah:** `Jurnal/Naskah JATI AgriVision v2.docx` (dibuat dari naskah lama, yang asli tetap utuh; tidak di-commit karena memuat nomor WA). Dibingkai ulang sebagai studi evaluasi empiris tomat (bukan modul baru), tanpa cabai dan tanpa kata monitoring. Isian yang masih kosong, asal tiap angka, dan sitasi yang harus dicek manual: `Jurnal/Catatan revisi naskah v2.md`. PPT belum diubah.
- **Belum dikerjakan:** pilih/latih model produksi baru (butuh GPU + izin mengunduh berkas model), kalibrasi ambang confidence (tanpa mengubah kontrak API; peringatan confidence < 60% sudah ada di `warning_note`), foto lapangan berlabel, revisi PPT, pengisian nama/afiliasi pada naskah.

**Fase 7 — eksperimen arsitektur selesai dan model produksi v2 (2026-11-16):**
- v4b Part 2 (SE, CBAM, MobileNetV3-Large, EfficientNetB0 × 3 seed, fine-tuning, komposisi B) selesai; tidak ada arsitektur yang unggul konsisten di data lapangan, hanya akurasi lab yang naik (detail dan McNemar: `05-ml-pipeline.md`; mentah: `ml-service/results/v4b_results.csv`).
- Model produksi v2 = MobileNetV2 komposisi D (lab + PlantDoc + Tomato-Village), notebook `ml-service/agrivision_production_v6_tomato.ipynb`. Run 2026-11-16 (seed 42): val 91,3%, lab 95,8%, PlantDoc 51,4%, Tomato-Village test 94,0% (dalam-sumber), TFLite float16 4,5 MB, kesepakatan argmax dengan Keras ≥ 99,5%; `label_map.json` v2 lolos cek 10 label. **Berkas TFLite hilang** karena runtime Colab terputus sebelum diunduh (hanya `label_map.json` terunduh) dan kuota GPU kedua akun habis. Keputusan user: tunggu kuota reset lalu jalankan ulang notebook (kini 1 seed, hasil diunduh sebagai satu zip). **Produksi masih v1** sampai model v2 dipasang.

**Fase 8 — model produksi v2 dipasang (2026-11-17):**
- Kuota GPU pulih (akun authuser=0, T4). Notebook v6 dijalankan ulang (seed 42, run kedua): val 90,9%, lab 94,7%, PlantDoc 44,4%, Tomato-Village test 90,5%; berkas run pertama (16 Nov) ternyata ikut terunduh ke Downloads (TFLite 4,54 MB, metrik di `ml-service/results/metrics_v6_prod_v2.json`). Selisih antar-run = varian pelatihan (GPU nondeterministik, satu seed).
- **Dipasang di produksi: run pertama** (val 91,3% lebih tinggi; dipilih berdasar validasi, bukan set uji): lab 95,8%, PlantDoc 51,4%, Tomato-Village 94,0% (dalam-sumber, terinflasi), kesepakatan argmax dengan Keras ≥ 99,5%. `label_map.json` v2: 10 label urutan sama dengan v1. `pytest` 26 lulus.
- **Peringatan jujur:** 9 foto asli milik user tidak bisa menjadi tolok ukur. 5 foto (3 Nov) adalah tanaman **cabai** (di luar cakupan model; v1 sempat menjawab yellow_leaf_curl 90%), 4 foto (10 Nov) tomat lapangan berdaun hijau dengan lubang bekas hama tanpa bercak jelas; v1 menjawab early/late blight 87–98%, v2 menjawab leaf_mold dengan keyakinan lebih rendah. Tidak ada label sebenarnya, jadi tidak diketahui model mana yang lebih benar. Bukti berlabel satu-satunya: PlantDoc (v2 51% vs sekitar 22% untuk model hanya-lab pada protokol sama).
- **Temuan:** model tidak punya penolakan "bukan daun tomat"; foto cabai tetap mendapat label penyakit tomat. Perlu ambang confidence atau kelas "bukan tomat" (butuh persetujuan karena mengubah kontrak). Rollback v1: `git revert` commit pemasangan v2.
- **Penolakan keyakinan rendah (2026-11-17, disetujui user):** `/api/diagnose` kini menolak (400) bila keyakinan tertinggi < 50% (`REJECT_CONFIDENCE`, `ml-service/app/cv/photo_quality.py`); tanpa perubahan field kontrak (web/app sudah menampilkan `detail`). Uji pada 164 foto Tomato-Village (tak dipakai training): 0 tertolak, akurasi 93,3%. Pada 9 foto milik user: menolak sebagian kecil saja (foto cabai berkeyakinan tinggi, mis. 99%, tetap lolos). Jadi ini penolakan "tidak yakin", bukan detektor non-tomat. Solusi penuh = kelas ke-11 "bukan tomat" (butuh retraining, mengubah label_map dan `disease_reference`).
- **Naskah dan PPT direvisi ke hasil fine-tuning (2026-11-17, disetujui user):** `Jurnal/Naskah JATI AgriVision v2.docx` dan `AgriVision_Kelompok19_v2.pptx` (tidak di-commit) kini memakai fine-tuning untuk E1–E3 (Tabel 5: A 23,9 / B 53,9 / C 22,1 / D 49,4% di PlantDoc; Tomato-Village uji 31,0 / 34,8 / 97,4 / 89,4%; Tabel 6 arsitektur 3 seed; Gambar 3 baru). Klaim "sumber lain dapat merugikan" dihapus. Versi lama (backbone beku) diarsipkan dengan akhiran "(arsip, hasil backbone beku)". Sisa isian manual penulis tetap di `Jurnal/Catatan revisi naskah v2.md`.
