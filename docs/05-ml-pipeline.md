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

### Wilayah daun, objek non-daun, dan kualitas foto (diubah 2026-11-12)
Pengujian pada foto kebun nyata (daun dipegang tangan, buah dan ajir di latar) menunjukkan dua masalah: (1) ambang HSV lesi menangkap kulit tangan, ajir, tangkai, dan buah jingga sehingga luas terdampak membengkak (28–52% pada daun yang tampak hampir sehat; mask lesi menandai telapak tangan), dan (2) model klasifikasi memberi keyakinan 87–98% pada penyakit yang kemungkinan keliru. Perbaikan di `app/cv/`:
- `leaf_region.py`: piksel berwarna buah matang (jingga jenuh & terang) bukan lesi; lesi hanya dihitung di dalam **wilayah daun** (hijau yang ditutup secara morfologis, lubang yang terkurung diisi); pembukaan morfologi kecil membuang garis tipis; bila piksel hijau < 15% foto (daun sangat nekrotik) wilayah daun juga memakai piksel lesi (perilaku lama).
- `segmentation.py`: syarat ExG minimum 0,02 — sebelumnya gambar seragam (dinding polos, foto gelap) menghasilkan "100% vegetasi" karena ambang Otsu ≈ 0.
- `photo_quality.py`: penilaian kelayakan foto. Foto tanpa wilayah daun (< 3%) ditolak dengan HTTP 400; masalah lain (foto dipenuhi dedaunan ≥ 70%, objek non-daun ≥ 8%, daun terlalu kecil < 15%, keyakinan < 60%) hanya memberi peringatan di `warning_note`.
- Validasi (heuristik, bukan anotasi pakar): 18 foto lab PlantVillage tomat acak — tidak ada peringatan "latar ramai" (wilayah daun 10–59%), hanya 1 peringatan "daun terlalu kecil" yang memang benar; luas terdampak turun sedikit dibanding versi lama (mis. 23,5→13,2%, 13,9→10,9%), daun sangat nekrotik tetap tinggi (71,8→63,3%). 9 foto nyata (wilayah daun 78–100%) semuanya mendapat peringatan "latar ramai"; luas terdampak foto tomat turun dari 30–53% menjadi 28–44%.
- **Keterbatasan:** foto kebun tetap menghasilkan luas terdampak yang tinggi (daun latar, tangkai, dan buah di latar ikut terhitung) — peringatan memang dimaksudkan memberi tahu bahwa angka itu kurang andal. Model klasifikasi **tidak punya penolakan "bukan daun tomat"**: foto cabai dibaca sebagai penyakit tomat dengan keyakinan tinggi. Solusi yang lebih benar adalah kelas negatif (non-tomat) saat training dan anotasi lesi piksel untuk validasi.

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

## Training ulang tomat (v2) — status: sudah dijalankan di Colab (2026-11-12), BELUM di-deploy

Alasan: angka validasi 94,33% (MobileNetV2) hanya berlaku untuk foto lab. Dataset sekarang adalah augmentasi offline PlantVillage yang di-split *setelah* augmentasi, sehingga validasi kemungkinan berisi turunan daun yang sama dengan set latih (optimistis), dan set validasi juga dipakai untuk early stopping. **Menambah gambar PlantVillage tidak menaikkan akurasi lapangan** — masalahnya domain, bukan jumlah.

Rencana (detail & status di `08-status-dan-progres.md`):
1. Audit dataset: jumlah per kelas per sumber, deteksi duplikat antar sumber (hash), pemetaan label ke 10 kelas.
2. Basis bersih: PlantVillage asli non-augmentasi lewat Hugging Face `mohanty/PlantVillage` (config `color`, CC BY-SA 3.0, punya kolom `leaf_id`, split 80/20 per daun; `lab_val` dipisah lagi per `leaf_id`). Data non-lab: PlantDoc lewat `Project-AgML/plant_doc_classification` (CC BY-SA 4.0, 2.569 gambar/28 kelas; 8 kelas tomat dipetakan ke 10 label kita). Target Spot tidak ada di PlantDoc dan spider mites hanya 2 gambar (dikecualikan) → kedua kelas tanpa uji lapangan.
3. **Set uji lapangan terpisah** (`field_test` ±30% PlantDoc, stratified, tidak ikut training, near-duplicate lintas set dibuang dengan dHash); tidak ada foto lapangan milik sendiri. Tomato-Village tidak dipakai (tidak berhasil diverifikasi).
4. Augmentasi domain (crop/zoom acak, color jitter, blur), class weight, dua tahap fine-tuning seperti v1; bandingkan MobileNetV2 dengan satu kandidat lebih kuat (mis. EfficientNetB0) dengan batas ukuran TFLite untuk Railway.
5. Pilih model berdasarkan akurasi **uji lapangan**; laporkan metrik lab dan lapangan terpisah (akurasi/P/R/F1, matriks kebingungan, selang Wilson).
6. Ekspor `tomato_classifier.tflite` + `label_map.json` baru (naikkan `model_version`; pertahankan 10 label agar `disease_reference` tetap sinkron), deploy, E2E produksi.
7. Opsional (mengubah kontrak, butuh persetujuan): ambang confidence "perlu verifikasi manual".

### Hasil training v2 (dijalankan 2026-11-12 di Colab T4, notebook `agrivision_training_tomato_v2.ipynb`)

Data: `lab_train` 12.997 / `lab_val` 1.519 / `lab_test` 3.639 (PlantVillage asli, split per daun) dan `field_train` 369 / `field_val` 130 / `field_test` 216 (PlantDoc tomat). Kelas Target Spot dan spider mites tidak punya data lapangan. Dua kandidat dilatih (basis beku ≤12 epoch + fine-tuning 30 lapisan ≤10 epoch).

| Model | `lab_val` | `field_val` (n=130) |
|---|---|---|
| MobileNetV2 v2 | 72,75% | 39,23% |
| EfficientNetB0 v2 (terpilih) | 85,52% | 49,23% |

Uji akhir, set yang sama untuk kedua model (model v1 = `tomato_classifier.tflite` produksi saat ini):

| | `lab_test` (n=3.639, split per daun) | `field_test` (n=216, PlantDoc) |
|---|---|---|
| **v1** (MobileNetV2, produksi) | 94,45% (*) | **25,93%** (CI95 20,5–32,2; F1 makro 16,97%) |
| **v2** (EfficientNetB0) | 85,90% | **45,37%** (CI95 38,9–52,0; F1 makro 41,31%) |

(*) Angka lab v1 **tidak bersih**: v1 dilatih pada augmentasi PlantVillage yang kemungkinan berasal dari gambar/daun yang sama dengan `lab_test`; hanya `field_test` yang benar-benar adil untuk membandingkan v1 dan v2 (v1 tidak pernah melihat PlantDoc; v2 hanya melihat `field_train`, bukan `field_test`).

Temuan dan caveat:
- **Akurasi lapangan v1 hanya ±26%** pada foto non-lab (angka 94,33% di naskah hanya berlaku untuk foto lab). v2 menaikkannya ke ±45%, tapi tetap rendah.
- v2 kemungkinan **under-trained** (akurasi latih ±75–78% saat berhenti: augmentasi kuat, LR fine-tuning 1e-5, epoch terbatas). Ruang perbaikan masih ada (augmentasi lebih ringan, LR fine-tuning lebih besar, epoch lebih banyak, lebih banyak data lapangan); angka di atas belum merupakan batas atas v2.
- `field_test` kecil (216) dan dari satu sumber (PlantDoc); selang kepercayaan lebar dan mengasumsikan gambar independen.
- Model v2 **belum di-deploy**. TFLite v2: 8,15 MB (float16), kesepakatan argmax dengan Keras 100%; kuantisasi dinamis int8 (default v1) merusak EfficientNetB0 (hanya 92,7% sepakat, selisih probabilitas hingga 0,69).
- Bug notebook yang ditemukan saat benar-benar dijalankan dan sudah diperbaiki: `load_dataset("mohanty/PlantVillage","color")` tidak bisa (dataset berbasis skrip → file mentah dibaca langsung), import `load_dataset` hilang, `GaussianNoise` Keras 3 hanya menerima stddev 0–1, augmentasi di `tf.data` (CPU) ±10× lebih lambat daripada di dalam model (GPU), dan `from_keras_model` + kuantisasi dinamis untuk TFLite.

Notebook: `ml-service/agrivision_training_tomato_v2.ipynb` (dibuat 2026-11-12; tanpa API key; sintaks sudah dicek tapi **belum pernah dijalankan** di Colab). Dua kandidat: MobileNetV2 dan EfficientNetB0 (224px); model dipilih dari akurasi `field_val`, uji akhir sekali pada model terpilih, plus perbandingan dengan v1 pada set uji yang sama dan verifikasi TFLite vs Keras (≥97% argmax sama). Keluaran: `tomato_classifier.tflite`, `label_map.json` (kunci `tomato`, 10 label identik dengan v1), `metrics.json`, matriks kebingungan. Training dijalankan user di Colab; integrasi model ke ml-service dikerjakan setelahnya. Jangan deploy bila akurasi lapangan v2 tidak lebih baik dari v1.

---

## Ablasi pra-pemrosesan citra pada MobileNetV2 (v3, dijalankan 2026-11-15/16 di Colab T4)

Notebook: `ml-service/agrivision_experiment_preprocessing_v3.ipynb` (modul `app/ml/enhance.py`). Data = v2 (lab: PlantVillage split per daun, 12.997/1.519/3.639 gambar latih/val/uji; lapangan: PlantDoc 369/130/216). MobileNetV2 224px, dua tahap (kepala 8 epoch, lalu 60 lapisan atas dibuka dengan BatchNorm dibekukan, ≤15 epoch), augmentasi dan hiperparameter identik untuk semua varian; 7 varian × seed 42, lalu baseline + 2 varian terbaik (menurut `field_val`) × seed 1 dan 2.

**Seed 42, semua varian (akurasi %):**

| Varian | lab_test | field_test (PlantDoc, n=216) | field_val |
|---|---|---|---|
| none (baseline) | 95,41 | 50,00 | 46,15 |
| clahe | 93,49 | 52,31 | 47,69 |
| sog (Shades-of-Gray) | 95,71 | 50,46 | 48,46 |
| unsharp | 94,37 | 54,63 | 49,23 |
| bg (penekanan latar) | 95,58 | 46,76 | 45,38 |
| sog_clahe | 95,58 | 45,83 | 48,46 |
| bg_sog_clahe | 94,81 | 46,76 | 44,62 |

**Tiga seed (rata-rata ± simpangan baku):**

| Varian | lab_test acc | lab_test F1 makro | field_test acc | field_test F1 makro | field_val acc |
|---|---|---|---|---|---|
| none | 94,97 ± 0,31 | 93,26 ± 0,21 | 56,48 ± 4,58 | 55,75 ± 2,72 | 46,67 ± 0,73 |
| sog | 95,49 ± 1,11 | 94,50 ± 1,08 | 51,70 ± 2,08 | 49,87 ± 2,60 | 43,85 ± 3,77 |
| unsharp | 94,84 ± 0,54 | 93,38 ± 1,04 | 54,17 ± 1,73 | 53,52 ± 1,43 | 48,97 ± 0,98 |

**Uji berpasangan terhadap baseline (seed 42, McNemar):** pada `field_test` semua selisih tidak signifikan (p 0,20–1,00; selisih −4,2 s.d. +4,6 poin, CI bootstrap mencakup 0). Pada `lab_test`, CLAHE (−1,92 poin, p < 0,001) dan unsharp (−1,04 poin, p = 0,016) justru sedikit lebih buruk; varian lain netral (selisih ≤ 0,6 poin).

**Kesimpulan (hasil nol, dilaporkan apa adanya):** tidak ada varian pra-pemrosesan yang meningkatkan akurasi lapangan secara bermakna. Variansi antarseed baseline pada `field_test` (50,0–59,7%, simpangan baku 4,6 poin) lebih besar daripada semua selisih antarvarian, jadi perbandingan satu-seed tidak boleh ditafsirkan sebagai keunggulan. Akurasi lab baseline (±95%, split bersih per daun) jauh lebih tinggi daripada lapangan (±50–60%): kesenjangan domain tetap menjadi masalah utama dan tidak diselesaikan oleh enhancement.

Baseline per kelas pada `lab_test` (seed 42; presisi/recall/F1 %): Bacterial_spot 99,0/91,1/94,9; Early_blight 86,3/90,7/88,4; Late_blight 97,8/95,5/96,6; Leaf_Mold 81,1/100/89,6; Septoria 89,3/91,4/90,3; Spider_mites 91,6/98,4/94,9; Target_Spot 96,0/91,7/93,8; TYLCV 99,9/98,2/99,0; ToMV 98,2/80,3/88,3; healthy 98,5/100/99,3.

### Uji eksternal Tomato-Village (v3b, 2026-11-15) — PARSIAL, terhenti karena kuota GPU Colab

Notebook: `ml-service/agrivision_experiment_external_v3b.ipynb`. Set uji = Tomato-Village varian-a (Gehlot dkk., 2023; foto kebun asli), hanya 3 kelas yang bisa dipetakan: Early_blight 496, Late_blight 904, healthy 216 (n = 1.616; near-duplicate terhadap data latih = 0). Model tetap 10 kelas, prediksi di luar 3 kelas dihitung salah. Tomato-Village tidak pernah dipakai untuk melatih atau memilih model. **Pembanding wajib: menebak "Late_blight" untuk semua gambar sudah 55,9%.**

Runtime Colab terputus (batas penggunaan GPU) setelah 5 dari 9 model selesai; model tersimpan di `/content/models` ikut hilang, sehingga tidak ada uji McNemar, F1 makro, maupun recall per kelas untuk set eksternal. Varian `sog` dan `unsharp` seed 2 belum berjalan. Akurasi (%) dari log yang sempat terbaca:

| Varian | Seed | lab_test | PlantDoc field_test | Tomato-Village |
|---|---|---|---|---|
| none | 42 | 96,48 | 53,70 | 40,72 |
| none | 1 | 94,89 | 53,24 | 47,09 |
| none | 2 | 96,81 | 56,94 | 35,71 |
| unsharp | 42 | 93,79 | 57,41 | 50,00 |
| unsharp | 1 | 94,17 | 51,85 | 40,97 |

Rata-rata baseline (3 seed): lab 96,06; PlantDoc 54,63; Tomato-Village 41,17 ± 4,66. Unsharp (2 seed): lab 93,98; PlantDoc 54,63; Tomato-Village 45,49.

Temuan yang aman dilaporkan: (1) di foto kebun asli, **model berada di bawah baseline mayoritas (55,9%)** untuk kelima model — kesenjangan lab→lapangan lebih parah daripada yang terlihat di PlantDoc; (2) variasi antarseed baseline di Tomato-Village (35,7–47,1%) jauh lebih besar daripada selisih baseline vs unsharp, jadi tidak ada klaim keunggulan varian; (3) seed 42 yang sama memberi hasil berbeda antara v3 dan v3b (baseline lab 95,41 vs 96,48; PlantDoc 50,00 vs 53,70) karena nondeterminisme GPU/pipeline — satu run tidak dapat diulang persis, sehingga hanya rata-rata multi-seed yang layak dilaporkan. Untuk menyelesaikan: jalankan ulang v3b setelah kuota GPU pulih (atau di platform lain), dengan keluaran Step 11–12 disimpan segera.

### Ablasi komposisi data latih — protokol backbone beku (v5, runtime CPU, 2026-11-15) — Bagian 1 selesai

Notebook: `ml-service/agrivision_experiment_v5_cpu_frozen.ipynb`. **Protokol berbeda dari v3/v3b/v4:** kuota GPU habis, sehingga MobileNetV2 (ImageNet) **dibekukan**, fitur diekstrak sekali (tanpa augmentasi, tanpa fine-tuning) dan hanya kepala linear (Dropout 0,3 + Dense softmax) yang dilatih (Adam 1e-3, ≤40 epoch × 200 langkah × batch 64, early stopping pada validasi gabungan sumber yang dipakai, class weight). **Akurasi mutlak tidak sebanding dengan v3** (lab 89–92% vs 95–97% pada fine-tuning); yang bermakna adalah selisih antar kondisi *dalam protokol yang sama*. Komposisi (porsi data lapangan dalam batch dijaga 25%): A = lab saja; B = lab 75% + PlantDoc 25%; C = lab 75% + Tomato-Village 25%; D = lab 75% + PlantDoc 12,5% + Tomato-Village 12,5%. Tomato-Village dibagi mengikuti split resmi (train/val/test) lalu near-duplicate (dHash ≤ 3) dibuang terhadap data lain dan antar-split: test 164→116, val 322→211, total 1.616→1.457 gambar — split resmi ternyata mengandung banyak gambar mirip. Tebakan mayoritas: `tv_test` 49,14% (n = 116), `tv_all` 54,63% (n = 1.457). `tv_all` hanya sah untuk A dan B (tidak dilatih dengan Tomato-Village). 5 seed per kondisi; rata-rata ± simpangan baku (populasi), akurasi %:

| Komposisi | lab_test | PlantDoc field_test (n=216) | Tomato-Village test (n=116) | Tomato-Village semua (n=1.457) |
|---|---|---|---|---|
| A lab saja | 91,58 ± 0,38 | 28,52 ± 0,70 | 41,03 ± 2,01 | 47,89 ± 0,95 |
| B lab + PlantDoc | 89,23 ± 0,58 | 43,52 ± 2,29 | 32,07 ± 2,75 | 38,20 ± 2,66 |
| C lab + Tomato-Village | 90,81 ± 0,22 | 25,28 ± 0,63 | 89,31 ± 0,88 | (tidak sah) |
| D lab + keduanya | 89,56 ± 0,45 | 42,50 ± 1,84 | 87,93 ± 2,38 | (tidak sah) |

Pola (konsisten di kelima seed): (1) data **dari domain yang sama dengan set uji** menaikkan akurasi sumbernya sangat besar (PlantDoc 28,5 → 43,5 dengan PlantDoc di data latih; Tomato-Village 41 → 89 dengan Tomato-Village di data latih); (2) data lapangan **dari sumber lain tidak menolong dan dapat merugikan**: menambah PlantDoc menurunkan Tomato-Village (41,0 → 32,1 pada `tv_test`; 47,9 → 38,2 pada `tv_all`), menambah Tomato-Village tidak menaikkan PlantDoc (28,5 → 25,3); (3) menambah data lapangan menurunkan akurasi lab 1–2 poin; (4) tanpa data in-domain, model berada di bawah tebakan mayoritas pada Tomato-Village (A: 47,9% vs 54,6%). **Peringatan tafsir:** angka 88–89% pada `tv_test` untuk C/D adalah evaluasi dalam sumber yang sama dan kemungkinan terinflasi oleh kemiripan antar-foto Tomato-Village (dedupe hanya membuang kembaran dekat, bukan kemiripan adegan/tanaman); jangan dilaporkan sebagai akurasi lapangan umum, dan `tv_test` kecil (n = 116, ±9 poin pada tingkat kepercayaan 95%). **Uji McNemar berpasangan per seed** (seed sama, baris `RESULT|` yang tercetak notebook; selisih dalam poin akurasi, p dua sisi binomial eksak): A→B di PlantDoc +12,0 s.d. +17,6 poin, signifikan di kelima seed (p ≤ 0,005); A→D di PlantDoc +12,0 s.d. +15,7, signifikan di kelima seed. A→B di `tv_test` −6,0 s.d. −17,2 poin dengan arah negatif konsisten tetapi signifikan hanya di 3 dari 5 seed (p = 0,000; 0,039; 0,021; sisanya 0,118–0,143, `tv_test` kecil). A→C di PlantDoc −1,9 s.d. −4,6 poin, tidak signifikan di semua seed (p 0,11–0,56). A→C dan A→D di `tv_test` +44 s.d. +52 poin (p < 0,001), efek in-domain.

**Bagian 2 — arsitektur pada komposisi B (lab + PlantDoc)**, backbone beku: kepala linear di atas fitur terpooling; SE dan CBAM di atas peta fitur terakhir MobileNetV2 (7×7×1280; SE ±219 ribu parameter, CBAM ±219 ribu, kepala linear 12.810); MobileNetV3-Large linear (9.610 parameter). Akurasi % (rata-rata ± simpangan baku; F1 makro dihitung pada kelas yang ada di set):

| Kepala / backbone | seed | lab_test | PlantDoc acc (F1) | Tomato-Village test acc (F1) | Tomato-Village semua |
|---|---|---|---|---|---|
| MobileNetV2 linear | 5 | 89,23 ± 0,58 | 43,52 ± 2,29 (41,25) | 32,07 ± 2,75 (23,70) | 38,20 ± 2,66 |
| MobileNetV2 + SE | 3 | 92,91 ± 0,20 | 41,98 ± 2,57 (39,92) | 29,31 ± 2,54 (24,36) | 38,60 ± 3,78 |
| MobileNetV2 + CBAM | 3 | 91,60 ± 0,58 | 42,75 ± 1,16 (40,01) | 33,33 ± 2,93 (25,62) | 39,90 ± 5,37 |
| MobileNetV3-Large linear | 5 | 93,77 ± 0,40 | 45,46 ± 1,15 (45,51) | 32,41 ± 1,29 (29,74) | 34,01 ± 2,26 |

Attention dan backbone yang lebih kuat menaikkan akurasi **lab** 2–4,5 poin, tetapi **tidak menaikkan akurasi lapangan**: McNemar terhadap MobileNetV2 linear pada PlantDoc tidak signifikan untuk SE, CBAM, maupun MobileNetV3 di seed mana pun (p ≥ 0,105); pada `tv_test` hanya CBAM seed 42 yang signifikan (+9,5 poin, p = 0,013) dan tidak terulang di seed 1 dan 2 (−3,4 dan 0,0). MobileNetV3-Large linear memberi F1 makro PlantDoc lebih tinggi (45,5 vs 41,3) tetapi selisih akurasinya tidak signifikan. EfficientNetB0 **tidak selesai**: runtime Colab terputus saat ekstraksi fiturnya baru dimulai dan cache fitur ikut hilang; ConvNeXt-Tiny tidak dijalankan. Catatan: ringkasan dan McNemar di atas dihitung ulang dari baris `RESULT|` yang tersimpan di keluaran notebook (Step 15–16 tidak sempat jalan); kepala SE/CBAM hanya 3 seed.

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
