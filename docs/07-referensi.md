# Referensi Akademik

25 referensi terverifikasi, dikelompokkan per modul sistem. Diambil dari riset literatur untuk proyek ini — gunakan sebagai basis sitasi di proposal/laporan TA (cek ulang format sitasi sesuai pedoman skripsi IPB/TRPL).

## Prioritas Sitasi
1. **Wajib (inti kredibilitas):** #1 (Mohanty/PlantVillage), #19 (MobileNetV2), #20 (EfficientNet), #9 (Woebbecke/ExG), #10 (Gitelson/VARI), #16 (Agriculture 4.0).
2. **Kedalaman modul:** #2, #5, #6, #7, #8 (spesifik tomat/cabai); #11, #12, #13 (validasi RGB index); #17, #18 (lapisan rekomendasi).
3. **Landasan teori / related work:** #3, #4, #14, #15.

---

## Modul 1 — Deteksi Penyakit (Deep Learning)

1. Mohanty, S. P., Hughes, D. P., & Salathé, M. (2016). Using Deep Learning for Image-Based Plant Disease Detection. *Frontiers in Plant Science*, 7, 1419. DOI: 10.3389/fpls.2016.01419 — https://www.frontiersin.org/journals/plant-science/articles/10.3389/fpls.2016.01419/full — *Paper benchmark PlantVillage (54.306 gambar, 38 kelas, akurasi hingga 99.35%). Wajib untuk sitasi dataset.*

2. Singh, D., Jain, N., Jain, P., Kayal, P., Kumawat, S., & Batra, N. (2020). PlantDoc: A Dataset for Visual Plant Disease Detection. *Proceedings of the 7th ACM IKDD CoDS and 25th COMAD*, 249–253. DOI: 10.1145/3371158.3371196 — https://dl.acm.org/doi/10.1145/3371158.3371196 (preprint terbuka: https://arxiv.org/abs/1911.10317) — *Dataset "in-the-wild" (2.598 gambar, 13 spesies, 17 kelas) untuk generalisasi ke kondisi lapangan.*

3. Ferentinos, K. P. (2018). Deep learning models for plant disease detection and diagnosis. *Computers and Electronics in Agriculture*, 145, 311–318. DOI: 10.1016/j.compag.2018.01.009 — *Benchmark 5 arsitektur CNN pada 87.848 gambar, 58 kelas. (Berbayar di Elsevier, abstrak gratis.)*

4. Saleem, M. H., Potgieter, J., & Arif, K. M. (2019). Plant Disease Detection and Classification by Deep Learning. *Plants*, 8(11), 468. Open access. DOI: 10.3390/plants8110468 — https://www.mdpi.com/2223-7747/8/11/468 — *Review komprehensif, bagus untuk bab tinjauan pustaka.*

5. Sharma, Al-Huqail, Almogren, et al. (2025). Deep learning based ensemble model for accurate tomato leaf disease classification by leveraging ResNet50 and MobileNetV2 architectures. *Scientific Reports*, 15, 13904. Open access. DOI: 10.1038/s41598-025-98015-x — https://www.nature.com/articles/s41598-025-98015-x — *11.000 gambar tomat, 10 kelas, ensemble ResNet50+MobileNetV2 akurasi 99.91%. Justifikasi arsitektur modul tomat.*

6. Pratap, V. K., & Kumar, N. S. (2023). High-precision multiclass classification of chili leaf disease through customized EfficientNetB4. *Smart Agricultural Technology*, 5, 100285. DOI: 10.1016/j.atech.2023.100285 — *EfficientNetB4 kustom ("EfficientLeafNetB4") unggul atas ResNet-50/DenseNet-121/MobileNetV2/VGG-16 pada 5 kelas cabai. (Berbayar, abstrak gratis.)*

7. Bezabh, Y. A., Salau, A. O., Abuhayi, B. M., Mussa, A. A., & Ayalew, A. M. (2023). CPD-CCNN: classification of pepper disease using a concatenation of convolutional neural network models. *Scientific Reports*, 13(1), 15581. Open access. DOI: 10.1038/s41598-023-42843-2 — https://www.nature.com/articles/s41598-023-42843-2 — *Model VGG16+AlexNet untuk pepper/cabai, akurasi testing 95.82%. Catatan: nama penulis yang benar "Bezabh" (bukan "Bezabih").*

8. Usamah Putra, dkk. (2024). Deteksi Penyakit Pada Daun Cabai Menggunakan Metode Convolutional Neural Network. *JATISI*, 11(4), 486–494. Open access — https://jurnal.mdp.ac.id/index.php/jatisi/article/view/8310 — *Studi CNN konteks Indonesia untuk cabai, akurasi validasi 82%. Relevan untuk konteks lokal. Lihat juga studi MALCOM terkait (cabai+tomat, CNN web-app): https://journal.irpi.or.id/index.php/malcom/article/view/1989*

## Modul 2 — Pemantauan Kesehatan (Vegetation Index RGB)

9. Woebbecke, D. M., Meyer, G. E., Von Bargen, K., & Mortensen, D. A. (1995). Color indices for weed identification under various soil, residue, and lighting conditions. *Transactions of the ASAE*, 38(1), 259–269. DOI: 10.13031/2013.27838 — *Paper asal Excess Green Index (ExG = 2G-R-B). Sitasi wajib untuk ExG.*

10. Gitelson, A. A., Kaufman, Y. J., Stark, R., & Rundquist, D. (2002). Novel algorithms for remote estimation of vegetation fraction. *Remote Sensing of Environment*, 80(1), 76–87. DOI: 10.1016/S0034-4257(01)00289-9 — PDF terbuka: https://digitalcommons.unl.edu/natrespapers/149/ — *Paper asal VARI = (G-R)/(G+R-B). Sitasi wajib untuk VARI. **Hati-hati:** ada paper lain Gitelson et al. 2002 di Int. J. Remote Sensing yang sering salah dikutip untuk VARI — pastikan pakai paper Remote Sensing of Environment ini.*

11. Meyer, G. E., & Camargo Neto, J. (2008). Verification of color vegetation indices for automated crop imaging applications. *Computers and Electronics in Agriculture*, 63(2), 282–293. DOI: 10.1016/j.compag.2008.03.009 — *Verifikasi ExG, ExGR, ExR, CIVE untuk aplikasi crop imaging otomatis — rujukan metodologi thresholding. (Berbayar, abstrak gratis.)*

12. Sukhova, E., dkk. (2025). RGB Indices Can Be Used to Estimate NDVI, PRI, and Fv/Fm in Wheat and Pea Plants Under Soil Drought and Salinization. *Plants*, 14(9), 1284. Open access. DOI: 10.3390/plants14091284 — https://www.mdpi.com/2223-7747/14/9/1284 — *Bukti RGB index (ExG, VARI, VEG) merespons stres tanaman, kadang lebih awal dari NDVI.*

13. Rossi, R., dkk. (2025). Reliable NDVI estimation in wheat using low-cost UAV-derived RGB vegetation indices. *Smart Agricultural Technology*, 12, 101452. DOI: 10.1016/j.atech.2025.101452 — *VARI dkk. berkorelasi tinggi (R² > 0.70) dengan NDVI dari kamera murah — bukti konkret RGB index bisa menggantikan NDVI di precision agriculture.*

## Modul 3 — Precision Farming & Rekomendasi

14. (2025). Systematic review on machine learning and computer vision in precision agriculture. *Engineering Applications of Artificial Intelligence*. DOI: 10.1016/j.engappai.2025.110457 — *Review PRISMA 213 artikel ML/CV di precision agriculture. (Berbayar, abstrak gratis.)*

15. (2024). Computer vision in smart agriculture and precision farming: Techniques and applications. *Smart Agricultural Technology*. Open access — https://www.sciencedirect.com/science/article/pii/S2589721724000266 — *Review CV di smart agriculture, anchor bab precision farming.*

16. Araújo, S. O., dkk. (2021). An overview of agriculture 4.0 development. *Computers and Electronics in Agriculture*, 189, 106405. DOI: 10.1016/j.compag.2021.104221 — *Framework Agriculture 4.0 sebagai evolusi precision farming. Sitasi wajib untuk bab kerangka teori. (Berbayar, abstrak gratis.)*

17. Banothu, S., dkk. (2024). Plant disease identification and pesticides recommendation using DenseNet. *Cogent Engineering*, 11(1), 2353080. Open access. DOI: 10.1080/23311916.2024.2353080 — https://www.tandfonline.com/doi/full/10.1080/23311916.2024.2353080 — *Template langsung: deteksi penyakit + lapisan rekomendasi pestisida (jenis, dosis, cara aplikasi).*

18. (2022). An Automatic Recommendation System for Plant Disease Treatment. *Advances in Intelligent Systems and Computing / LNNS* (Springer). DOI: 10.1007/978-3-031-19694-2_55 — *Pipeline deteksi → rekomendasi, mendukung arsitektur rule-based rekomendasi.*

## Arsitektur & Dataset Dasar

19. Sandler, M., Howard, A., Zhu, M., Zhmoginov, A., & Chen, L.-C. (2018). MobileNetV2: Inverted Residuals and Linear Bottlenecks. *CVPR 2018*, 4510–4520. PDF terbuka: https://openaccess.thecvf.com/content_cvpr_2018/papers/Sandler_MobileNetV2_Inverted_Residuals_CVPR_2018_paper.pdf — *Sitasi wajib setiap memakai MobileNetV2.*

20. Tan, M., & Le, Q. V. (2019). EfficientNet: Rethinking Model Scaling for Convolutional Neural Networks. *ICML 2019*, PMLR 97. Open access — https://proceedings.mlr.press/v97/tan19a.html — *Sitasi wajib setiap memakai varian EfficientNet.*

21. New Plant Diseases Dataset (Kaggle) — https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset — *Dataset praktis (~87.000 gambar, augmented dari PlantVillage). Sitasi bersama #1.*

22. PlantVillage Dataset repository (GitHub, spMohanty) — https://github.com/spmohanty/plantvillage-dataset — *Repository resmi 54.306 gambar. Sitasi untuk provenance data.*

23. Chili Leaves Disease Classification (Roboflow Universe) — https://universe.roboflow.com/chili-leaves-disease-classification/chili-leaves-disease-classification — Lisensi CC BY 4.0. *Dataset cabai final yang dipakai untuk training model diagnosis (6 kelas: healthy, leaf curl, leaf spot, powdery mildew, whitefly, yellowish; 1.147 gambar). Sitasi wajib untuk provenance dataset cabai — cantumkan juga nomor versi project yang benar-benar dipakai (dicetak notebook saat dijalankan, karena project bisa dirilis ulang dengan versi baru).*

24. Tang, Y., dkk. (2024). MCCM: multi-scale feature extraction network for disease classification and recognition of chili leaves. *Frontiers in Plant Science*, 15, 1367738. Open access. DOI: 10.3389/fpls.2024.1367738 — *Bukan validasi dataset #23 (paper ini memvalidasi dataset Kaggle `dhenyd/chili-plant-disease` yang sempat dipakai sebelum pindah ke Roboflow) — tetap relevan sebagai referensi metodologi/related work untuk klasifikasi penyakit daun cabai berbasis deep learning.*

25. Rani, dkk. (2025). VGG-EffAttnNet [transfer learning untuk klasifikasi penyakit daun cabai]. *Food Science & Nutrition*. DOI: 10.1002/fsn3.70653 — *Sama seperti #24 — awalnya dipakai untuk memvalidasi dataset Kaggle dhenyd, sekarang relevan sebagai referensi metodologi transfer learning untuk cabai, bukan sitasi provenance dataset #23.*

**Catatan riwayat dataset cabai (4 iterasi, lihat juga `docs/05-ml-pipeline.md`):**
1. Dua kandidat Kaggle awal ditolak (2 kelas kesehatan buah saja / struktur tidak terverifikasi).
2. Mendeley Data `wzc6r6w5w5` (Ahmed, dkk., DOI: 10.17632/wzc6r6w5w5, CC BY 4.0, 4 kelas, 1.544 gambar) — kontennya bagus tapi tidak API-downloadable, menghambat Colab "Run All".
3. Kaggle `dhenyd/chili-plant-disease` (5 kelas, 500 gambar, divalidasi oleh #24 dan #25 di atas) — full-API tapi terlalu kecil.
4. **Roboflow `chili-leaves-disease-classification` (#23) — pilihan final**, lebih besar dari opsi Kaggle dan tetap full-API.

Kalau workflow-nya diubah untuk mengizinkan upload manual (misal demi mengejar akurasi lebih tinggi lewat data yang lebih besar), dataset Mendeley (poin 2) dan varian Mendeley lain yang lebih besar (COLD dataset, 10.987 gambar; `tm3v4zmh7c`, 8.814 gambar) adalah kandidat kembali yang baik — cantumkan sebagai alternatif yang dipertimbangkan di bab metodologi jika relevan.

## Catatan Penting

- **Gap akurasi lab vs lapangan:** Jelali, M. (2024), "Deep learning networks-based tomato disease and pest detection: a first review of research studies using real field datasets," *Frontiers in Plant Science*, 15, 1493322 (open access) — model yang diuji pada foto lapangan nyata (pencahayaan, oklusi, background) turun ke ~90% akurasi, di bawah model yang dilatih pada dataset lab. Studi MALCOM Indonesia bahkan turun ke 75% saat deteksi langsung. **Cantumkan gap ini secara eksplisit di bab pembahasan** — ini memperkuat evaluasi, bukan kelemahan yang perlu ditutupi.
- **Provenance dataset Kaggle:** "New Plant Diseases Dataset" adalah turunan augmented dari PlantVillage — selalu sitasi Mohanty et al. 2016 (#1) sebagai sumber asli bersamanya.
- **Referensi berbayar (ScienceDirect/Elsevier):** #3, #6, #11, #14, #16 — akses lewat SINTA/Garuda/EBSCO/akses institusi kampus, atau cari mirror di author repository/preprint.
- **Dataset cabai — dua kandidat Kaggle ditolak setelah verifikasi:** `shuvokumarbasak4004/chili-plant-disease-detection` (hanya 2 kelas kesehatan buah, bukan penyakit daun — tidak relevan untuk sistem ini) dan `ravindubandara3002/...` (struktur folder/kelas tidak bisa diverifikasi dari metadata publik). Dataset final yang dipakai adalah Kaggle `dhenyd/chili-plant-disease` (#23), didukung dua paper independen (#24, #25) — dipilih dari dua kandidat sebelumnya (satu Kaggle yang ditolak, satu Mendeley yang lebih besar tapi tidak API-downloadable) demi mendukung alur kerja Colab "Run All" tanpa upload manual.
