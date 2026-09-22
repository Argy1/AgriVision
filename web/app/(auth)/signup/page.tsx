import type { Metadata } from "next";

import { SignupForm } from "./SignupForm";

// Halaman ini SENGAJA tidak di-link di mana pun (tidak ada di navigasi/UI utama)
// -- cuma bisa diakses lewat URL langsung. Dibutuhkan untuk bootstrap akun
// pertama karena mockup login tidak punya form daftar sendiri (implikasinya
// akun dibuat admin manual). Lihat catatan di rencana implementasi soal
// perilaku sesi yang tergantikan saat dipakai.
export const metadata: Metadata = { title: "Buat Akun — AgriVision" };

export default function SignupPage() {
  return (
    <div className="flex flex-col gap-5">
      <div>
        <h1 className="font-display text-[30px] font-semibold text-ink">Buat Akun AgriVision</h1>
        <p className="mt-2 font-sans text-[14.5px] text-sage">
          Halaman ini untuk membuat akun uji/awal secara manual.
        </p>
      </div>

      <div className="rounded-sm border border-rust-divider bg-rust-soft px-4 py-3 font-sans text-[13px] text-rust-text">
        Membuat akun baru akan mengeluarkan Anda dari sesi saat ini — gunakan jendela
        browser terpisah kalau ingin tetap masuk sebagai akun sekarang.
      </div>

      <SignupForm />
    </div>
  );
}
