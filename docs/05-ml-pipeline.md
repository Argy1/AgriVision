# ML Pipeline — Diagnosis & Monitoring

## Status implementasi (aktual, 2026-11-12)

- **Model terlatih & ter-deploy:** `ml-service/models/tomato_classifier.tflite` (MobileNetV2, 224px, 10 kelas) dan `label_map.json` (urutan kelas + `model_version` + `img_size`). **Fokus tomat saja** sejak 2026-11-12: model cabai (`chili_classifier.tflite`, EfficientNetB4 380px 6 kelas) dan seluruh kodenya dihapus. File ter-commit di git, dimuat sekali saat startup (`ml-service/app/ml/model_loader.py`, thread-lock per model), sehingga redeploy tidak membutuhkan training ulang. Training dilakukan di Google Colab (`ml-service/agrivision_training.ipynb`); hasil diekspor ke TFLite.
- **Pipeline inferensi** (`ml-service/app/`): `imaging.py` (decode/resize) → `ml/inference.py` (klasifikasi) → `cv/segmentation.py` (mask daun = hijau ∪ lesi) → `cv/affected_area.py` (lesi via HSV, ambang saturasi/value ≥ 60 agar tidak salah deteksi latar coklat) → `cv/severity.py` (aturan di bawah) → `cv/vegetation_index.py` (ExG/VARI) → lookup `disease_reference` → insert ke Supabase (`routers/diagnose.py`).
- **Evaluasi yang sudah ada:** confusion matrix lab di `ml-service/evaluation/confusion_matrix_tomat.png`.
- **BELUM:** evaluasi pada data lapangan (PlantDoc / foto sendiri), metrik precision/recall/F1 terpisah lab vs lapangan, dan kalibrasi `health_score` dengan foto sehat vs sakit nyata. Lihat `08-status-dan-progres.md` bagian 8.
- **Catatan kualitas yang diketahui:** (1) `_EXG_MIN=-0.2` / `_EXG_MAX=0.6` di `cv/vegetation_index.py` adalah placeholder kalibrasi. (2) `affected_area_pct` berbasis ambang warna: pada daun sehat yang berbayang nilainya bisa > 0 sehingga `severity` bukan nol meski diagnosis "Sehat" — validasi dengan foto nyata. (3) VARI dijaga dari penyebut mendekati nol (piksel dengan |G+R−B| < 1e-3 dianggap 0, hasil di-clip ke [−1, 1]).
- **Pengujian yang sudah dilakukan:** E2E `/api/diagnose` di produksi untuk tomat dengan gambar sintetis (status 200, CORS benar, trigger `zone_health_daily` terisi). Belum dengan foto lapangan nyata.

## Modul 1: Diagnosis (Deep Learning)

### Dataset (terverifikasi — lihat `ml-service/agrivision_training.ipynb`)

**Tomat — PlantVillage (via Kaggle "New Plant Diseases Dataset", Chohan et al.)**
Sudah di-split train/valid, 10 kelas persis (jangan diubah nama foldernya, notebook melakukan assertion terhadap daftar ini):
`Bacterial_spot`, `Early_blight`, `Late_blight`, `Leaf_Mold`, `Septoria_leaf_spot`, `Spider_mites Two-spotted_spider_mite`, `Target_Spot`, `Tomato_Yellow_Leaf_Curl_Virus`, `Tomato_mosaic_virus`, `healthy` (prefix `Tomato___` pada nama folder asli). Download otomatis via Kaggle API di notebook (cell Step 1–2).

**Cabai:** dihapus dari scope (2026-11-12). Dataset Roboflow `chili-leaves-disease-classification` (6 kelas, 1.147 gambar) dan riwayat penggantian datasetnya tidak lagi dipakai; model cabai sempat mencapai akurasi validasi 80,69% (terbatas oleh data kecil). Riwayat lengkap ada di git (commit sebelum penghapusan).

**Label penyakit final (dipakai di `disease_reference.disease_label`, dihasilkan otomatis oleh notebook lewat fungsi `slugify()`/`to_disease_label()`):**
- Tomat: `tomato_bacterial_spot`, `tomato_early_blight`, `tomato_late_blight`, `tomato_leaf_mold`, `tomato_septoria_leaf_spot`, `tomato_spider_mites_two_spotted_spider_mite`, `tomato_target_spot`, `tomato_tomato_yellow_leaf_curl_virus`, `tomato_tomato_mosaic_virus`, `tomato_healthy`

**Untuk generalisasi ke kondisi lapangan (bukan hanya foto lab):** tambahkan/gunakan PlantDoc (Singh et al. 2020) sebagai data uji tambahan untuk tomat — akurasi PlantVillage (lab) vs PlantDoc (lapangan) **harus dilaporkan terpisah** di evaluasi, karena keduanya biasanya berbeda signifikan (lihat catatan di `07-referensi.md`).

### Arsitektur Model
- **Tomat:** MobileNetV2 (transfer learning, ImageNet pretrained) — ringan, cocok untuk inference cepat. Referensi: Sharma et al. 2025 (ensemble ResNet50+MobileNetV2 pada 10 kelas tomat, 99.91% akurasi test).
- Satu model tomat. `crop_type` tetap dikirim di API (selalu `tomat`) demi kontrak yang stabil.

### Preprocessing
- Resize ke ukuran input model (224x224 untuk MobileNetV2 — sesuaikan dengan varian yang dipakai; ukuran dibaca dari `img_size` di `label_map.json`).
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

## Rencana training ulang tomat (v2) — status: direncanakan

Alasan: angka validasi 94,33% (MobileNetV2) hanya berlaku untuk foto lab. Dataset sekarang adalah augmentasi offline PlantVillage yang di-split *setelah* augmentasi, sehingga validasi kemungkinan berisi turunan daun yang sama dengan set latih (optimistis), dan set validasi juga dipakai untuk early stopping. **Menambah gambar PlantVillage tidak menaikkan akurasi lapangan** — masalahnya domain, bukan jumlah.

Rencana (detail & status di `08-status-dan-progres.md`):
1. Audit dataset: jumlah per kelas per sumber, deteksi duplikat antar sumber (hash), pemetaan label ke 10 kelas.
2. Basis bersih: PlantVillage asli (non-augmentasi), split sebelum augmentasi; campur data berfoto non-lab (kandidat: PlantDoc subset tomat, Tomato-Village — lisensi dan pemetaan kelas diverifikasi saat implementasi; kelas yang tak bisa dipetakan tidak dipakai).
3. **Set uji lapangan terpisah** (tidak ikut training) dari PlantDoc/Tomato-Village; tidak ada foto lapangan milik sendiri.
4. Augmentasi domain (crop/zoom acak, color jitter, blur), class weight, dua tahap fine-tuning seperti v1; bandingkan MobileNetV2 dengan satu kandidat lebih kuat (mis. EfficientNetB0) dengan batas ukuran TFLite untuk Railway.
5. Pilih model berdasarkan akurasi **uji lapangan**; laporkan metrik lab dan lapangan terpisah (akurasi/P/R/F1, matriks kebingungan, selang Wilson).
6. Ekspor `tomato_classifier.tflite` + `label_map.json` baru (naikkan `model_version`; pertahankan 10 label agar `disease_reference` tetap sinkron), deploy, E2E produksi.
7. Opsional (mengubah kontrak, butuh persetujuan): ambang confidence "perlu verifikasi manual".

Notebook: `ml-service/agrivision_training_tomato_v2.ipynb` (belum dibuat). Training dijalankan user di Colab; integrasi model ke ml-service dikerjakan setelahnya.

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
