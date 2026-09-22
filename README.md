# AgriVision — Projek Akhir Computer Vision

Sistem Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat dan Cabai Berbasis Computer Vision untuk Precision Farming.

**Status saat ini: tahap perencanaan selesai, belum ada kode aplikasi.** Folder ini berisi seluruh keputusan desain sistem, skema database, kontrak API, dan mockup UI yang sudah difinalisasi lewat diskusi — siap dipakai sebagai basis untuk mulai coding.

## Mulai dari mana?

Baca **`CLAUDE.md`** dulu — itu ringkasan orientasi lengkap proyek ini untuk siapa pun (manusia atau Claude Code) yang mulai mengerjakan implementasinya.

## Struktur Folder

```
├── CLAUDE.md                    ← baca ini duluan
├── docs/
│   ├── 01-project-brief.md      — judul, rumusan masalah, tujuan, scope
│   ├── 02-tech-stack.md         — Next.js + Flutter + Supabase + Railway/FastAPI
│   ├── 03-database-schema.md    — penjelasan skema (SQL di database/schema.sql)
│   ├── 04-api-contract.md       — kontrak endpoint FastAPI (wajib diikuti web & app)
│   ├── 05-ml-pipeline.md        — dataset, model, vegetation index, evaluasi
│   ├── 06-roadmap.md            — rencana 14 minggu
│   └── 07-referensi.md          — 22 referensi akademik
├── design/
│   ├── design-system.md         — token warna, tipografi, komponen
│   └── screens/                 — 8 mockup (4 web + 4 app), .html + .png
└── database/
    └── schema.sql                — SQL lengkap, siap dijalankan di Supabase
```
