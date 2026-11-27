import type { HTMLAttributes } from "react";

import { cn } from "@/lib/cn";

export function Card({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "box-border rounded-xl border border-border-soft bg-paper shadow-[0_1px_2px_rgba(32,38,27,0.04),0_10px_28px_-18px_rgba(32,38,27,0.18)]",
        className,
      )}
      {...props}
    />
  );
}

/** Judul kartu dengan aksen garis jerami (warna ilustrasi, BUKAN warna status). */
export function CardTitle({ className, ...props }: HTMLAttributes<HTMLHeadingElement>) {
  return (
    <h2
      className={cn(
        "flex items-center gap-2 font-sans text-[15px] font-semibold text-ink before:h-4 before:w-1 before:shrink-0 before:rounded-full before:bg-straw before:content-['']",
        className,
      )}
      {...props}
    />
  );
}
