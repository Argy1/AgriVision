# Design System — AgriVision

Referensi visual lengkap ada di `screens/` (8 file `.html` + `.png`, bisa dibuka langsung di browser). Dokumen ini adalah token & aturan yang harus diikuti persis saat implementasi di Next.js maupun Flutter — supaya web dan app terlihat sebagai satu produk yang sama.

## Konsep
Identitas visual diambil dari dunia **spesimen tanaman / field guide botani**, bukan "green tech dashboard" generik. Warna severity (rust/ochre/moss) bukan dekorasi — itu adalah sistem klasifikasi 3-tingkat yang sama dengan yang dipakai modul diagnosis (ringan/sedang/parah). Ilustrasi daun dengan overlay warna menggambarkan area terdampak (representasi visual dari `affected_area_pct`).

## Warna

| Token | Hex | Pemakaian |
|---|---|---|
| Ink | `#20261B` | Teks utama, sidebar/header gelap |
| Parchment | `#EEEADC` | Background halaman |
| Paper | `#FFFFFF` | Background card/panel |
| Moss | `#46603C` | Warna brand utama, tombol primer, status "sehat" |
| Moss tint | `#E7ECE0` | Background ikon/state aktif ringan |
| Rust | `#AE4F2E` | Status "parah"/alert, aksen rekomendasi |
| Rust tint | `#F3E2DA` / `#FBF1EC` | Background chip/card rust |
| Ochre | `#BD8A2E` | Status "sedang"/warning |
| Ochre tint | `#F3E8CE` | Background chip ochre |
| Sage | `#8B9280` / `#8B9A7E` | Teks sekunder, border |
| Border | `#DED9C7` / `#E3DFCF` | Border hairline di atas parchment/putih |

**Aturan warna status (wajib konsisten di seluruh sistem):** moss = sehat/ringan, ochre = waspada/sedang, rust = perlu tindakan/parah. Jangan pakai kombinasi warna lain untuk severity di bagian manapun.

## Tipografi

- **Display/heading:** Fraunces (serif, optical sizing) — weight 600 untuk heading.
- **UI/body:** IBM Plex Sans — weight 400 (body), 500 (label), 600 (emphasis/button).
- Google Fonts: `https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600;9..144,700&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap`

## Komponen Kunci (lihat kode sumber di `screens/*.html` untuk detail styling)

- **Sidebar (web):** 240px, background Ink, item aktif background Moss.
- **Bottom nav (app):** 4 item (Beranda, Unggah, Riwayat, Profil), item aktif warna Moss.
- **Severity meter:** bar 3 segmen (Ringan/Sedang/Parah) dengan indikator posisi.
- **Status dot:** lingkaran 8-9px, warna sesuai token severity.
- **Ilustrasi daun:** SVG custom (bentuk daun + urat + blob rust untuk area terdampak) — bukan foto stok/emoji. Lihat kode SVG di `screens/3-web-hasil-diagnosis.html` sebagai referensi bentuk.
- **Card:** border 1px `#E3DFCF`, radius 12px, background putih, padding 20-28px (bukan drop shadow generik).
- **Border-radius:** 8-16px tergantung ukuran elemen; jangan seragamkan semua ke satu nilai.

## Referensi Layar

| File | Deskripsi |
|---|---|
| `screens/1-web-login.html` | Web — Login (split screen, panel kiri Ink dengan headline) |
| `screens/2-web-upload-foto.html` | Web — Unggah Foto (dropzone + tips + riwayat terbaru) |
| `screens/3-web-hasil-diagnosis.html` | Web — Hasil Diagnosis (diagnosis card + rekomendasi + histori) |
| `screens/4-web-dashboard.html` | Web — Dashboard (stat tiles + tren chart + status zona) |
| `screens/5-app-login.html` | App — Login |
| `screens/6-app-upload-foto.html` | App — Unggah Foto (kamera-first) |
| `screens/7-app-hasil-diagnosis.html` | App — Hasil Diagnosis |
| `screens/8-app-dashboard.html` | App — Dashboard |

Setiap `.html` bisa dibuka langsung di browser (tidak butuh server) — berisi markup + style lengkap, jadi bisa dijadikan referensi persis saat menulis komponen React/Flutter. File `.png` adalah screenshot cepat untuk yang tidak sempat membuka HTML.

**Sumber asli (live, bisa diedit lebih lanjut di Claude):** https://claude.ai/artifact/3ZaS3TaCcTqFGNmDTMfkgq
