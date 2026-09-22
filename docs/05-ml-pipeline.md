# ML Pipeline — Diagnosis & Monitoring

## Modul 1: Diagnosis (Deep Learning)

### Dataset (terverifikasi — lihat `ml-service/agrivision_training.ipynb`)

**Tomat — PlantVillage (via Kaggle "New Plant Diseases Dataset", Chohan et al.)**
Sudah di-split train/valid, 10 kelas persis (jangan diubah nama foldernya, notebook melakukan assertion terhadap daftar ini):
`Bacterial_spot`, `Early_blight`, `Late_blight`, `Leaf_Mold`, `Septoria_leaf_spot`, `Spider_mites Two-spotted_spider_mite`, `Target_Spot`, `Tomato_Yellow_Leaf_Curl_Virus`, `Tomato_mosaic_virus`, `healthy` (prefix `Tomato___` pada nama folder asli). Download otomatis via Kaggle API di notebook (cell Step 1–2).

**Cabai — Roboflow Universe `chili-leaves-disease-classification`**
6 kelas: `healthy`, `leaf curl`, `leaf spot`, `powdery mildew`, `whitefly`, `yellowish` — 1.147 gambar total. Download otomatis via Roboflow Python SDK (`pip install roboflow`, cell Step 3 di notebook) — **tidak ada langkah upload manual**, hanya butuh API key gratis (ditempel sekali di Step 1, mirip login, bukan file besar yang diupload). Struktur hasil download (sudah ter-split train/valid/test, atau flat) dideteksi otomatis saat runtime — begitu juga nama folder kelas, karena berpotensi mengandung spasi/variasi kapitalisasi.
- **Riwayat perubahan dataset cabai (4 kali ganti — didokumentasikan lengkap supaya jelas alasannya, bukan asal ganti-ganti):**
  1. Dua kandidat Kaggle awal ditolak: `shuvokumarbasak4004/chili-plant-disease-detection` (cuma 2 kelas kesehatan buah, bukan penyakit daun) dan `ravindubandara3002/...` (struktur tidak bisa diverifikasi).
  2. Sempat pindah ke Mendeley Data `wzc6r6w5w5` (Ahmed et al., CC BY 4.0, 4 kelas, 1.544 gambar) — datanya bagus, tapi Mendeley tidak punya API download otomatis, dan upload manual ZIP-nya ke Colab lewat `files.upload()` sering macet/stuck di 0%.
  3. Pindah ke Kaggle `dhenyd/chili-plant-disease` (5 kelas, 500 gambar) — solusi sementara yang full-API, tapi ternyata terlalu kecil untuk kebutuhan user.
  4. **Pindah final ke Roboflow `chili-leaves-disease-classification`** (6 kelas, 1.147 gambar) — lebih dari 2x lipat dataset Kaggle sebelumnya, tetap foto close-up daun (bukan foto kanopi/lapangan) dan tetap punya kelas *healthy*, didownload otomatis lewat Roboflow SDK persis seperti alur Kaggle untuk tomat.
- **Kenapa bukan opsi yang lebih besar lagi:** ada dataset *pepper* (bukan chili/cabai) di Hugging Face dengan 26.377 gambar tanpa perlu API key — tapi itu foto tanaman lapangan/kanopi, **tanpa kelas sehat**, dan provenance-nya diragukan (paper yang disitasi angkanya tidak cocok). Dataset cabai terbesar yang benar-benar cocok secara konten (10.987 dan 8.814 gambar, termasuk kelas sehat) semuanya ada di Mendeley — masalah yang sama seperti poin 2 di atas (tidak API-downloadable). Roboflow adalah titik seimbang terbaik saat ini antara ukuran, kecocokan konten, dan otomatisasi penuh.
- **Trade-off yang harus dilaporkan apa adanya:** meski lebih besar dari opsi Kaggle sebelumnya, 1.147 gambar/6 kelas (±190 gambar/kelas) masih jauh lebih kecil dari dataset tomat (~87.900 gambar). Akurasi validasi cabai kemungkinan tetap lebih fluktuatif/rendah dan lebih rawan overfitting dibanding tomat — mitigasi lewat augmentasi + transfer learning + fine-tuning bertahap (sudah diimplementasikan di notebook), tapi angka evaluasi tetap harus dilaporkan jujur.
- **Semantik kelas:** `whitefly` (kutu kebul — nama hama vektor, bukan nama penyakit) dan `yellowish`/`leaf spot` (gejala/deskripsi umum, bukan nama patogen spesifik) — beda dari penamaan spesifik seperti `Anthracnose` di versi Mendeley yang tidak dipakai. Sesuaikan istilah ini di teks laporan/UI.
- **Verifikasi nomor versi dataset:** notebook mengasumsikan `version(1)` di project Roboflow — ini bisa berubah kalau pemilik project merilis versi baru. Notebook sudah melakukan assertion otomatis kalau kelas yang ditemukan tidak sesuai; cek juga nomor versi terbaru langsung di halaman project sebelum training final.

**Label penyakit final (dipakai di `disease_reference.disease_label`, dihasilkan otomatis oleh notebook lewat fungsi `slugify()`/`to_disease_label()`):**
- Tomat: `tomato_bacterial_spot`, `tomato_early_blight`, `tomato_late_blight`, `tomato_leaf_mold`, `tomato_septoria_leaf_spot`, `tomato_spider_mites_two_spotted_spider_mite`, `tomato_target_spot`, `tomato_tomato_yellow_leaf_curl_virus`, `tomato_tomato_mosaic_virus`, `tomato_healthy`
- Cabai: `chili_healthy`, `chili_leaf_curl`, `chili_leaf_spot`, `chili_powdery_mildew`, `chili_whitefly`, `chili_yellowish`

**Untuk generalisasi ke kondisi lapangan (bukan hanya foto lab):** tambahkan/gunakan PlantDoc (Singh et al. 2020) sebagai data uji tambahan untuk tomat — akurasi PlantVillage (lab) vs PlantDoc (lapangan) **harus dilaporkan terpisah** di evaluasi, karena keduanya biasanya berbeda signifikan (lihat catatan di `07-referensi.md`). Dataset cabai sejauh ini belum punya padanan data-lapangan terpisah — kalau ada waktu, ambil sendiri beberapa foto cabai dari lapangan sebagai uji tambahan kualitatif (makin penting mengingat ukuran dataset training-nya kecil).

### Arsitektur Model
- **Tomat:** MobileNetV2 (transfer learning, ImageNet pretrained) — ringan, cocok untuk inference cepat. Referensi: Sharma et al. 2025 (ensemble ResNet50+MobileNetV2 pada 10 kelas tomat, 99.91% akurasi test).
- **Cabai:** EfficientNetB4 (transfer learning) — referensi Pratap & Kumar 2023 ("EfficientLeafNetB4" mengungguli ResNet-50/DenseNet-121/MobileNetV2/VGG-16 pada 5 kelas cabai).
- Dua model terpisah per komoditas (bukan satu model gabungan) — lebih akurat karena distribusi kelas penyakit tomat dan cabai berbeda, dan `crop_type` sudah diketahui dari input user (zona sudah terikat ke satu crop_type).

### Preprocessing
- Resize ke ukuran input model (224x224 untuk MobileNetV2, 380x380 untuk EfficientNetB4 — sesuaikan dengan varian yang dipakai).
- Normalisasi sesuai preprocessing bawaan arsitektur (`tf.keras.applications.mobilenet_v2.preprocess_input`, dst).
- Augmentasi saat training: rotasi, flip, brightness/contrast jitter (agar model lebih robust ke variasi foto lapangan).

### Affected Area (`affected_area_pct`)
Dihitung dengan segmentasi sederhana (bukan model segmentasi terpisah — di luar scope): threshold warna pada channel HSV untuk mendeteksi area bercak/lesi (biasanya kecoklatan/kekuningan) relatif terhadap total area daun (dipisahkan dari background lewat masking hijau). Ini classical CV, bukan deep learning — konsisten dengan pendekatan modul monitoring.

### Mapping Severity
Aturan sederhana (dokumentasikan di kode, sesuaikan berdasarkan validasi):
```
if affected_area_pct < 15%          → ringan
elif affected_area_pct < 40%        → sedang
else                                 → parah
```
(Confidence rendah, misal <70%, sebaiknya ditandai terpisah sebagai "perlu verifikasi manual" — pertimbangkan untuk versi lanjutan, di luar MVP.)

### Deployment
Export model ke **TFLite** atau **ONNX** untuk inference ringan di FastAPI (Railway punya resource terbatas dibanding training environment). Load model sekali saat startup service, bukan per-request.

### Evaluasi (wajib untuk laporan TA)
- Confusion matrix per kelas.
- Akurasi, precision, recall, F1 — dilaporkan terpisah untuk data uji lab (PlantVillage held-out) vs data uji lapangan (PlantDoc atau foto sendiri).
- Diskusikan secara eksplisit **gap akurasi lab vs lapangan** di bab pembahasan (lihat caveat di `07-referensi.md`) — ini justru memperkuat kredibilitas evaluasi, bukan kelemahan yang perlu disembunyikan.

---

## Modul 2: Monitoring (Classical CV — Vegetation Index)

Tidak pakai deep learning tambahan — pakai **Excess Green Index (ExG)** dan **VARI (Visible Atmospherically Resistant Index)**, dihitung langsung dari foto RGB yang sama dengan yang dipakai modul diagnosis.

### Rumus
```
ExG  = 2G - R - B
VARI = (G - R) / (G + R - B)
```
(R, G, B dinormalisasi ke rentang 0–1 sebelum dihitung.)

### Implementasi
1. Baca gambar (OpenCV, `cv2.imread`).
2. Segmentasi area tanaman vs background (mask sederhana berdasarkan ExG > threshold, karena ExG sendiri sudah efektif memisahkan vegetasi dari background — referensi Woebbecke et al. 1995).
3. Hitung rata-rata ExG dan VARI hanya pada piksel tanaman (bukan seluruh gambar).
4. Normalisasi ke `health_score` 0–100 (kalibrasi skala berdasarkan distribusi nilai dari dataset training — dokumentasikan formula normalisasi yang dipakai).

### Kenapa bukan NDVI/multispektral
NDVI butuh sensor near-infrared (kamera khusus/drone) yang mahal dan di luar jangkauan petani kecil. Studi RGB-index (Sukhova et al. 2025; Rossi et al. 2025) menunjukkan ExG/VARI berkorelasi kuat dengan NDVI dan bahkan bisa merespons stres tanaman lebih awal — cukup valid sebagai proxy murah. Ini adalah **justifikasi teknis**, bukan sekadar penyederhanaan — cantumkan di bab metodologi laporan.

### Output
`health_score` disimpan per upload dengan timestamp → dipakai untuk membangun **tren histori per zona** di dashboard (grafik line chart 30 hari terakhir), tanpa perlu model CV tambahan untuk "crop monitoring".

---

## Modul 3: Rekomendasi (Rule-Based)

Bukan model ML — murni **lookup table** dari `disease_reference` (lihat `03-database-schema.md`). Isi tabel disusun manual dari literatur agronomi (referensi #17, #18 di `07-referensi.md` untuk pola arsitektur "deteksi → rekomendasi", dan sumber agronomi lokal/Kementan untuk isi dosis & jadwal aktual — **verifikasi isi rekomendasi dengan dosen pembimbing atau sumber agronomi terpercaya sebelum dipakai di laporan final**, karena dosis pestisida yang salah berisiko nyata bagi pengguna).
