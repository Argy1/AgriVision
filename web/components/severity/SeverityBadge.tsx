import { cn } from "@/lib/cn";
import type { Enums } from "@/types/database.types";

import { SEVERITY_LABEL, SEVERITY_PILL_CLASSES, ZONE_STATUS_LABEL, ZONE_STATUS_PILL_CLASSES } from "./tokens";

export function SeverityPill({
  severity,
  className,
}: {
  severity: Enums<"severity_level">;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex rounded-pill px-3.5 py-1.5 font-sans text-[13px] font-semibold",
        SEVERITY_PILL_CLASSES[severity],
        className,
      )}
    >
      Tingkat {SEVERITY_LABEL[severity].toLowerCase()}
    </span>
  );
}

export function ZoneStatusPill({
  status,
  className,
}: {
  status: Enums<"zone_status">;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex rounded-pill px-2.5 py-1 font-sans text-[11.5px] font-semibold",
        ZONE_STATUS_PILL_CLASSES[status],
        className,
      )}
    >
      {ZONE_STATUS_LABEL[status]}
    </span>
  );
}

// Badge keyakinan model -- SENGAJA selalu rust (aksen dekoratif, bukan indikator
// severity), persis seperti satu-satunya contoh di mockup ("92% keyakinan").
// Jangan diubah jadi warna dinamis berdasarkan nilai confidence -- itu akan
// bentrok makna dengan sistem warna severity yang sudah tetap.
export function ConfidencePill({ confidence, className }: { confidence: number; className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex rounded-pill bg-rust-tint px-3.5 py-1.5 font-sans text-[13px] font-semibold text-rust-text",
        className,
      )}
    >
      {Math.round(confidence * 100)}% keyakinan
    </span>
  );
}
