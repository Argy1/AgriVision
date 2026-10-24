# AgriVision — Mobile App (Flutter)

Aplikasi pendamping petani: kamera-first untuk memotret daun, hasil diagnosis + rekomendasi, dashboard ringkas, riwayat, panduan penyakit, notifikasi. Memakai backend yang sama dengan web (Supabase + FastAPI di Railway). Konteks proyek: `../CLAUDE.md`.

## Menjalankan

```bash
flutter pub get
flutter run -d <device> \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon key> \
  --dart-define=ML_API_URL=https://agrivision-production.up.railway.app
flutter analyze && flutter test
```
Preview cepat di browser: `run_web.bat` (Flutter web di http://localhost:8081, hanya untuk uji tampilan; kamera/galeri native tidak teruji di sana).

## Pasang ke HP Android

```bash
flutter build apk --release --dart-define=... (tiga define di atas)
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" install -r build\app\outputs\flutter-apk\app-release.apk
```
Hindari `flutter run` di background pada Windows (output tidak ter-flush, tampak menggantung).

## Struktur `lib/`

```
core/{config,theme,utils,errors}   — env, token warna (color_tokens/severity_tokens), tema, helper tanggal Jakarta, mapper error auth
data/{models,sources,repositories} — model (cermin skema/API), klien ml-service (dio), repository per fitur (cermin web/lib/data)
providers/                         — Riverpod (tanpa codegen); upload_flow_controller = state machine upload per-langkah
routing/                           — go_router + auth guard
features/                          — auth (login, daftar, lupa-password OTP), onboarding (zona pertama), dashboard, upload,
                                     diagnosis, history, zone_detail, disease_guide, notifications, profile
shared/widgets/                    — bottom nav shell, kartu, chip, meter, state view
```

## Hal penting

- **Riverpod 3 tanpa codegen** (`riverpod_generator` bentrok dengan pin `meta`). `StateProvider` → `package:flutter_riverpod/legacy.dart`; pakai `.value` (bukan `valueOrNull`).
- **Alur upload** (`providers/upload_flow_controller.dart`): validasi → upload Storage → insert `uploads` → cek idempotensi `diagnoses` → POST `/api/diagnose`. Retry selalu dari langkah yang gagal; auto-resume saat koneksi kembali. `upload_id` UNIQUE → jangan POST ulang tanpa cek.
- **Daftar:** `AuthRepository.signUp`; akun baru → router redirect ke `/mulai` (buat zona pertama). Buka `/daftar` dengan `context.go`, bukan `push`. Pesan error auth dipetakan di `core/errors/auth_error_mapper.dart` (terpisah per konteks: login/OTP/daftar).
- **Banyak akun di satu HP:** `lib/app.dart` meng-invalidate semua provider per-akun saat akun berganti. Tambahkan provider baru yang menyimpan data per-akun ke daftar itu.
- Aturan warna severity (Moss/Ochre/Rust) sama dengan web — hanya lewat `severity_tokens.dart`.
- Android: izin `INTERNET` dan `CAMERA` ada di `AndroidManifest.xml`; iOS: deskripsi kamera/galeri di `Info.plist` (iOS belum pernah dibangun/diuji).
- Tes: `test/` berisi unit test fungsi murni (token severity, skala blob daun, tanggal Jakarta, mapper error auth).
