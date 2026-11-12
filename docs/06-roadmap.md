# Roadmap (Estimasi 14 Minggu / 1 Semester)

Sesuaikan tanggal mulai dengan kalender akademik. Setiap minggu punya deliverable konkret agar progres mudah dilaporkan ke dosen pembimbing. **Kolom Status diperbarui 2026-10-24** (rincian di `08-status-dan-progres.md`).

| Minggu | Fokus | Deliverable | Status |
|---|---|---|---|
| 1–2 | Persiapan dataset | Dataset tomat terkumpul (PlantVillage; dataset cabai ikut dikumpulkan lalu dibuang saat scope fokus ke tomat), difilter & dibagi train/val/test | ✅ Selesai |
| 3–4 | Training model diagnosis | Model MobileNetV2 (tomat) terlatih (model cabai EfficientNetB4 dihapus 2026-11-12), evaluasi awal (confusion matrix) | ✅ Selesai (confusion matrix lab ada di `ml-service/evaluation/`) |
| 5 | Modul monitoring | Implementasi ExG/VARI (OpenCV), validasi manual terhadap foto sehat vs sakit | ⚠️ Terimplementasi; **kalibrasi `health_score` dengan foto nyata belum** (rentang ExG masih placeholder) |
| 6 | Setup backend | Skema Supabase di-deploy, FastAPI `/api/diagnose` jalan dengan model terlatih | ✅ Selesai |
| 7 | Modul rekomendasi | `disease_reference` lengkap untuk semua kelas, terverifikasi sumber agronomi | ⚠️ 16/16 baris terisi, tapi **hanya 4 `is_verified=true`** — verifikasi ke pembimbing belum |
| 8 | Deploy backend | FastAPI live di Railway, terhubung ke Supabase produksi | ✅ Selesai (service dibuat ulang 2026-10-23 setelah terhapus tidak sengaja) |
| 9–10 | Web app | Next.js sesuai `design/screens/` | ✅ Selesai, diperluas jadi 13 route, live di Vercel |
| 11–12 | Mobile app | Flutter, terhubung ke backend yang sama | ✅ Selesai, 13 route, APK terpasang di HP |
| — | *(tambahan di luar roadmap awal)* | Registrasi publik web + app, onboarding zona pertama, pengerasan keamanan role | ✅ Selesai 2026-10-24 |
| 13 | Integrasi & testing | E2E (upload → diagnosis → rekomendasi → dashboard), **uji dengan foto lapangan asli** | ⏳ E2E dengan data sintetis ✅; **foto lapangan asli belum** |
| 14 | Evaluasi & laporan | Evaluasi akurasi lab vs lapangan, studi kasus, penulisan bab hasil & pembahasan | ⏳ Belum |

## Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Akurasi lapangan jauh di bawah lab | Sudah diantisipasi — laporkan keduanya terpisah (lihat `05-ml-pipeline.md`), gunakan PlantDoc sebagai data uji tambahan sejak awal |
| Model tomat hanya dievaluasi pada foto lab (PlantVillage augmentasi) | Training ulang v2: campur data non-lab (PlantDoc/Tomato-Village, split bersih) + set uji lapangan terpisah; lihat `05-ml-pipeline.md` |
| Integrasi web + app + backend molor | *(Teratasi)* kontrak API difiksasi di awal, web selesai dulu baru app |
| Waktu habis di 2 platform (web+app) | *(Teratasi)* keduanya selesai |
| Infrastruktur gratis berhenti (Supabase pause, service Railway terhapus) | Runbook pemulihan di `09-operasional-dan-runbook.md`; model ter-commit di git sehingga tidak hilang |
