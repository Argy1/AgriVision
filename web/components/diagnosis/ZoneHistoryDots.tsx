import Link from "next/link";

import { ChevronRightIcon } from "@/components/icons";
import { SEVERITY_DOT_CLASSES } from "@/components/severity/tokens";
import type { Enums } from "@/types/database.types";

export function ZoneHistoryDots({
  zoneId,
  zoneName,
  severities,
}: {
  zoneId: string;
  zoneName: string;
  severities: Enums<"severity_level">[];
}) {
  return (
    <div className="flex items-center justify-between">
      <div className="flex items-center gap-2.5">
        <span className="font-sans text-[13px] text-sage">Riwayat Zona {zoneName}</span>
        <div className="flex gap-1.5">
          {severities.map((severity, i) => (
            <div key={i} className={`h-2 w-2 rounded-full ${SEVERITY_DOT_CLASSES[severity]}`} />
          ))}
        </div>
      </div>
      <Link
        href={`/zona/${zoneId}`}
        className="flex items-center gap-1 font-sans text-[13px] font-medium text-moss"
      >
        Lihat riwayat lengkap
        <ChevronRightIcon size={14} />
      </Link>
    </div>
  );
}
