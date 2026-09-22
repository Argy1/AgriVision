import type { Metadata } from "next";
import Link from "next/link";

import { ForgotPasswordForm } from "./ForgotPasswordForm";

export const metadata: Metadata = { title: "Lupa Kata Sandi — AgriVision" };

export default function ForgotPasswordPage() {
  return (
    <div className="flex flex-col gap-5">
      <div>
        <h1 className="font-display text-[30px] font-semibold text-ink">Lupa kata sandi?</h1>
        <p className="mt-2 font-sans text-[14.5px] text-sage">
          Masukkan email Anda, kami kirimkan tautan untuk atur ulang kata sandi.
        </p>
      </div>
      <ForgotPasswordForm />
      <Link href="/login" className="text-center font-sans text-[13px] font-medium text-moss">
        Kembali ke halaman masuk
      </Link>
    </div>
  );
}
