# Dataset, Notebook Training, dan Model

Dokumen ini menjawab: data apa yang dipakai, di mana mendapatkannya, notebook mana melakukan apa, bagaimana mengulang eksperimen atau melatih ulang model, dan bagaimana memasang model hasilnya. Angka hasil eksperimen ada di [`05-ml-pipeline.md`](05-ml-pipeline.md); cara menjalankan sistem ada di [`10-panduan-setup-mandiri.md`](10-panduan-setup-mandiri.md).

## 1. Apa yang ada di repositori dan apa yang tidak

| Item | Di repo? | Keterangan |
|---|---|---|
| Model produksi | **Ya** | `ml-service/models/tomato_classifier.tflite` (4,5 MB, v2) + `label_map.json`. Railway dan Docker memakainya langsung; tidak perlu training ulang untuk menjalankan sistem. Model v1 ada di riwayat git (sebelum commit `e005c93`). |
| Notebook training/eksperimen | **Ya** | 10 berkas `ml-service/*.ipynb` (tabel bagian 3). |
| Hasil mentah eksperimen | **Ya** | `ml-service/results/` (`v4_partial_results.csv`, `v4b_results.csv`, `metrics_v6_prod_v2.json`), `ml-service/evaluation/confusion_matrix_tomat.png`. Keluaran sel notebook sudah dikosongkan; angka ringkasnya ada di `05-ml-pipeline.md`. |
| Dataset mentah | **Tidak** | Besar (PlantVillage ±2,2 GB) dan berlisensi masing-masing. Notebook mengunduhnya sendiri saat dijalankan (bagian 2). |
| Bobot Keras (`.keras`, `.h5`) | **Tidak** | Di-gitignore dan tidak diunduh dari Colab; hanya TFLite hasil ekspor yang disimpan. Untuk bobot Keras, latih ulang notebook. |
| Foto lapangan milik Argy (`Foto daun real/`), unduhan lokal (`Dataset lapangan/`) | **Tidak** | Privasi, belum berlabel, atau lisensi tidak mengizinkan redistribusi; di-gitignore. **Tidak diperlukan** untuk menjalankan sistem maupun notebook. |

## 2. Sumber dataset

Semua notebook modern (v2–v6) mengambil data langsung dari sumbernya; tidak ada unggah manual.

| Dataset | Peran | Sumber | Lisensi | Catatan |
|---|---|---|---|---|
| **PlantVillage** (Hughes & Salathé 2015; Mohanty dkk. 2016) | foto laboratorium: `lab_train` / `lab_val` / `lab_test` | Hugging Face `mohanty/PlantVillage`, berkas `data.zip` (±2,2 GB), `leaf_grouping/leaf-map.json`, `splits/color_{train,test}.txt` | CC BY-SA 3.0 | Dibaca sebagai berkas mentah (bukan `load_dataset`: dataset berbasis skrip gagal di `datasets` terbaru). Split per **daun** (`leaf_id`) supaya satu daun tidak muncul di latih dan uji. |
| **PlantDoc** (Singh dkk. 2020) | foto non-lab (web): `field_train` 369 / `field_val` 130 / `field_test` 216 | Hugging Face `Project-AgML/plant_doc_classification` | CC BY-SA 4.0 | 8 kelas tomat dipetakan ke 10 label kita; Target Spot tidak ada dan spider mites hanya 2 gambar (dikecualikan), jadi dua kelas itu tanpa uji lapangan. |
| **Tomato-Village** (Gehlot, Saxena & Gandhi 2023) | foto kebun asli (India): uji eksternal dan, di komposisi C/D, data latih | GitHub `mamta-joshi-gehlot/Tomato-Village`, varian-a (multiclass); notebook meng-`git clone` secara sparse | repo tanpa lisensi tertulis, jadi hanya riset dan wajib sitasi | Hanya 3 kelas yang bisa dipetakan (Early_blight, Late_blight, healthy); setelah pembuangan near-duplicate dHash tersisa 1.457 gambar (uji 116, validasi 211). |
| Mendeley "Tomato Leaf Dataset" (Imtiaz dkk. 2025) | **tidak dipakai** | doi 10.17632/bpfd9cns5g.2 | CC BY 4.0 | Anotasi kotak tanpa `data.yaml`, id kelas tidak bisa dipetakan pasti. |
| Kaggle "New Plant Diseases Dataset" (`vipoooool/new-plant-diseases-dataset`) | hanya notebook v1 (usang) | Kaggle API (butuh `kaggle.json`) | — | Augmentasi offline PlantVillage yang di-split sesudah augmentasi, jadi validasinya optimistis. Alasan utama notebook baru memakai split per daun. |

10 kelas model (urutan indeks 0–9 tetap, sama dengan `label_map.json`; jangan diubah karena `disease_reference` memakai label yang sama): `Bacterial_spot`, `Early_blight`, `Late_blight`, `Leaf_Mold`, `Septoria_leaf_spot`, `Spider_mites Two-spotted_spider_mite`, `Target_Spot`, `Tomato_Yellow_Leaf_Curl_Virus`, `Tomato_mosaic_virus`, `healthy`.

## 3. Peta notebook

Semua dijalankan di **Google Colab** (Runtime → Run all). Notebook meng-`git clone` repo ini ke `/content/agrivision` untuk memakai modul `ml-service/app/ml/enhance.py`; bila Anda memakai fork, ganti URL kloningnya pada sel setup.

| Notebook | Isi | Runtime | Status / hasil |
|---|---|---|---|
| `agrivision_training.ipynb` | **v1 (usang)**: tomat + cabai, Kaggle + Roboflow, API key | GPU | Menghasilkan model v1 (di riwayat git). Cabai sudah dihapus dari proyek; jangan dipakai ulang. |
| `agrivision_training_tomato_v2.ipynb` | Training ulang tomat 12 Nov 2026: split bersih per daun, PlantVillage + PlantDoc, MobileNetV2 vs EfficientNetB0, uji lapangan terpisah | GPU T4 | Dijalankan; tidak dipasang di produksi. Nama "v2" di sini ≠ model produksi v2. Hasil di `05` bagian "Hasil training v2". |
| `agrivision_experiment_preprocessing_v3.ipynb` | Ablasi pra-pemrosesan (CLAHE, Shades-of-Gray, unsharp, penekanan latar; 7 varian, 3 seed) | GPU T4 | Hasil nol: tidak menaikkan akurasi lapangan. |
| `agrivision_experiment_external_v3b.ipynb` | Uji eksternal Tomato-Village pada model v3 | GPU T4 | Parsial (kuota GPU habis); model di bawah tebakan mayoritas. |
| `agrivision_experiment_v4_data_arch.ipynb` | Komposisi data latih (A–D) dan arsitektur, **fine-tuning**, 3 seed | GPU T4 | 9 dari 24 model selesai (kuota habis); `results/v4_partial_results.csv`. |
| `agrivision_experiment_v4b_resume.ipynb` | Menyelesaikan sisa v4 (12 model total terverifikasi, 3 seed) | GPU T4 | Selesai; `results/v4b_results.csv`. Dasar Tabel 5 dan 6 naskah. |
| `agrivision_experiment_v5_cpu_frozen.ipynb` | Versi **backbone beku** dari v4 (5 seed) | CPU | Selesai; angka mutlak tidak sebanding dengan fine-tuning. |
| `agrivision_experiment_v5b_effb0.ipynb` | EfficientNetB0 beku, komposisi A–D | CPU (±39 menit ekstraksi fitur) | Selesai. |
| `agrivision_production_v6_tomato.ipynb` | **Model produksi v2**: MobileNetV2, komposisi D (75% lab + 12,5% PlantDoc + 12,5% Tomato-Village), 1 seed, ekspor TFLite float16 | GPU T4 | Dipasang di produksi 2026-11-17. Metrik: `results/metrics_v6_prod_v2.json`. |
| `agrivision_experiment_v8_skenario_dataset.ipynb` | **Revisi dataset sesuai arahan dosen**: ketiga dataset digabung **per kelas** (10 kelas; kelas tanpa data tambahan tetap), pembagian **70/10/20 per kelas per dataset** (PlantVillage per daun; split resmi PlantVillage/Tomato-Village tidak dipakai), near-duplicate dibuang sebelum dibagi. Dua skenario: **lab saja** vs **gabungan (gabung polos, tanpa porsi batch)**, 3 seed, resep training sama dengan Tabel 2 naskah. Mencetak Tabel A (per dataset), B (per skenario), C–F (akurasi, F1, McNemar, per kelas) + confusion matrix; hasil per model disimpan ke Drive (`MyDrive/AgriVision_v8`) dan dilanjutkan otomatis bila sesi putus | GPU T4, ±1,5–2,5 jam | Dibuat 2026-11-27; diuji dry-run lokal dengan data sintetis. **Belum dijalankan di Colab.** Pembagiannya berbeda dari v3–v6, jadi angkanya tidak bisa dicampur dengan Tabel 1/5 naskah lama. |

Kuota GPU gratis Colab terbatas: v4 (24 model) tidak selesai dalam satu kuota sehingga dipecah menjadi v4b; v6 (satu model) cukup. Dua kali menjalankan seed yang sama memberi hasil berbeda (nondeterminisme GPU), jadi angka satu run bukan angka pasti.

## 4. Mengulang atau melatih ulang model

1. Buka notebook di Colab (File → Upload notebook, atau dari GitHub), pilih Runtime → T4 GPU.
2. Runtime → Run all. Notebook mengunduh PlantVillage, PlantDoc, dan Tomato-Village, membangun split, melatih, mengekspor TFLite, dan memverifikasinya terhadap Keras.
3. Sel terakhir memicu unduhan zip (`model_v6.zip` untuk notebook produksi) berisi `tomato_classifier.tflite`, `label_map.json`, `metrics_v6.json`. **Unduh segera**: runtime yang terputus menghapus semua berkas di `/content` (pernah terjadi: model run pertama hilang).
4. Jangan memilih opsi "tanpa GPU" pada dialog kuota bila ingin fine-tuning; itu mengubah protokol.

## 5. Memasang model baru ke sistem

1. Ekstrak zip, salin `tomato_classifier.tflite` dan `label_map.json` ke `ml-service/models/` (ganti yang lama).
2. Pastikan `label_map.json` memuat kunci `tomato` dengan **10 kelas dalam urutan yang sama** dan `img_size` + `model_version` yang benar. Bila jumlah/urutan kelas berubah, `disease_reference` dan seluruh kontrak ikut berubah (butuh persetujuan; lihat `CLAUDE.md`).
3. Uji lokal: `cd ml-service && pytest tests/test_schemas.py tests/test_cv_quality.py tests/test_enhance.py`, lalu `python scripts/predict_local.py <beberapa foto>`.
4. Preprocessing: model mengharapkan masukan **mentah 0–255** (`preprocess_input` MobileNetV2 sudah di dalam graf); `app/ml/inference.py` tidak membagi 255. Model dengan konvensi lain harus diekspor dengan preprocessing di dalam graf.
5. Commit lalu push ke `main` → Railway membangun ulang. Verifikasi `GET /api/health` melaporkan `model_version` baru. Rollback: `git revert` commit pemasangan.

## 6. Menambah dataset sendiri

- Tambahkan sumber baru sebagai komposisi baru di notebook (mengikuti pola komposisi A–D) dan **pisahkan set uji** dari set latih (bandingkan hash perseptual; notebook sudah memuat dHash).
- Pilih model berdasarkan set validasi, bukan set uji; laporkan akurasi lab dan lapangan terpisah.
- Pemetaan label ke 10 kelas harus diverifikasi; kelas yang tidak bisa dipetakan jangan dimasukkan.
- Foto kebun sendiri yang berlabel adalah data yang paling dibutuhkan (lihat `08-status-dan-progres.md`). Jangan commit foto ke repo publik tanpa memikirkan privasi dan lisensi.
