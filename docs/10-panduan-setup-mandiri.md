# Panduan Setup Mandiri (mencoba AgriVision di komputer sendiri)

Untuk anggota kelompok atau siapa pun yang ingin menjalankan sendiri sistemnya, tanpa menyentuh data dan infrastruktur produksi milik Argy. Rujukan operasional produksi (deploy, pemulihan insiden) ada di [`09-operasional-dan-runbook.md`](09-operasional-dan-runbook.md); dataset dan notebook training ada di [`11-dataset-dan-notebook.md`](11-dataset-dan-notebook.md).

> **Jangan** memakai kunci atau project Supabase produksi (`ymfcrxymizwwolikgrhq`) untuk percobaan. Buat project Supabase sendiri (gratis, bagian 3). Data uji Anda tidak akan tercampur dengan data asli, dan service role key milik Argy tidak perlu dibagikan ke siapa pun.

## 1. Pilih jalur

| Tujuan | Jalur | Butuh |
|---|---|---|
| Hanya melihat sistemnya | Buka situs live: https://agrivision-blond-nine.vercel.app (daftar sendiri, akun otomatis "petani") | Browser |
| Hanya menguji model pada foto sendiri | `python scripts/predict_local.py` (bagian 2) | Python 3.11. **Tanpa akun apa pun** |
| Menjalankan seluruh sistem, termudah | Docker Compose (bagian 4) | Docker Desktop + project Supabase sendiri |
| Menjalankan seluruh sistem, untuk mengembangkan | Tanpa Docker (bagian 5) | Node 22, Python 3.11, + project Supabase sendiri |
| Aplikasi Android | Flutter (bagian 6) | Flutter SDK, HP/emulator Android |
| Melatih ulang model | Notebook Colab (`11-dataset-dan-notebook.md`) | Akun Google (GPU T4 gratis, terbatas kuota) |

Versi yang dipakai pengembang: Node 22 atau lebih baru (Next.js 16 mensyaratkan ≥ 20.9), **Python 3.11** (`ml-service/.python-version`; TensorFlow 2.17 belum punya wheel untuk Python 3.13 ke atas), Flutter 3.41 / Dart ≥ 3.11, Docker Desktop.

## 2. Hanya menguji model (tanpa Supabase)

```bash
cd ml-service
python -m venv .venv
.venv/Scripts/activate            # Windows. Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
python scripts/predict_local.py foto_daun.jpg
python scripts/predict_local.py folder_foto/            # semua .jpg/.jpeg/.png/.webp di dalamnya
python scripts/predict_local.py folder_foto/ --json     # satu objek JSON per baris
```

Keluaran per foto: label penyakit, keyakinan model, severity, luas terdampak (%), ExG/VARI, serta penolakan/peringatan kelayakan foto. Skrip ini menjalankan pipeline yang sama dengan `/api/diagnose` (`app/ml`, `app/cv`) tetapi tidak menyimpan apa pun dan tidak memberi rekomendasi (rekomendasi butuh tabel `disease_reference` di Supabase). Model yang dipakai: `ml-service/models/tomato_classifier.tflite` (model produksi v2).

Hanya daun **tomat**. Skrip juga menjalankan penyaring daun tomat (kolom `tomat …%`): foto di bawah ambang (0,45) dilaporkan DITOLAK; penyaring tidak sempurna (data uji: cabai 91,9% ditolak). Keyakinan penyakit < 30% ditolak, 30–60% diberi peringatan "model ragu" (lihat `04-api-contract.md`).

## 3. Menyiapkan project Supabase sendiri

Semua jalur "seluruh sistem" membutuhkan ini. Dilakukan sekali.

1. **Buat project** di https://supabase.com/dashboard (tier gratis cukup). Catat password database. Region bebas.
2. **Jalankan skema.** SQL Editor → New query → tempel seluruh isi [`database/schema.sql`](../database/schema.sql) → Run. Ini membuat semua tabel, trigger (`handle_new_user`, `prevent_profile_role_change`, `upsert_zone_health_daily`), kebijakan RLS, dan 10 baris `disease_reference` tomat. Pengerasan pendaftaran publik (migrasi 003) sudah termasuk di dalamnya; migrasi 004 tidak diperlukan pada instalasi baru.
3. **Buat bucket Storage dan kebijakannya.** SQL Editor → tempel isi [`database/migrations/005_storage_bucket_and_policies.sql`](../database/migrations/005_storage_bucket_and_policies.sql) → Run. (Bucket `plant-photos`, privat; user hanya boleh mengunggah ke folder `{uid}/`.)
4. **Atur Authentication.**
   - Authentication → Providers → Email: **Confirm email = OFF**. Bila ON, pendaftaran tidak langsung membuat sesi dan UI menampilkan pesan konfigurasi.
   - Authentication → URL Configuration: Site URL `http://localhost:3000`; Redirect URLs tambahkan `http://localhost:3000/**` (dipakai tautan reset password di web).
5. **Ambil kunci.** Project Settings → API: `Project URL`, `anon public` key, dan `service_role` key.
   - `service_role` **rahasia**: hanya untuk `ml-service`; jangan di web/app, jangan di-commit, jangan ditempel ke chat atau dokumen.
6. **Cek.** `select count(*) from disease_reference;` harus 10, dan `select id from storage.buckets;` memuat `plant-photos`.

Akun `admin_ppl` tidak bisa dibuat dari UI; untuk mencoba, jalankan di SQL Editor: `update public.profiles set role = 'admin_ppl' where id = '<uuid user>';` (UUID di Authentication → Users).

## 4. Docker Compose (web + ml-service)

Prasyarat: Docker Desktop berjalan, dan bagian 3 selesai.

```bash
cp .env.example .env            # Windows PowerShell: Copy-Item .env.example .env
# isi SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY di .env
docker compose up --build
```

Build pertama memakan waktu beberapa menit (TensorFlow dan `npm ci`). Setelah itu:

| Layanan | Alamat | Cek |
|---|---|---|
| ml-service | http://localhost:8000 | `http://localhost:8000/api/health` → `{"status":"ok","model_loaded":true,"model_version":"v8"}` |
| web | http://localhost:3000 | daftar akun → onboarding (buat zona) → Unggah foto |

Perintah berguna: `docker compose logs -f ml-service`, `docker compose down`, `docker compose up --build ml-service` (hanya backend, mis. untuk menguji app Flutter).

Catatan penting:
- `NEXT_PUBLIC_*` pada web di-inline saat build. Setelah mengubah `.env`, jalankan `docker compose up --build` lagi.
- `NEXT_PUBLIC_ML_API_URL` dipanggil dari **browser**, jadi bernilai `http://localhost:8000` (bukan nama service Docker).
- `ALLOWED_ORIGINS` (CORS ml-service) harus memuat alamat web persis (`http://localhost:3000`). Jika Anda membuka web dari alamat lain (mis. IP LAN), tambahkan di `.env`.
- Berkas Docker sengaja ada di `docker/` dan `docker-compose.yml`, bukan `ml-service/Dockerfile`, supaya **Railway dan Vercel tidak berubah perilaku**. Produksi tetap dibangun dari `Procfile` (Railway) dan build bawaan Next.js (Vercel).
- Docker hanya untuk web dan ml-service. Database/Auth/Storage tetap Supabase di cloud; aplikasi Flutter dijalankan terpisah (bagian 6).

## 5. Tanpa Docker

```bash
# --- ml-service (terminal 1) ---
cd ml-service
python -m venv .venv && .venv/Scripts/activate
pip install -r requirements-dev.txt
cp .env.example .env            # isi SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
                                # ALLOWED_ORIGINS=http://localhost:3000 (jangan "*" selain untuk uji lokal)
uvicorn app.main:app --port 8000

# --- web (terminal 2) ---
cd web
cp .env.example .env.local      # isi NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY,
                                # NEXT_PUBLIC_ML_API_URL=http://localhost:8000
npm install
npm run dev                     # http://localhost:3000
```

`ml-service/.env.example` dan `web/.env.example` berisi URL project Argy sebagai contoh; **ganti** dengan URL project Anda.

Tes:
```bash
cd ml-service && pytest tests/test_schemas.py tests/test_cv_quality.py tests/test_enhance.py   # offline, tanpa akun
cd ml-service && pytest tests/test_e2e_diagnose.py                                              # E2E: butuh .env asli (membuat lalu menghapus user uji)
cd web && npm run lint && npm run build
cd app && flutter analyze && flutter test
```

## 6. Aplikasi Flutter

```bash
cd app
flutter pub get
flutter run -d <device> \
  --dart-define=SUPABASE_URL=https://<project-anda>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon key> \
  --dart-define=ML_API_URL=<alamat ml-service>
```

Alamat `ML_API_URL` bergantung pada tempat app berjalan:

| App berjalan di | `ML_API_URL` |
|---|---|
| Emulator Android | `http://10.0.2.2:8000` |
| HP Android (satu Wi-Fi dengan komputer) | `http://<IP LAN komputer>:8000` (izinkan port 8000 di firewall Windows) |
| Flutter web (`run_web.bat`, http://localhost:8081) | `http://localhost:8000`, dan tambahkan `http://localhost:8081` ke `ALLOWED_ORIGINS` |

Build **debug** mengizinkan HTTP biasa (`app/android/app/src/debug/AndroidManifest.xml`); build **release** hanya HTTPS, jadi APK release harus memakai ml-service yang ber-HTTPS (mis. Railway sendiri).

Memasang APK release ke HP: lihat `09-operasional-dan-runbook.md` bagian 4 (di Windows jangan memakai `flutter run` di background; pakai `flutter build apk --release ...` lalu `adb install -r`). `app/run_web.bat` berisi URL dan anon key project **produksi** milik Argy; salin dan ganti nilainya bila ingin memakai project sendiri.

## 7. Masalah yang sering muncul

| Gejala | Penyebab / solusi |
|---|---|
| Web: "Failed to fetch" saat unggah, konsol berisi error CORS | alamat web belum ada di `ALLOWED_ORIGINS` ml-service |
| Setelah daftar muncul pesan konfigurasi / tidak masuk | "Confirm email" di Supabase masih ON |
| Unggah gagal 403 / "new row violates row-level security" | kebijakan Storage (`005_...sql`) belum dijalankan |
| `docker compose up`: ml-service berhenti dengan pesan "SUPABASE_URL / ... kosong" | `.env` belum diisi |
| `/api/diagnose` 500 "Gagal menyimpan hasil diagnosis" | skema belum lengkap, atau `SUPABASE_SERVICE_ROLE_KEY` salah (mis. tertukar dengan anon key) |
| Mengubah `.env` tetapi web masih memakai nilai lama | `NEXT_PUBLIC_*` di-inline saat build: `docker compose up --build` (atau restart `npm run dev`) |
| `pip install` gagal di TensorFlow | gunakan Python 3.11 (bukan 3.13/3.14) |
| Build Docker pertama lama / besar | image ml-service dan web masing-masing ±2 GB (TensorFlow-CPU, node_modules); setelah itu build ulang cepat karena lapisan di-cache. Healthcheck container baru "healthy" ±20-30 detik setelah start |
| Ditolak "Foto ini tidak dikenali sebagai daun tomat…" | penyaring v9.1; potong foto ke satu daun tomat (langkah potong di web/app) atau foto dari dekat |
| Ditolak "Model belum cukup yakin menentukan penyakit…" | keyakinan < 30%; foto satu daun dari dekat yang memenuhi layar |
| Foto cabai/tanaman lain kadang tetap lolos | penyaring tidak sempurna (data uji v9.1: cabai 91,9%, kentang 93,6% ditolak) |
| Flutter debug di emulator tidak bisa menghubungi `http://10.0.2.2:8000` | pastikan ml-service jalan di host dan app memakai build **debug** |

## 8. Yang tidak ada di repositori (dan alasannya)

- **Dataset mentah** (PlantVillage, PlantDoc, Tomato-Village): terlalu besar dan berlisensi masing-masing; notebook mengunduhnya sendiri. Lihat `11-dataset-dan-notebook.md`.
- **Foto lapangan milik Argy** (`Foto daun real/`) dan unduhan lokal (`Dataset lapangan/`): privasi dan belum berlabel; di-gitignore.
- **Naskah jurnal, PPT, catatan riset** (`Jurnal/`, `*.pptx`, `reports/`, `research_notes/`): memuat data pribadi; tidak di-commit.
- **Kunci/rahasia**: `ml-service/.env`, `web/.env.local`, `.env` di root, `kaggle.json`.
