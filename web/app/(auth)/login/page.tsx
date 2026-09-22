import type { Metadata } from "next";
import { Suspense } from "react";

import { LoginForm } from "./LoginForm";

export const metadata: Metadata = { title: "Masuk — AgriVision" };

export default function LoginPage() {
  return (
    <div className="flex flex-col gap-5">
      <div>
        <h1 className="font-display text-[30px] font-semibold text-ink">Masuk ke AgriVision</h1>
        <p className="mt-2 font-sans text-[14.5px] text-sage">
          Pantau kesehatan tanaman Anda dari mana saja.
        </p>
      </div>

      <Suspense fallback={null}>
        <LoginForm />
      </Suspense>

      <div className="flex items-center gap-3">
        <div className="h-px flex-grow bg-divider-soft" />
        <span className="font-sans text-[12px] text-muted-2">atau</span>
        <div className="h-px flex-grow bg-divider-soft" />
      </div>

      <p className="text-center font-sans text-[13px] text-sage">
        Belum punya akun?{" "}
        <span className="font-semibold text-moss">Hubungi admin di wilayah Anda</span>
      </p>
    </div>
  );
}
