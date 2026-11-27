-- 006: Rekomendasi penanganan bersumber (DRAF 2026-11-28) — BELUM DIJALANKAN.
-- Sumber per baris: docs/12-sumber-rekomendasi.md. Jalankan di Supabase SQL Editor hanya
-- setelah disetujui; lalu salin isinya ke seed disease_reference di database/schema.sql.
-- Hanya UPDATE kolom teks + is_verified; disease_label (kunci) tidak berubah, jadi model,
-- API, web, dan app tidak terpengaruh. Diagnosis lama menyimpan snapshot rekomendasinya
-- sendiri (tabel recommendations), jadi riwayat tidak ikut berubah.

begin;

update disease_reference set
  recommendation_text = 'Pakai benih dan bibit bebas penyakit. Hindari penyiraman dari atas yang membasahi daun, jauhkan tumpukan sisa tanaman, dan gilir tanam dengan tanaman bukan inang. Bakterisida tembaga dapat diberikan sebagai pelindung; bila tembaga kurang mempan, kombinasikan dengan mankozeb.',
  dosage = 'Sesuai label produk',
  application_schedule = 'Mulai saat gejala pertama, ulangi tiap 10–14 hari selama cuaca hangat dan lembap',
  warning_note = 'Tembaga hanya melindungi daun yang belum terinfeksi, tidak menyembuhkan daun yang sudah sakit.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_bacterial_spot';

update disease_reference set
  recommendation_text = 'Buang daun tua/daun bawah yang terinfeksi dan jarangkan daun agar aliran udara baik. Bersihkan gulma terung-terungan serta tomat/kentang liar, dan lakukan rotasi tanaman. Bila cuaca mendukung penyakit dan gejala pertama muncul, gunakan fungisida pelindung berbahan aktif klorotalonil atau mankozeb.',
  dosage = 'Sesuai label produk',
  application_schedule = 'Mulai saat gejala pertama; gilir bahan aktif dengan kode FRAC berbeda dan patuhi batas jumlah aplikasi pada label',
  warning_note = 'Menyebar cepat pada kondisi lembap — pantau tanaman di sekitarnya.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_early_blight';

update disease_reference set
  recommendation_text = 'Gunakan varietas tahan bila tersedia dan bibit bebas penyakit. Cabut tomat/kentang liar dan gulma terung-terungan, hindari penyiraman dari atas, dan pasang naungan hujan bila memungkinkan. Semprot fungisida pelindung (mis. mankozeb, klorotalonil) sebelum penyakit berkembang; bila sudah muncul, semprot teratur dengan cakupan merata menggunakan fungisida sistemik dan gilir bahan aktifnya (mis. azoksistrobin, dimetomorf, famoksadon + simoksanil).',
  dosage = 'Sesuai label produk',
  application_schedule = 'Pencegahan sebelum musim hujan; bila sudah muncul ulangi teratur (mis. azoksistrobin tiap 5–7 hari, maksimal 2 kali berturut-turut lalu ganti bahan aktif)',
  warning_note = 'Penyakit sangat merusak dan cepat menyebar — segera cabut dan musnahkan tanaman terinfeksi berat.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_late_blight';

update disease_reference set
  recommendation_text = 'Turunkan kelembapan: perbaiki ventilasi (buka sisi rumah tanam bila kelembapan di atas ±85%), gunakan irigasi tetes dan jangan membasahi daun, serta beri jarak tanam yang cukup. Bersihkan dan musnahkan sisa tanaman di akhir musim. Coba varietas tahan dalam skala kecil. Fungisida hanya efektif bila kelembapan sudah diturunkan.',
  dosage = 'Sesuai label produk',
  application_schedule = 'Sesuai label; utamakan pengaturan kelembapan',
  warning_note = 'Varietas tahan hanya melindungi dari ras jamur tertentu, jadi hasilnya bisa berbeda di tiap lokasi.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_leaf_mold';

update disease_reference set
  recommendation_text = 'Petik daun bawah yang terinfeksi dan musnahkan (jangan dikompos). Pasang mulsa di pangkal tanaman agar percikan tanah tidak mengenai daun, gunakan irigasi tetes, bersihkan ajir/alat, kendalikan gulma terung-terungan, dan rotasi minimal 2 tahun dari tomat/kentang. Fungisida pelindung berbahan aktif klorotalonil atau mankozeb diberikan sebelum penyakit meluas.',
  dosage = 'Sesuai label produk',
  application_schedule = 'Tiap 7–14 hari sesuai label; gilir bahan aktif dengan kode FRAC berbeda',
  warning_note = 'Fungisida hanya mencegah, tidak menyembuhkan; varietas yang tahan penuh belum tersedia.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_septoria_leaf_spot';

update disease_reference set
  recommendation_text = 'Periksa bagian bawah daun secara rutin. Semprot air dengan kuat ke bawah daun beberapa kali seminggu, hindari tanaman kekurangan air dan pupuk nitrogen berlebih. Hindari insektisida spektrum luas (mis. piretroid) yang membunuh tungau predator dan memicu ledakan tungau. Bila populasi tinggi, gunakan akarisida yang selektif dan gilir cara kerjanya.',
  dosage = 'Sesuai label produk',
  application_schedule = 'Saat populasi tinggi (mis. 5–10 tungau per daun tanpa predator); gilir cara kerja akarisida',
  warning_note = 'Ini serangan hama, bukan penyakit jamur/bakteri — fungisida tidak efektif.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_spider_mites_two_spotted_spider_mite';

update disease_reference set
  recommendation_text = 'Musnahkan sisa tanaman segera setelah panen, hindari pupuk nitrogen berlebih, dan amati gejala dengan teliti karena mirip bercak bakteri dan early blight. Belum ada varietas tahan, sehingga fungisida pencegahan adalah cara utama; gilir bahan aktif karena jamur ini mudah menjadi tahan (resistensi terhadap fungisida golongan strobilurin sudah banyak dilaporkan).',
  dosage = 'Sesuai label produk',
  application_schedule = 'Pencegahan sesuai label; gilir bahan aktif',
  warning_note = 'Jangan mengandalkan satu jenis fungisida saja.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_target_spot';

update disease_reference set
  recommendation_text = 'Gunakan varietas tahan TYLCV serta bibit bebas virus dan kutu kebul. Jangan menanam di dekat pertanaman lama yang terinfeksi, kendalikan kutu kebul dan gulma di sekitar lahan, lindungi bibit dengan kain kasa/sungkup halus, dan cabut tanaman sakit selagi masih sedikit. Musnahkan sisa tanaman setelah panen.',
  dosage = 'Untuk pengendalian kutu kebul: sesuai label produk',
  application_schedule = 'Pantau kutu kebul secara rutin; tindakan sesuai anjuran PPL',
  warning_note = 'Virus tidak dapat disembuhkan — fokus mencegah penularan oleh kutu kebul.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_tomato_yellow_leaf_curl_virus';

update disease_reference set
  recommendation_text = 'Gunakan benih yang sudah diperlakukan/bebas virus dan varietas tahan bila tersedia. Lakukan sanitasi ketat: cabut dan musnahkan tanaman terinfeksi, bersihkan alat kerja, dan hindari memegang tanaman sehat setelah memegang tanaman sakit.',
  dosage = null,
  application_schedule = null,
  warning_note = 'Virus tidak dapat disembuhkan dan sangat mudah menular lewat sentuhan dan alat kerja.',
  is_verified = false, updated_at = now()
where disease_label = 'tomato_tomato_mosaic_virus';

update disease_reference set
  recommendation_text = 'Lanjutkan perawatan rutin dan periksa daun secara berkala. Jaga aliran udara dengan penyanggahan dan pemangkasan tunas/daun tua.',
  updated_at = now()
where disease_label = 'tomato_healthy';

commit;
