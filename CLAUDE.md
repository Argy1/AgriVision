# CLAUDE.md — Panduan untuk Claude Code di Proyek Ini

Ini adalah proyek **AgriVision**: tugas akhir mata kuliah Visual Komputer Cerdas milik Argy Fawwaz Akbar (TRPL, Sekolah Vokasi IPB). **Baca file ini dulu sebelum mengubah apa pun.** Untuk detail progres, daftar yang belum selesai, dan runbook operasional, lanjut ke `docs/08-status-dan-progres.md` dan `docs/09-operasional-dan-runbook.md`.

## Status Saat Ini (diperbarui 2026-11-12)

**Seluruh sistem sudah dibangun, di-deploy, dan diuji end-to-end.** Ini BUKAN lagi proyek tahap perencanaan.

| Bagian | Status | Lokasi / URL |
|---|---|---|
| Database + Auth + Storage | ✅ Live | Supabase project `ymfcrxymizwwolikgrhq` (region ap-southeast-1) |
| ML Service (FastAPI) | ✅ Live | https://agrivision-production.up.railway.app (Railway, root `ml-service/`) |
| Web (Next.js 16) | ✅ Live | https://agrivision-blond-nine.vercel.app (Vercel, root `web/`) |
| Mobile app (Flutter) | ✅ Terpasang di HP (APK release) | `app/` (belum di Play Store — tidak perlu untuk scope TA) |
| Model ML (tomat saja) | ✅ Terlatih, ter-commit; training ulang (v2) direncanakan | `ml-service/models/tomato_classifier.tflite` |
| Registrasi publik | ✅ Web + app | lihat bagian "Auth & Registrasi" |
| Evaluasi akurasi lapangan + laporan | ⏳ BELUM (butuh data & tulisan user) | `docs/06-roadmap.md` minggu 13–14 |

Repo: https://github.com/Argy1/AgriVision (branch `main`; Vercel & Railway auto-deploy dari push ke `main`).

## Apa yang Dibangun

Sistem web + mobile app untuk petani/PPL tomat:
1. **Upload foto daun** → 2. **Diagnosis penyakit** (CNN) + **Pemantauan kesehatan** (vegetation index ExG/VARI, classical CV) → 3. **Rekomendasi penanganan** (rule-based dari tabel `disease_reference`).

Konteks lengkap & alasan scope: `docs/01-project-brief.md`.

## Batasan yang TIDAK BOLEH Dilanggar Tanpa Konfirmasi User

- **Hanya tomat.** Fitur cabai DIHAPUS (keputusan 2026-11-12, arahan pembimbing: fokus deteksi daun tomat). Jangan menambah komoditas lain (termasuk mengembalikan cabai) atau men-generalisasi model tanpa konfirmasi user. Catatan teknis: enum Postgres `crop_type` masih memuat nilai `'cabai'` (tidak bisa di-drop dengan rapi) tapi tidak dipakai; `crop_type` tetap dikirim di API dan selalu `'tomat'`.
- **3 modul saja:** diagnosis (deep learning), monitoring (classical CV — BUKAN model DL terpisah), rekomendasi (lookup table — BUKAN model ML). Tidak ada "robotic farming".
- **Supabase untuk data (Postgres/Auth/Storage), FastAPI di Railway untuk inference.** Jangan pindahkan inference ke Supabase Edge Functions (Deno tidak bisa menjalankan TF/ONNX).
- **Next.js untuk web, Flutter untuk app** — dua codebase terpisah, berbagi kontrak API & skema DB yang sama.
- **Teks UI Bahasa Indonesia.** Jangan diterjemahkan.
- **Ikuti `docs/04-api-contract.md` persis.** Perubahan field harus disinkronkan ke backend + web + app.
- **Aturan warna severity (keras):** Moss=sehat/ringan, Ochre=waspada/sedang, Rust=perlu tindakan/parah. Trio ini HANYA untuk makna severity/status — jangan dipakai untuk hal lain (chart ranking, indikator password, dsb.). Sumber tunggal: `web/components/severity/tokens.ts` dan `app/lib/core/theme/severity_tokens.dart`.
- **Service role key TIDAK PERNAH dipakai di web/app/Flutter** — hanya di `ml-service`.

### Perluasan scope yang SUDAH disetujui user (jangan dikembalikan ke rencana awal)

Rencana awal hanya 4 layar per platform sesuai mockup. User sengaja meminta lebih supaya kedua modul ML dimanfaatkan maksimal:
- **Web = 13 route:** login, register, forgot-password, reset-password, onboarding, upload, diagnosis/[id], dashboard, monitoring, zona/[id], analitik, riwayat, pengaturan (+ `/signup` lama yang kini hanya redirect ke `/register`).
- **App = 13 route** (11 layar + 2 auth OTP): login, daftar, mulai (zona pertama), lupa-password, verifikasi-kode, beranda, unggah, riwayat, profil, diagnosis/[id], zona/[id], panduan-penyakit, notifikasi.
- **Registrasi publik** (web + app): siapa pun bisa daftar sendiri; akun selalu `petani`. `admin_ppl` hanya dinaikkan manual oleh user lewat Supabase Dashboard/SQL Editor. Tanpa verifikasi email (keputusan user).

## Auth & Registrasi (penting dipahami sebelum menyentuh auth)

- Daftar: `signUp` dengan `data.full_name`. Trigger DB `handle_new_user()` membuat baris `profiles` dengan role **hardcode `petani`**.
- Trigger `prevent_profile_role_change` menolak perubahan `role` dari client (JWT user). Tanpa ini, user mana pun bisa menjadikan dirinya admin_ppl (policy `profiles_update_own` tidak membatasi kolom). Jangan hapus.
- **"Confirm email" di Supabase Dashboard HARUS OFF**; kalau ON, signUp tidak mengembalikan sesi dan UI menampilkan pesan konfigurasi.
- Reset password: web pakai link (PKCE, `/reset-password`); app pakai **OTP 6 digit** (tanpa deep link).
- Setelah daftar: web → `/onboarding`, app → `/mulai` (buat zona pertama, bisa dilewati).

## Struktur Folder

```
CLAUDE.md                ← file ini
README.md                ← ringkasan + cara menjalankan
docs/                    ← 01–07 desain & keputusan, 08 status/progres, 09 runbook
design/                  ← design-system.md + screens/ (8 mockup HTML/PNG)
database/
  schema.sql             ← sumber kebenaran skema (harus selalu sinkron dengan produksi)
  migrations/            ← migrasi tambahan yang dijalankan manual (003 = pengerasan registrasi publik)
ml-service/              ← FastAPI + model TFLite + notebook training + tes E2E
  app/{routers,cv,ml}    ← endpoint, classical CV (ExG/VARI, segmentasi), inferensi
  models/                ← tomato_classifier.tflite, label_map.json
web/                     ← Next.js 16 (App Router, Tailwind v4, Supabase SSR)
app/                     ← Flutter (Riverpod, go_router, supabase_flutter)
```

## Gotcha yang Sering Membuat Salah (baca!)

**Umum**
- Tanggal "hari ini" untuk `zone_health_daily` = **kalender Asia/Jakarta**, bukan UTC. Web: `toJakartaDateString()` di `web/lib/data/zone-health.ts`; app: `app/lib/core/utils/jakarta_date.dart`. Jangan pakai `toISOString().slice(0,10)`.
- `diagnoses.upload_id` UNIQUE → memanggil `/api/diagnose` dua kali untuk upload yang sama = 500. Selalu cek `diagnoses` by `upload_id` sebelum retry (lihat `web/components/upload/Dropzone.tsx` dan `app/lib/providers/upload_flow_controller.dart`).
- Trigger `upsert_zone_health_daily` mengisi `zone_health_daily` dan **bergantung pada urutan insert di `ml-service/app/routers/diagnose.py`** (diagnoses sebelum vegetation_index_readings). Jangan ubah urutannya.
- Supabase menolak domain email palsu (`.test`, `example.com`) untuk signup publik. Untuk membuat user uji, pakai Admin API (`auth.admin.create_user`, `email_confirm=True`) dan hapus lagi setelah tes.

**Web (Next.js 16)** — ini BUKAN Next.js versi lama:
- `middleware.ts` diganti nama menjadi **`proxy.ts`** (export `proxy`). Baca `web/AGENTS.md` dan `node_modules/next/dist/docs/` sebelum menulis kode Next.
- Tailwind v4: token ada di `web/app/globals.css` (`@theme`), tidak ada `tailwind.config.ts`.
- Next 16 + React Compiler lint: jangan `setState` sinkron di dalam `useEffect`; deklarasikan fungsi sebelum dipakai.
- Recharts v3: tipe `formatter`/`labelFormatter` lebih ketat — pakai `String(x)` di dalam.

**App (Flutter)**
- Riverpod 3 **tanpa codegen** (`riverpod_generator` bentrok dengan pin `meta` Flutter SDK). `StateProvider` ada di `package:flutter_riverpod/legacy.dart`; `AsyncValue.valueOrNull` sudah diganti `.value`.
- Pagination Riwayat memakai "ambil pageSize+1" (tanpa `count: exact`).
- Saat akun berganti, `app/lib/app.dart` meng-invalidate semua provider per-akun (banyak orang bisa memakai satu HP). Provider baru yang menyimpan data per-akun harus ditambahkan ke daftar itu.
- Layar daftar dibuka dengan `context.go` (bukan `push`) supaya redirect ke `/mulai` bekerja saat sesi terbentuk.
- Di Windows, `flutter run` di background bisa menggantung tanpa output. Pasang ke HP dengan `flutter build apk --release --dart-define=...` lalu `adb install -r` (adb: `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`; di Samsung pakai `pm list packages --user 0`).
- Menguji Flutter web di browser pane: render canvas, tidak ada accessibility tree; klik koordinat, beri jeda ±1 detik sebelum mengetik; deep link `#/rute` di cold start bisa tampil kosong — mulai dari `/`.

**Infra**
- Konektor MCP Supabase di sesi Claude kadang terikat ke akun/org lain (tidak melihat project AgriVision). Jika begitu, jalankan SQL lewat Supabase SQL Editor oleh user.
- Supabase free tier bisa **pause** saat tidak aktif (gejala: 521/502 dari `*.supabase.co`) → Restore di dashboard.
- Railway: service pernah terhapus tidak sengaja (2026-10-23) dan dibuat ulang. Setelan wajib: root directory `ml-service`, healthcheck `/api/health`, env var di `docs/09-operasional-dan-runbook.md`. URL berubah tiap service dibuat ulang → update `NEXT_PUBLIC_ML_API_URL` (Vercel), `ML_API_URL` (build app), `ALLOWED_ORIGINS` (Railway).

## Cara Menjalankan Tiap Bagian

Lihat `docs/09-operasional-dan-runbook.md` (perintah lengkap, env var, deploy, tes). Singkat:
- Web: `cd web && npm install && npm run dev` (butuh `web/.env.local`, contoh di `web/.env.example`).
- ML service: `cd ml-service && python -m venv .venv && pip install -r requirements-dev.txt && uvicorn app.main:app` (butuh `ml-service/.env`).
- App: `cd app && flutter pub get && flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=ML_API_URL=...` (atau `app/run_web.bat` untuk Flutter web).
- Tes: `flutter test` (app), `npm run lint && npm run build` (web), `pytest` (ml-service, butuh `.env` asli).

## Keamanan & Rahasia

- `ml-service/.env` (berisi `SUPABASE_SERVICE_ROLE_KEY`), `web/.env.local`, `kaggle.json`, `roboflow_key.txt` **tidak boleh di-commit** (sudah di `.gitignore`). Anon key Supabase bukan rahasia (aman ada di `run_web.bat`/`.env.example`).
- Service role key pernah ditempel di chat; user disarankan **merotasinya** (Supabase → Settings → API) lalu memperbarui `ml-service/.env` dan variable Railway.
- Jangan menaruh nilai rahasia di dokumen markdown.

## Hal yang Masih Perlu Dikerjakan

Daftar lengkap & terkini ada di `docs/08-status-dan-progres.md`. Ringkasnya: evaluasi akurasi lapangan vs lab, verifikasi isi `disease_reference` (hanya 2 dari 10 baris tomat `is_verified=true`), kalibrasi `health_score` (ExG min/max masih placeholder), uji app di berbagai HP, **training ulang model tomat (v2) dengan data non-lab + set uji lapangan** (lihat `docs/05` dan `docs/08`), revisi naskah/pptx ke versi tomat saja, dan penulisan laporan.

## Kalau Ragu

Jika instruksi user tampak bertentangan dengan dokumen ini (mis. menambah komoditas ketiga), **tanyakan dulu** — kemungkinan itu perubahan sadar yang perlu dikonfirmasi. Jangan diam-diam mengikuti dokumen lama jika user jelas meminta hal berbeda hari ini, tapi jangan juga diam-diam mengubah keputusan besar. Setelah ada keputusan baru, **perbarui dokumen ini dan `docs/08`**.
