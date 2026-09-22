import type { Metadata } from "next";
import { Suspense } from "react";

import { ResetPasswordForm } from "./ResetPasswordForm";

export const metadata: Metadata = { title: "Atur Ulang Kata Sandi — AgriVision" };

export default function ResetPasswordPage() {
  return (
    <div className="flex flex-col gap-5">
      <div>
        <h1 className="font-display text-[30px] font-semibold text-ink">Atur ulang kata sandi</h1>
        <p className="mt-2 font-sans text-[14.5px] text-sage">
          Masukkan kata sandi baru untuk akun Anda.
        </p>
      </div>
      <Suspense fallback={null}>
        <ResetPasswordForm />
      </Suspense>
    </div>
  );
}
