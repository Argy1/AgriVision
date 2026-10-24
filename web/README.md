# AgriVision — Web (Next.js 16)

Dashboard & portal pengguna AgriVision: unggah foto daun, hasil diagnosis, monitoring kesehatan multi-zona, analitik, riwayat. Live di https://agrivision-blond-nine.vercel.app (Vercel, root directory `web`, auto-deploy dari `main`).

> **Ini Next.js 16, bukan versi lama.** `middleware.ts` kini `proxy.ts`. Baca `AGENTS.md` dan dokumen di `node_modules/next/dist/docs/` sebelum menulis kode Next. Konteks proyek: `../CLAUDE.md`.

## Menjalankan

```bash
cp .env.example .env.local   # isi NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, NEXT_PUBLIC_ML_API_URL
npm install
npm run dev                  # http://localhost:3000
npm run lint && npm run build
```
`NEXT_PUBLIC_*` di-inline saat build → setelah mengubah env di Vercel, redeploy.

## Struktur

```
proxy.ts                     — refresh sesi Supabase + redirect optimistik (rute publik: login, register, signup→redirect, forgot/reset-password)
app/(auth)/                  — login, register, signup (redirect), forgot-password, reset-password
app/onboarding/              — langkah 2 setelah daftar: buat zona pertama (dilindungi login)
app/(app)/                   — dashboard, upload, diagnosis/[id], monitoring, zona/[id], analitik, riwayat, pengaturan (shell sidebar)
components/                  — ui, layout, icons, severity (tokens.ts = sumber tunggal warna severity), leaf-illustration, charts, upload, ...
lib/data/                    — fungsi baca data (server-only, RLS lewat sesi user); auth.ts = getUser/getProfile (DAL)
lib/ml-service/client.ts     — pemanggil POST /api/diagnose (token user, bukan service role)
lib/validation/              — skema zod (auth, zona)
lib/supabase/{client,server}.ts
types/database.types.ts      — tipe yang digenerate dari skema Supabase
```

## Aturan penting

- Teks UI Bahasa Indonesia. Token desain: `app/globals.css` (`@theme`, Tailwind v4) — jangan improvisasi palet.
- Moss/Ochre/Rust hanya untuk severity/status (lihat `../design/design-system.md`).
- Tanggal untuk `zone_health_daily` = kalender Asia/Jakarta (`lib/data/zone-health.ts`).
- Service role key tidak pernah dipakai di web. Pemeriksaan auth sebenarnya ada di `lib/data/auth.ts` + RLS; `proxy.ts` hanya lapisan optimistik.
- Registrasi: `app/(auth)/register` → `signUp` (tanpa field role) → `/onboarding`. "Confirm email" di Supabase harus OFF.
