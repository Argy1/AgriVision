import Image from "next/image";

import { Mascot } from "@/components/brand/Mascot";
import { cn } from "@/lib/cn";

/**
 * Header halaman di area aplikasi: pita foto sawah bergradasi gelap + judul + maskot Si Tomat.
 * `actions` (mis. pemilih zona/rentang waktu) tampil di kanan pada layar lebar, di bawah judul
 * pada layar sempit. Maskot disembunyikan di layar sangat sempit supaya tidak berdesakan.
 */
export function PageHeader({
  eyebrow,
  title,
  subtitle,
  pose = "wave",
  actions,
  className,
}: {
  eyebrow?: React.ReactNode;
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  pose?: "wave" | "lens" | "happy";
  actions?: React.ReactNode;
  className?: string;
}) {
  return (
    <header
      className={cn(
        "relative isolate z-10 rounded-[20px] bg-night px-5 py-6 text-white shadow-[0_18px_40px_-24px_rgba(20,26,16,0.7)] sm:px-7 sm:py-7",
        className,
      )}
    >
      {/* Lapisan latar diklip sendiri supaya dropdown di `actions` tidak ikut terpotong. */}
      <div aria-hidden className="pointer-events-none absolute inset-0 -z-10 overflow-hidden rounded-[20px]">
        <Image src="/images/latar-sawah.webp" alt="" fill loading="eager" sizes="(min-width: 1024px) 80vw, 100vw" className="object-cover object-[50%_70%]" />
        <div className="absolute inset-0 bg-gradient-to-r from-night/95 via-night/80 to-night/40" />
        <div className="absolute -bottom-3 right-3 hidden min-[380px]:block sm:right-6">
          <Mascot size={104} pose={pose} />
        </div>
      </div>

      <div className="flex flex-col gap-5 md:flex-row md:items-end md:justify-between">
        <div className="min-w-0 pr-24 sm:pr-32 md:pr-0">
          {eyebrow && <p className="font-sans text-[12.5px] font-semibold uppercase tracking-[0.14em] text-straw">{eyebrow}</p>}
          <h1 className="mt-1 font-display text-[26px] font-semibold leading-tight sm:text-[32px]">{title}</h1>
          {subtitle && <p className="mt-2 max-w-[560px] font-sans text-[14px] leading-relaxed text-white/75">{subtitle}</p>}
        </div>
        {actions && <div className="relative z-10 flex shrink-0 flex-wrap items-center gap-2.5 md:mr-36">{actions}</div>}
      </div>

    </header>
  );
}
