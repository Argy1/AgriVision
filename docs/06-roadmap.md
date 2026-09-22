# Roadmap (Estimasi 14 Minggu / 1 Semester)

Sesuaikan tanggal mulai dengan kalender akademik. Setiap minggu punya deliverable konkret agar progres mudah dilaporkan ke dosen pembimbing.

| Minggu | Fokus | Deliverable |
|---|---|---|
| 1–2 | Persiapan dataset | Dataset tomat & cabai terkumpul (PlantVillage/PlantDoc/Kaggle), sudah difilter & dibagi train/val/test |
| 3–4 | Training model diagnosis | Model MobileNetV2 (tomat) & EfficientNetB4 (cabai) terlatih, evaluasi awal (confusion matrix) |
| 5 | Modul monitoring | Implementasi ExG/VARI (OpenCV), validasi manual terhadap beberapa foto sehat vs sakit |
| 6 | Setup backend | Supabase schema (`database/schema.sql`) di-deploy, FastAPI service (`/api/diagnose`) jalan lokal dengan model yang sudah dilatih |
| 7 | Modul rekomendasi | Isi `disease_reference` lengkap untuk semua kelas penyakit yang dipakai, terverifikasi dari sumber agronomi |
| 8 | Deploy backend | FastAPI live di Railway, terhubung ke Supabase produksi |
| 9–10 | Web app | Next.js: Login, Unggah Foto, Hasil Diagnosis, Dashboard — sesuai `design/screens/` |
| 11–12 | Mobile app | Flutter: 4 screen yang sama, terhubung ke backend yang sama |
| 13 | Integrasi & testing | End-to-end testing (upload → diagnosis → rekomendasi → dashboard), uji dengan foto lapangan asli |
| 14 | Evaluasi & laporan | Evaluasi akurasi lab vs lapangan, studi kasus, penulisan bab hasil & pembahasan |

## Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Akurasi lapangan jauh di bawah lab | Sudah diantisipasi — laporkan keduanya terpisah (lihat `05-ml-pipeline.md`), gunakan PlantDoc sebagai data uji tambahan sejak awal |
| Data cabai Indonesia terbatas di PlantVillage | Kumpulkan tambahan foto lapangan sendiri jika waktu memungkinkan, atau perjelas batasan di laporan |
| Integrasi web + app + backend molor | Kontrak API (`04-api-contract.md`) sudah difiksasi di awal — kerjakan backend & 1 platform frontend dulu (disarankan web), baru app, agar ada fallback demo yang jalan |
| Waktu habis di 2 platform (web+app) | Prioritaskan web selesai dulu (deliverable utama untuk sidang), app sebagai nilai tambah — jangan sebaliknya |
