import Link from "next/link";

import { ChevronDownIcon } from "@/components/icons";

export function Pagination({
  page,
  totalPages,
  buildHref,
}: {
  page: number;
  totalPages: number;
  buildHref: (page: number) => string;
}) {
  if (totalPages <= 1) return null;

  return (
    <div className="flex items-center justify-center gap-2 pt-4">
      <Link
        href={buildHref(Math.max(1, page - 1))}
        aria-disabled={page <= 1}
        className={`flex h-[30px] w-[30px] items-center justify-center rounded-sm border border-border bg-paper ${
          page <= 1 ? "pointer-events-none opacity-40" : ""
        }`}
      >
        <ChevronDownIcon size={14} className="rotate-90 text-ink" />
      </Link>
      <span className="font-sans text-[13px] text-sage">
        Halaman {page} dari {totalPages}
      </span>
      <Link
        href={buildHref(Math.min(totalPages, page + 1))}
        aria-disabled={page >= totalPages}
        className={`flex h-[30px] w-[30px] items-center justify-center rounded-sm border border-border bg-paper ${
          page >= totalPages ? "pointer-events-none opacity-40" : ""
        }`}
      >
        <ChevronDownIcon size={14} className="-rotate-90 text-ink" />
      </Link>
    </div>
  );
}
