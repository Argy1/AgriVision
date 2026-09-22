import Link from "next/link";

import { LeafLogoIcon } from "@/components/icons";

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-parchment px-6 text-center">
      <div className="flex h-14 w-14 items-center justify-center rounded-full bg-moss-tint">
        <LeafLogoIcon size={26} className="text-moss" />
      </div>
      <h1 className="font-display text-[32px] font-semibold text-ink">Halaman tidak ditemukan</h1>
      <p className="max-w-md font-sans text-[14.5px] text-sage">
        Halaman ini tidak ada, atau Anda tidak punya akses untuk melihatnya.
      </p>
      <Link
        href="/dashboard"
        className="mt-2 rounded-sm bg-moss px-5 py-2.5 font-sans text-[13.5px] font-semibold text-white"
      >
        Kembali ke Dashboard
      </Link>
    </div>
  );
}
