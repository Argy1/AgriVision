# Project Brief

## Identitas
- **Nama:** Argy Fawwaz Akbar (NIM: J0403241149)
- **Program studi:** D4 Teknologi Rekayasa Perangkat Lunak (TRPL), Sekolah Vokasi IPB University
- **Mata kuliah:** Visual Komputer Cerdas (Computer Vision) — Projek Akhir

## Judul
**Sistem Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat Berbasis Computer Vision untuk Precision Farming**

Versi ringkas (opsional, untuk cover): "Sistem Computer Vision untuk Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat dalam Mendukung Precision Farming"

Nama produk (working title, dipakai di UI & mockup): **AgriVision**

## Latar Belakang
Petani tomat kesulitan mendeteksi penyakit tanaman secara dini karena keterbatasan akses ke penyuluh pertanian (PPL) dan minimnya alat bantu diagnosis yang murah dan cepat. Computer vision memungkinkan diagnosis penyakit dari foto daun secara otomatis, sekaligus memantau tren kesehatan tanaman dari waktu ke waktu tanpa memerlukan sensor mahal (multispektral/drone).

## Rumusan Masalah
1. Bagaimana merancang model computer vision yang dapat mengklasifikasikan jenis penyakit pada daun tomat dengan akurasi yang dapat dipertanggungjawabkan?
2. Bagaimana memantau tren kesehatan tanaman dari waktu ke waktu tanpa bergantung pada sensor multispektral/drone yang mahal?
3. Bagaimana menghasilkan rekomendasi penanganan yang relevan berdasarkan hasil diagnosis, sehingga sistem tidak berhenti di deteksi saja tetapi mendukung pengambilan keputusan petani (precision farming)?

## Tujuan
1. Membangun model klasifikasi penyakit daun tomat menggunakan deep learning (transfer learning: MobileNetV2 / EfficientNet).
2. Membangun modul pemantauan kesehatan tanaman berbasis vegetation index (ExG, VARI) dari foto RGB biasa, sebagai alternatif ringan dari NDVI/multispektral.
3. Membangun modul rekomendasi penanganan berbasis rule/knowledge base yang terhubung dengan hasil diagnosis.
4. Mengintegrasikan ketiga modul di atas menjadi satu sistem end-to-end (web + mobile app) yang dapat digunakan petani/PPL.

## Scope & Batasan Masalah (penting — jangan diperluas tanpa alasan kuat)
- **Komoditas:** hanya **tomat** (keputusan 2026-11-12, arahan pembimbing: fokus deteksi daun tomat; cabai sebelumnya ikut dalam scope dan sudah dihapus dari sistem). Alasan fokus: dataset PlantVillage/PlantDoc paling kuat untuk tomat, dan satu komoditas memungkinkan evaluasi lebih dalam (termasuk uji lapangan). **Jangan generalisasi ke "semua tanaman"** — itu menurunkan akurasi dan sulit dipertanggungjawabkan saat sidang.
- **3 modul, bukan 4.** "Robotic farming" (dari daftar ide awal) sengaja **tidak** dimasukkan ke scope — itu ranah hardware/robotika (aktuator, kontrol real-time), bukan software CV. Cukup disebut sebagai *future work* di laporan.
- **Crop monitoring** tidak dibangun sebagai model CV terpisah (dataset publik untuk itu lemah/generik). Sebagai gantinya, monitoring diwujudkan sebagai **tren histori** dari data yang dihasilkan sistem sendiri (setiap diagnosis + skor vegetation index disimpan dengan timestamp per zona), dipadukan dengan **vegetation index (ExG/VARI)** dari classical CV — bukan deep learning tambahan.
- **Precision farming** diwujudkan sebagai **rule-based recommendation**, bukan model ML terpisah — mapping dari hasil diagnosis ke rekomendasi dosis/jadwal penanganan, disusun dari literatur agronomi.

## Arsitektur 3 Modul
1. **Modul Diagnosis** (deep learning) — klasifikasi penyakit dari foto daun. Dataset: PlantVillage / PlantDoc / New Plant Diseases Dataset (Kaggle), difilter ke kelas tomat.
2. **Modul Monitoring** (classical CV + histori) — hitung ExG/VARI dari foto RGB → skor kesehatan 0–100 → disimpan per zona/waktu → ditampilkan sebagai tren.
3. **Modul Rekomendasi** (rule-based) — knowledge base pemetaan disease_label → rekomendasi penanganan (jenis, dosis, jadwal), disusun dari literatur agronomi (lihat `07-referensi.md`).

## Target Pengguna
- **Admin PPL (Penyuluh Pertanian Lapangan):** mengelola zona/petak, memantau banyak zona sekaligus, melihat dashboard agregat. Akun ini **tidak bisa dibuat lewat pendaftaran**; dinaikkan manual dari akun petani (lihat `09-operasional-dan-runbook.md`).
- **Petani:** mengunggah foto dari lapangan (mobile app, kamera-first), melihat hasil diagnosis & rekomendasi untuk zonanya sendiri. **Siapa pun bisa mendaftar sendiri** (web & app) dan otomatis menjadi petani — keputusan user agar sistem bisa dipakai banyak orang.

## Deliverable Akhir
*(Status per 2026-10-24 — rincian di `08-status-dan-progres.md`)*
- ✅ Web app (Next.js) — dashboard + monitoring + analitik, live di Vercel.
- ✅ Mobile app (Flutter) — kamera-first, hasil diagnosis, dashboard ringkas, panduan penyakit, notifikasi; APK terpasang di HP.
- ✅ Backend ML inference (FastAPI di Railway).
- ✅ Database & Auth (Supabase), termasuk registrasi publik.
- ⏳ Laporan tugas akhir dengan evaluasi model (confusion matrix lab sudah ada; **akurasi lapangan & penulisan laporan belum**) dan studi kasus rekomendasi.

## Keputusan Desain yang Sudah Diambil (ringkasan diskusi)
- 2 komoditas (bukan lebih) — keputusan sadar demi kedalaman evaluasi, bukan keterbatasan teknis.
- 3 modul (diagnosis + monitoring + rekomendasi), robotic farming di-exclude.
- Web (Next.js) dan mobile app (Flutter) dibangun terpisah, tapi berbagi satu backend (Supabase + FastAPI) sebagai kontrak API yang sama.
- Jumlah layar **sengaja diperluas** di atas mockup awal (web 13 route, app 13 route) supaya modul diagnosis & monitoring termanfaatkan maksimal — atas permintaan user; jangan dikembalikan ke 4 layar.
- Pendaftaran publik tanpa verifikasi email; role selalu `petani` (dipaksa DB).
- Supabase untuk database/auth/storage; Railway untuk ML inference (FastAPI) — karena Supabase Edge Functions (Deno) tidak bisa menjalankan model deep learning.
