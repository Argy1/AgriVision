import { LeafLogoIcon } from "@/components/icons";

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-white">
      <div className="relative hidden w-[560px] shrink-0 flex-col justify-between overflow-hidden bg-ink p-14 md:flex">
        <svg
          viewBox="0 0 200 220"
          width="300"
          height="330"
          className="pointer-events-none absolute -bottom-10 -right-12 opacity-10"
          aria-hidden
        >
          <path
            d="M100 8 C46 26 14 84 14 146 C14 188 52 214 100 214 C148 214 186 188 186 146 C186 84 154 26 100 8 Z"
            fill="#EEEADC"
          />
        </svg>

        <div className="relative flex items-center gap-2.5">
          <div className="flex h-[34px] w-[34px] shrink-0 items-center justify-center rounded-full bg-parchment">
            <LeafLogoIcon size={18} className="text-ink" />
          </div>
          <span className="font-sans text-[19px] font-semibold tracking-[0.2px] text-parchment">
            AgriVision
          </span>
        </div>

        <div className="relative">
          <h1 className="whitespace-pre-line font-display text-[42px] font-semibold leading-[1.16] text-panel-headline">
            {"Diagnosis dini,\npanen lebih baik."}
          </h1>
          <p className="mt-4.5 max-w-[380px] font-sans text-[15.5px] leading-[1.65] text-panel-body">
            Sistem computer vision untuk deteksi penyakit dan pemantauan kesehatan tanaman
            tomat &amp; cabai.
          </p>
        </div>

        <p className="relative font-sans text-[12.5px] text-panel-caption">
          Tugas Akhir — Teknologi Rekayasa Perangkat Lunak, IPB University
        </p>
      </div>

      <div className="flex flex-1 flex-col justify-center px-8 py-12 sm:px-16 md:px-[88px]">
        <div className="mx-auto w-full max-w-[420px]">{children}</div>
      </div>
    </div>
  );
}
