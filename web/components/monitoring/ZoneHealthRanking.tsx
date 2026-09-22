import Link from "next/link";

import { ChevronRightIcon } from "@/components/icons";
import { ZONE_STATUS_DOT_CLASSES } from "@/components/severity/tokens";
import { CROP_LABEL } from "@/lib/format";
import type { Enums } from "@/types/database.types";

export interface RankingRow {
  zoneId: string;
  zoneName: string;
  cropType: Enums<"crop_type">;
  status: Enums<"zone_status"> | null;
  currentScore: number | null;
  trendDelta: number | null;
}

function TrendArrow({ delta }: { delta: number | null }) {
  if (delta == null || Math.abs(delta) < 1) {
    return <span className="font-sans text-[12px] text-sage">Stabil</span>;
  }
  const up = delta > 0;
  return (
    <span className={`font-sans text-[12px] font-medium ${up ? "text-moss-deep" : "text-rust-text"}`}>
      {up ? "▲" : "▼"} {Math.abs(Math.round(delta))}
    </span>
  );
}

/** Diurutkan dari health_score TERENDAH -- zona yang paling butuh perhatian di atas. */
export function ZoneHealthRanking({ rows }: { rows: RankingRow[] }) {
  if (rows.length === 0) {
    return <p className="font-sans text-[13.5px] text-sage">Belum ada zona.</p>;
  }

  return (
    <div className="flex flex-col">
      {rows.map((row, i) => (
        <Link
          key={row.zoneId}
          href={`/zona/${row.zoneId}`}
          className={`flex items-center gap-3 py-3 ${i < rows.length - 1 ? "border-b border-leaf-panel-bg" : ""}`}
        >
          <div
            className={`h-2 w-2 shrink-0 rounded-full ${
              row.status ? ZONE_STATUS_DOT_CLASSES[row.status] : "bg-sage"
            }`}
          />
          <span className="flex-1 font-sans text-[13.5px] text-ink">
            {row.zoneName} — {CROP_LABEL[row.cropType]}
          </span>
          <span className="font-display text-[15px] font-semibold text-ink">
            {row.currentScore != null ? Math.round(row.currentScore) : "—"}
          </span>
          <div className="w-14 text-right">
            <TrendArrow delta={row.trendDelta} />
          </div>
          <ChevronRightIcon size={14} className="text-muted-2" />
        </Link>
      ))}
    </div>
  );
}
