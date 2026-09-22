"use client";

import { usePathname, useRouter, useSearchParams } from "next/navigation";

const OPTIONS = [
  { value: "7", label: "7 Hari" },
  { value: "30", label: "30 Hari" },
  { value: "90", label: "90 Hari" },
];

export function TimeRangeToggle({ current }: { current: string }) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  return (
    <div className="flex gap-1 rounded-pill border border-border bg-paper p-1">
      {OPTIONS.map((opt) => {
        const active = opt.value === current;
        return (
          <button
            key={opt.value}
            type="button"
            onClick={() => {
              const params = new URLSearchParams(searchParams);
              params.set("range", opt.value);
              router.push(`${pathname}?${params.toString()}`);
            }}
            className={`rounded-pill px-4 py-1.5 font-sans text-[13px] font-medium transition-colors ${
              active ? "bg-moss text-white" : "text-sage"
            }`}
          >
            {opt.label}
          </button>
        );
      })}
    </div>
  );
}
