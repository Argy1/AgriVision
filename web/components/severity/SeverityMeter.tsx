import type { Enums } from "@/types/database.types";

const TIERS: Enums<"severity_level">[] = ["ringan", "sedang", "parah"];
const TIER_BG: Record<Enums<"severity_level">, string> = {
  ringan: "bg-moss",
  sedang: "bg-ochre",
  parah: "bg-rust",
};

/**
 * Meter 3-segmen persis seperti mockup: segmen sampai & termasuk severity saat
 * ini diwarnai (moss->ochre->rust berurutan), segmen setelahnya abu-abu
 * (meter-inactive). Indikator pil gelap ditempatkan di tengah segmen severity aktif.
 */
export function SeverityMeter({ severity }: { severity: Enums<"severity_level"> }) {
  const activeIndex = TIERS.indexOf(severity);

  return (
    <div>
      <div className="mb-1.5 flex justify-between font-sans text-[12px] text-sage">
        <span>Ringan</span>
        <span>Sedang</span>
        <span>Parah</span>
      </div>
      <div className="flex h-2 gap-1">
        {TIERS.map((tier, index) => (
          <div
            key={tier}
            className={`relative flex-1 rounded-sm ${
              index <= activeIndex ? TIER_BG[tier] : "bg-meter-inactive"
            }`}
          >
            {index === activeIndex && (
              <div className="absolute left-1/2 top-[-6px] h-5 w-1.5 -translate-x-1/2 rounded-sm bg-ink" />
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
