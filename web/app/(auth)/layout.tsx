import Image from "next/image";
import Link from "next/link";

import { Mascot } from "@/components/brand/Mascot";
import { CheckCircleIcon, LeafLogoIcon } from "@/components/icons";

/**
 * Shell halaman auth (masuk, daftar, lupa/atur ulang sandi) dan onboarding: foto sawah sebagai
 * latar, kartu formulir semi-transparan, maskot Si Tomat mengintip di atas kartu.
 */
export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative isolate flex min-h-screen overflow-hidden">
      <Image src="/images/latar-sawah.webp" alt="" fill priority sizes="100vw" className="-z-20 object-cover" />
      <div className="absolute inset-0 -z-10 bg-gradient-to-b from-night/70 via-night/55 to-night/80 lg:bg-gradient-to-r lg:from-night/90 lg:via-night/60 lg:to-night/30" />

      {/* Panel kiri (layar lebar): pesan brand di atas foto */}
      <div className="relative hidden w-[46%] max-w-[620px] flex-col justify-between p-12 text-white lg:flex xl:p-16">
        <Link href="/" className="flex w-fit items-center gap-2.5">
          <span className="flex h-9 w-9 items-center justify-center rounded-full bg-parchment/90">
            <LeafLogoIcon size={18} className="text-ink" />
          </span>
          <span className="font-sans text-[19px] font-semibold">AgriVision</span>
        </Link>

        <div className="rise-in">
          <h1 className="font-display text-[44px] font-semibold leading-[1.1] xl:text-[52px]">
            Diagnosis dini,
            <br />
            <span className="text-straw">panen lebih baik.</span>
          </h1>
          <p className="mt-5 max-w-[440px] font-sans text-[16px] leading-relaxed text-white/80">
            Foto satu daun tomat, dan AgriVision membantu mengenali penyakitnya beserta saran penanganan.
          </p>
          <ul className="mt-7 flex flex-col gap-3 font-sans text-[14.5px] text-white/90">
            {["Mengenali 9 penyakit + daun sehat", "Menolak foto yang bukan daun tomat", "Rekomendasi dari panduan resmi"].map(
              (t) => (
                <li key={t} className="flex items-center gap-2.5">
                  <CheckCircleIcon size={18} className="shrink-0 text-straw" /> {t}
                </li>
              ),
            )}
          </ul>
        </div>

        <p className="font-sans text-[12.5px] text-white/60">
          Tugas Akhir — Teknologi Rekayasa Perangkat Lunak, IPB University
        </p>
      </div>

      {/* Kartu formulir */}
      <div className="flex min-w-0 flex-1 flex-col items-center justify-center px-4 py-10 sm:px-8">
        <Link href="/" className="mb-4 flex items-center gap-2.5 text-white lg:hidden">
          <span className="flex h-9 w-9 items-center justify-center rounded-full bg-parchment/90">
            <LeafLogoIcon size={18} className="text-ink" />
          </span>
          <span className="font-sans text-[19px] font-semibold">AgriVision</span>
        </Link>

        <div className="rise-in relative w-full max-w-[440px] pt-16">
          <div className="pointer-events-none absolute left-1/2 top-0 z-10 -translate-x-1/2">
            <Mascot size={104} pose="wave" />
          </div>
          <div className="relative rounded-[22px] bg-paper/95 px-6 pb-7 pt-12 shadow-2xl shadow-black/30 ring-1 ring-white/40 backdrop-blur-md sm:px-9 sm:pb-9">
            {children}
          </div>
          <p className="mt-5 text-center font-sans text-[12.5px] text-white/75">
            <Link href="/" className="underline-offset-2 hover:underline">
              ← Kembali ke beranda AgriVision
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
