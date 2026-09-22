# Project Brief

## Identitas
- **Nama:** Argy Fawwaz Akbar (NIM: J0403241149)
- **Program studi:** D4 Teknologi Rekayasa Perangkat Lunak (TRPL), Sekolah Vokasi IPB University
- **Mata kuliah:** Visual Komputer Cerdas (Computer Vision) — Projek Akhir

## Judul
**Sistem Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat dan Cabai Berbasis Computer Vision untuk Precision Farming**

Versi ringkas (opsional, untuk cover): "Sistem Computer Vision untuk Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat dan Cabai dalam Mendukung Precision Farming"

Nama produk (working title, dipakai di UI & mockup): **AgriVision**

## Latar Belakang
Petani tomat dan cabai kesulitan mendeteksi penyakit tanaman secara dini karena keterbatasan akses ke penyuluh pertanian (PPL) dan minimnya alat bantu diagnosis yang murah dan cepat. Computer vision memungkinkan diagnosis penyakit dari foto daun secara otomatis, sekaligus memantau tren kesehatan tanaman dari waktu ke waktu tanpa memerlukan sensor mahal (multispektral/drone).

## Rumusan Masalah
1. Bagaimana merancang model computer vision yang dapat mengklasifikasikan jenis penyakit pada daun tomat dan cabai dengan akurasi yang dapat dipertanggungjawabkan?
2. Bagaimana memantau tren kesehatan tanaman dari waktu ke waktu tanpa bergantung pada sensor multispektral/drone yang mahal?
3. Bagaimana menghasilkan rekomendasi penanganan yang relevan berdasarkan hasil diagnosis, sehingga sistem tidak berhenti di deteksi saja tetapi mendukung pengambilan keputusan petani (precision farming)?

## Tujuan
1. Membangun model klasifikasi penyakit daun tomat & cabai menggunakan deep learning (transfer learning: MobileNetV2 / EfficientNet).
2. Membangun modul pemantauan kesehatan tanaman berbasis vegetation index (ExG, VARI) dari foto RGB biasa, sebagai alternatif ringan dari NDVI/multispektral.
3. Membangun modul rekomendasi penanganan berbasis rule/knowledge base yang terhubung dengan hasil diagnosis.
4. Mengintegrasikan ketiga modul di atas menjadi satu sistem end-to-end (web + mobile app) yang dapat digunakan petani/PPL.

## Scope & Batasan Masalah (penting — jangan diperluas tanpa alasan kuat)
- **Komoditas:** hanya **tomat dan cabai**. Alasan: dataset PlantVillage/PlantDoc paling kuat untuk dua komoditas ini, keduanya satu famili (Solanaceae) dengan pola penyakit yang berdekatan, dan scope ini realistis untuk dikerjakan dalam satu semester tanpa mengorbankan kedalaman evaluasi. **Jangan generalisasi ke "semua tanaman"** — itu menurunkan akurasi dan sulit dipertanggungjawabkan saat sidang.
- **3 modul, bukan 4.** "Robotic farming" (dari daftar ide awal) sengaja **tidak** dimasukkan ke scope — itu ranah hardware/robotika (aktuator, kontrol real-time), bukan software CV. Cukup disebut sebagai *future work* di laporan.
- **Crop monitoring** tidak dibangun sebagai model CV terpisah (dataset publik untuk itu lemah/generik). Sebagai gantinya, monitoring diwujudkan sebagai **tren histori** dari data yang dihasilkan sistem sendiri (setiap diagnosis + skor vegetation index disimpan dengan timestamp per zona), dipadukan dengan **vegetation index (ExG/VARI)** dari classical CV — bukan deep learning tambahan.
- **Precision farming** diwujudkan sebagai **rule-based recommendation**, bukan model ML terpisah — mapping dari hasil diagnosis ke rekomendasi dosis/jadwal penanganan, disusun dari literatur agronomi.

## Arsitektur 3 Modul
1. **Modul Diagnosis** (deep learning) — klasifikasi penyakit dari foto daun. Dataset: PlantVillage / PlantDoc / New Plant Diseases Dataset (Kaggle), difilter ke kelas tomat & cabai.
2. **Modul Monitoring** (classical CV + histori) — hitung ExG/VARI dari foto RGB → skor kesehatan 0–100 → disimpan per zona/waktu → ditampilkan sebagai tren.
3. **Modul Rekomendasi** (rule-based) — knowledge base pemetaan disease_label → rekomendasi penanganan (jenis, dosis, jadwal), disusun dari literatur agronomi (lihat `07-referensi.md`).

## Target Pengguna
- **Admin PPL (Penyuluh Pertanian Lapangan):** mengelola zona/petak, memantau banyak zona sekaligus, melihat dashboard agregat.
- **Petani:** mengunggah foto dari lapangan (mobile app, kamera-first), melihat hasil diagnosis & rekomendasi untuk zonanya sendiri.

## Deliverable Akhir
- Web app (Next.js) — dashboard admin/PPL.
- Mobile app (Flutter) — upload cepat dari lapangan, hasil diagnosis, dashboard ringkas.
- Backend ML inference (FastAPI di Railway).
- Database & Auth (Supabase).
- Laporan tugas akhir dengan evaluasi model (confusion matrix, akurasi lab vs. lapangan) dan studi kasus rekomendasi.

## Keputusan Desain yang Sudah Diambil (ringkasan diskusi)
- 2 komoditas (bukan lebih) — keputusan sadar demi kedalaman evaluasi, bukan keterbatasan teknis.
- 3 modul (diagnosis + monitoring + rekomendasi), robotic farming di-exclude.
- Web (Next.js) dan mobile app (Flutter) dibangun terpisah, tapi berbagi satu backend (Supabase + FastAPI) sebagai kontrak API yang sama.
- Supabase untuk database/auth/storage; Railway untuk ML inference (FastAPI) — karena Supabase Edge Functions (Deno) tidak bisa menjalankan model deep learning.
