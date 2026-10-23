import type { Metadata } from "next";
import Link from "next/link";

import { RegisterForm } from "./RegisterForm";

export const metadata: Metadata = { title: "Daftar — AgriVision" };

export default function RegisterPage() {
  return (
    <div className="flex flex-col gap-5">
      <div>
        <h1 className="font-display text-[30px] font-semibold text-ink">Buat akun baru</h1>
        <p className="mt-2 font-sans text-[14.5px] text-sage">
          Gratis — cukup satu menit untuk mulai memantau tanaman Anda.
        </p>
      </div>

      <RegisterForm />

      <div className="flex items-center gap-3">
        <div className="h-px flex-grow bg-divider-soft" />
        <span className="font-sans text-[12px] text-muted-2">atau</span>
        <div className="h-px flex-grow bg-divider-soft" />
      </div>

      <p className="text-center font-sans text-[13px] text-sage">
        Sudah punya akun?{" "}
        <Link href="/login" className="font-semibold text-moss">
          Masuk
        </Link>
      </p>
    </div>
  );
}
