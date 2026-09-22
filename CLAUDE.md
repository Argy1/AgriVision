# CLAUDE.md — Panduan untuk Claude Code di Proyek Ini

Ini adalah proyek **AgriVision**: tugas akhir mata kuliah Visual Komputer Cerdas milik Argy Fawwaz Akbar (TRPL, Sekolah Vokasi IPB). Baca file ini sebelum menulis kode apa pun di folder ini.

## Status Saat Ini

**Belum ada kode aplikasi.** Semua yang ada di folder ini adalah hasil perencanaan (dokumen, skema SQL, mockup desain) yang sudah difinalisasi lewat diskusi panjang dengan user — bukan draft yang masih bisa diperdebatkan ulang. Tugasmu adalah **mengimplementasikan**, bukan merancang ulang dari nol, kecuali user secara eksplisit memintanya.

## Apa yang Sedang Dibangun

Sistem web + mobile app untuk petani/PPL tomat & cabai:
1. **Upload foto daun** → **2. Diagnosis penyakit** (deep learning CNN) + **Pemantauan kesehatan** (vegetation index ExG/VARI, classical CV) → **3. Rekomendasi penanganan** (rule-based dari knowledge base).

Baca `docs/01-project-brief.md` untuk konteks lengkap (rumusan masalah, tujuan, dan **kenapa** scope-nya seperti ini — banyak keputusan di sana adalah hasil pertimbangan sadar, bukan default, jadi jangan diubah tanpa bertanya ke user dulu).

## Batasan yang TIDAK BOLEH Dilanggar Tanpa Konfirmasi User

- **Hanya tomat dan cabai.** Jangan menambah komoditas lain atau men-generalisasi model ke "semua tanaman".
- **3 modul saja:** diagnosis (deep learning), monitoring (classical CV/vegetation index — BUKAN model deep learning terpisah), rekomendasi (rule-based lookup table — BUKAN model ML). Jangan menambahkan "robotic farming" atau modul lain di luar scope ini.
- **Supabase untuk data (Postgres/Auth/Storage), FastAPI di Railway untuk ML inference.** Jangan pindahkan inference model ke Supabase Edge Functions (tidak didukung — Deno runtime tidak bisa menjalankan TensorFlow/PyTorch/ONNX).
- **Next.js untuk web, Flutter untuk app** — dua codebase terpisah yang berbagi kontrak API & skema database yang sama. Jangan mencoba membuat satu kode yang di-share langsung antara keduanya (beda bahasa/framework total).
- **Teks UI dalam Bahasa Indonesia**, sesuai desain di `design/screens/`. Jangan diterjemahkan ke Inggris.
- **Ikuti `docs/04-api-contract.md` persis** — ini kontrak bersama antara backend dan kedua frontend. Perubahan di satu sisi (misal nama field response) harus disinkronkan ke semua sisi lain, bukan dibuat menyimpang diam-diam.

## Urutan Kerja yang Disarankan

Jangan mulai dari frontend. Urutan ini penting karena tiap tahap bergantung pada tahap sebelumnya:

1. **Setup database** — jalankan `database/schema.sql` di Supabase (buat project Supabase baru dulu jika belum ada, lalu `mcp__Supabase__apply_migration` atau paste manual ke SQL editor). Verifikasi RLS policies jalan dengan benar sebelum lanjut.
2. **Training model diagnosis** — ikuti `docs/05-ml-pipeline.md` untuk dataset, arsitektur (MobileNetV2 untuk tomat, EfficientNetB4 untuk cabai), dan evaluasi. Ini biasanya dikerjakan di notebook/Colab dulu (butuh GPU), baru modelnya di-export (TFLite/ONNX) untuk dipakai FastAPI.
3. **Bangun FastAPI service** — implementasikan `POST /api/diagnose` persis sesuai `docs/04-api-contract.md`, load model hasil training, hitung vegetation index (ExG/VARI) sesuai `docs/05-ml-pipeline.md`, lookup rekomendasi dari `disease_reference`. Deploy ke Railway.
4. **Bangun web (Next.js)** — 4 halaman inti sesuai `design/screens/1-4`: Login, Unggah Foto, Hasil Diagnosis, Dashboard. Ikuti token warna & tipografi di `design/design-system.md` persis (jangan improvisasi palet baru). Web adalah **platform utama** — selesaikan ini dulu sebelum mulai app, karena ini deliverable yang akan didemokan saat sidang jika waktu app tidak cukup.
5. **Bangun app (Flutter)** — 4 halaman yang sama sesuai `design/screens/5-8`, terhubung ke backend yang sama (`supabase_flutter` + HTTP client ke FastAPI). App adalah **companion untuk upload cepat dari lapangan** (kamera-first).
6. **Integrasi & testing end-to-end**, lalu evaluasi model untuk laporan (lihat `docs/05-ml-pipeline.md` bagian evaluasi — akurasi lab vs lapangan harus dilaporkan terpisah).

Detail lengkap per minggu ada di `docs/06-roadmap.md`.

## Referensi Cepat per Dokumen

| Butuh tahu... | Baca |
|---|---|
| Kenapa scope-nya begini (2 crop, 3 modul) | `docs/01-project-brief.md` |
| Kenapa Supabase+Railway, bukan yang lain | `docs/02-tech-stack.md` |
| Struktur tabel, relasi, RLS | `docs/03-database-schema.md` + `database/schema.sql` |
| Format request/response API | `docs/04-api-contract.md` |
| Dataset, arsitektur model, rumus ExG/VARI, evaluasi | `docs/05-ml-pipeline.md` |
| Urutan pengerjaan per minggu | `docs/06-roadmap.md` |
| Sitasi akademik untuk laporan | `docs/07-referensi.md` |
| Warna, font, komponen UI | `design/design-system.md` |
| Tampilan pasti tiap layar (buka langsung di browser) | `design/screens/*.html` |

## Struktur Folder yang Disarankan Saat Mulai Coding

Belum dibuat — buat struktur berikut saat mulai implementasi (di root folder ini, sejajar dengan `docs/`, `design/`, `database/`):

```
web/            ← Next.js project (npx create-next-app)
app/            ← Flutter project (flutter create)
ml-service/     ← FastAPI project + notebook training model
```

## Kalau Ragu

Kalau ada instruksi user yang tampak bertentangan dengan dokumen-dokumen di atas (misal minta tambah komoditas ketiga, atau pindah database ke tempat lain), **tanyakan dulu** — ada kemungkinan besar itu perubahan sadar yang perlu didiskusikan ulang, bukan sekadar dilewati begitu saja. Jangan diam-diam mengikuti dokumen lama jika user jelas-jelas minta sesuatu yang berbeda hari ini; tapi juga jangan diam-diam mengubah keputusan besar tanpa mengonfirmasi bahwa user sadar itu perubahan dari rencana yang sudah difinalisasi.
