import type { Metadata } from "next";

import { getUser } from "@/lib/data/auth";

import { OnboardingZoneForm } from "./OnboardingZoneForm";

export const metadata: Metadata = { title: "Zona Pertama — AgriVision" };

export default async function OnboardingPage() {
  await getUser();

  return (
    <div className="flex flex-col gap-5">
      <div>
        <p className="font-sans text-[12.5px] font-semibold uppercase tracking-[0.6px] text-sage">
          Langkah 2 dari 2
        </p>
        <h1 className="mt-2 font-display text-[30px] font-semibold text-ink">
          Buat zona pertama Anda
        </h1>
        <p className="mt-2 font-sans text-[14.5px] text-sage">
          Zona adalah satu petak lahan yang Anda pantau. Anda bisa menambah zona lain kapan saja
          di Pengaturan.
        </p>
      </div>

      <OnboardingZoneForm />
    </div>
  );
}
