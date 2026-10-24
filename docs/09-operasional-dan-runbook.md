# Operasional & Runbook

Panduan praktis: menjalankan lokal, men-deploy, memulihkan insiden, dan menguji. Tidak ada nilai rahasia di dokumen ini — kunci disimpan di `ml-service/.env` (gitignored), dashboard Vercel/Railway/Supabase.

## 1. Identitas & lokasi (bukan rahasia)

| Hal | Nilai |
|---|---|
| GitHub | `Argy1/AgriVision`, branch `main` |
| Supabase project ref | `ymfcrxymizwwolikgrhq` → `https://ymfcrxymizwwolikgrhq.supabase.co` (dashboard: supabase.com/dashboard/project/ymfcrxymizwwolikgrhq) |
| Storage bucket | `plant-photos` (private) |
| Railway | project `AgriVision` (`bf0dcdcf-f699-4cf1-a9f2-a18a5011ab72`), env `production`, service `AgriVision`, domain `https://agrivision-production.up.railway.app` |
| Vercel | project `agrivision`, team `argy-fawwazs-projects`, root dir `web`, domain utama `https://agrivision-blond-nine.vercel.app` (+ alias `agrivision-argy-fawwazs-projects.vercel.app`, `agrivision-git-main-argy-fawwazs-projects.vercel.app`) |
| Android package | `com.agrivision.agrivision_app` |

## 2. Environment variable

**ml-service (Railway Variables / `ml-service/.env`)**
| Nama | Isi |
|---|---|
| `SUPABASE_URL` | URL project Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | service_role key — RAHASIA, hanya di sini |
| `SUPABASE_ANON_KEY` | hanya untuk `tests/test_e2e_diagnose.py` (tidak perlu di Railway) |
| `STORAGE_BUCKET` | `plant-photos` |
| `MODEL_DIR` | `models` |
| `ALLOWED_ORIGINS` | origin yang boleh memanggil API, dipisah koma — isi domain Vercel di atas (jangan `*` di produksi) |

**Web (Vercel Environment Variables / `web/.env.local`)** — semua `NEXT_PUBLIC_*` (di-inline saat build → perlu redeploy setelah diubah):
`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_ML_API_URL`.

**App (Flutter, `--dart-define` saat run/build):** `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `ML_API_URL` (dibaca di `app/lib/core/config/env.dart`).

## 3. Menjalankan lokal

```bash
# Web
cd web && npm install && npm run dev            # http://localhost:3000  (butuh web/.env.local)
npm run lint && npm run build                   # verifikasi sebelum push

# ML service
cd ml-service && python -m venv .venv && .venv/Scripts/activate   # (Windows)
pip install -r requirements-dev.txt
uvicorn app.main:app --port 8000                # butuh ml-service/.env
pytest                                          # E2E: membuat user/zona sementara lalu membersihkan

# App
cd app && flutter pub get
flutter run -d <device> --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=ML_API_URL=...
flutter analyze && flutter test
# Flutter web untuk preview cepat: app/run_web.bat  (http://localhost:8081)
```

## 4. Deploy

- **Web:** push ke `main` → Vercel build otomatis (root `web`). Ubah env → redeploy.
- **ML service:** push ke `main` → Railway build otomatis (root `ml-service`, `Procfile` menjalankan uvicorn, Python 3.11 dari `.python-version`, healthcheck `/api/health`). Build pertama ±3 menit (TensorFlow).
- **App ke HP (Android):**
  ```bash
  cd app
  flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=ML_API_URL=https://agrivision-production.up.railway.app
  "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" install -r build\app\outputs\flutter-apk\app-release.apk
  ```
  Jangan memakai `flutter run` di background pada Windows (output tidak ter-flush dan proses tampak menggantung). Aktifkan USB debugging di HP; di Samsung gunakan `pm list packages --user 0` untuk memeriksa paket.
- **Database:** perubahan skema → tulis SQL di `database/migrations/NNN_*.sql`, jalankan di Supabase SQL Editor (atau MCP `apply_migration` bila konektor menunjuk project yang benar), lalu **salin perubahan ke `database/schema.sql`** supaya tetap menjadi sumber kebenaran.

## 5. Pengaturan Supabase Dashboard yang WAJIB benar

- Authentication → Providers → Email: **Confirm email = OFF**; password minimum length = 8.
- Authentication → URL Configuration: Site URL = `https://agrivision-blond-nine.vercel.app`; Redirect URLs berisi `https://agrivision-blond-nine.vercel.app/**` (dipakai reset password web).
- Authentication → Rate Limits: cek batas sign-up per jam/IP.
- Storage: bucket `plant-photos` private; policy upload mensyaratkan path diawali `{auth.uid()}/`.

## 6. Menaikkan akun jadi admin_ppl

Tidak ada UI. Di Supabase SQL Editor (service-level, tidak terkena trigger blokir role):
```sql
update public.profiles set role = 'admin_ppl' where id = '<uuid user>';
```
(UUID dilihat di Authentication → Users.) Menjalankan `update` role dari client/JWT user akan ditolak (403) oleh trigger `prevent_profile_role_change`.

## 7. Pemulihan insiden (pernah terjadi)

**Service Railway terhapus / "Application not found" pada URL Railway**
1. Buat service baru dari repo `Argy1/AgriVision` branch `main` di project `AgriVision`.
2. Settings: **Root Directory `ml-service`**, healthcheck path `/api/health` (timeout 300 dtk).
3. Set variable: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `STORAGE_BUCKET=plant-photos`, `MODEL_DIR=models`, `ALLOWED_ORIGINS=<domain Vercel, koma>`.
4. Generate domain Railway. **URL baru** → perbarui `NEXT_PUBLIC_ML_API_URL` di Vercel (redeploy), `ML_API_URL` pada build app (build ulang APK), `web/.env.example`, `app/run_web.bat`, dan `docs/` yang menyebut URL.
5. Verifikasi: `GET <url>/api/health` → `{"status":"ok","model_loaded":true,...}`, lalu tes E2E (bagian 8). Model tidak hilang — file `.tflite` ter-commit di git.
   - Catatan: respons `{"detail":"Not Found"}` di `/` itu normal (API tidak punya halaman root).

**Supabase tidak merespons (521/502 dari `*.supabase.co`)** — kemungkinan project ter-*pause* (free tier). Dashboard → Restore project, tunggu beberapa menit. Data dan bucket tetap ada.

**Konektor MCP Supabase menunjuk akun lain** (`list_projects` tidak memuat AgriVision): jangan sentuh project lain; jalankan SQL lewat SQL Editor oleh user, atau minta user mengotorisasi ulang konektor ke org yang benar.

**Railway CLI `invalid_grant`**: butuh `railway login` interaktif oleh user.

## 8. Resep pengujian

**Membuat user uji (Admin API, melewati validasi domain email):**
```python
from supabase import create_client
admin = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)
u = admin.auth.admin.create_user({"email": "uji@agrivision.test", "password": "...", "email_confirm": True})
# ... uji ...
admin.auth.admin.delete_user(u.user.id)   # zona/upload/diagnosis ikut terhapus (cascade)
```
Hapus juga objek Storage uji. Pendaftaran publik via `/auth/v1/signup` menolak domain palsu (`.test`, `example.com`); gunakan alamat dengan domain nyata yang tidak mengirim email (Confirm email OFF) lalu hapus lewat Admin API.

**E2E diagnosis (ringkas):** buat user + zona → unggah gambar ke Storage → insert `uploads` (JWT user) → `POST /api/diagnose` dengan `Origin` = domain Vercel → harapkan 200, header `access-control-allow-origin` sama dengan origin, dan baris `zone_health_daily` terisi. Hapus semua data uji.

**Uji keamanan registrasi:** signUp dengan metadata `{"role":"admin_ppl"}` → profil harus `petani`; `PATCH /rest/v1/profiles?id=eq.<uid>` `{"role":"admin_ppl"}` dengan JWT user → harus 403.

**Menguji Flutter di browser pane:** render canvas (tanpa accessibility tree). Klik pakai koordinat dari screenshot (frame 585×1266 untuk viewport 390×844), beri jeda ±1 dtk antara klik dan mengetik, mulai dari `/` (jangan deep-link `#/rute` saat cold start), hapus `localStorage` untuk keluar dari sesi lama.

## 9. Keamanan

- Jangan commit: `ml-service/.env`, `web/.env.local`, `ml-service/kaggle.json`, `ml-service/roboflow_key.txt`.
- Rotasi service role key: Supabase → Project Settings → API → regenerate; perbarui `ml-service/.env` dan variable Railway; tidak ada klien lain yang memakainya.
- Anon key boleh publik, tetapi hanya aman karena semua tabel memakai RLS.
