import { forwardRef } from "react";
import type { ButtonHTMLAttributes } from "react";

import { cn } from "@/lib/cn";

type Variant = "primary" | "outline" | "ghost";

const VARIANT_CLASSES: Record<Variant, string> = {
  primary:
    "bg-moss text-white hover:bg-moss-deep disabled:bg-sage disabled:cursor-not-allowed",
  outline:
    "border border-moss text-moss bg-transparent hover:bg-moss-tint disabled:opacity-50 disabled:cursor-not-allowed",
  ghost:
    "text-ink hover:bg-parchment disabled:opacity-50 disabled:cursor-not-allowed",
};

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  loading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { className, variant = "primary", loading, disabled, children, ...props },
  ref,
) {
  return (
    <button
      ref={ref}
      disabled={disabled || loading}
      className={cn(
        "inline-flex items-center justify-center gap-2 rounded-sm px-5 py-3.5 font-sans text-[15px] font-semibold transition-colors",
        VARIANT_CLASSES[variant],
        className,
      )}
      {...props}
    >
      {loading ? "Memproses…" : children}
    </button>
  );
});
