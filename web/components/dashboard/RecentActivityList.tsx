import Link from "next/link";

import { LeafGlyph } from "@/components/leaf-illustration/LeafGlyph";
import { SeverityPill } from "@/components/severity/SeverityBadge";
import { formatTimeAgo } from "@/lib/format";
import type { Enums } from "@/types/database.types";

export interface ActivityRow {
  id: string;
  disease_name: string;
  severity: Enums<"severity_level">;
  created_at: string;
  zoneName: string;
}

export function RecentActivityList({ rows }: { rows: ActivityRow[] }) {
  if (rows.length === 0) {
    return <p className="font-sans text-[13.5px] text-sage">Belum ada aktivitas.</p>;
  }

  return (
    <div className="flex flex-col gap-1">
      {rows.map((row) => (
        <Link
          key={row.id}
          href={`/diagnosis/${row.id}`}
          className="flex flex-wrap items-center gap-x-3 gap-y-1.5 py-2 sm:flex-nowrap sm:py-1.5"
        >
          <LeafGlyph severity={row.severity} width={26} height={29} />
          <span className="min-w-0 flex-[1_1_calc(100%-3rem)] font-sans text-[13.5px] text-ink sm:flex-1">
            {row.disease_name} terdeteksi di Zona {row.zoneName}
          </span>
          <div className="flex items-center gap-3 pl-[38px] sm:pl-0">
            <span className="font-sans text-[12.5px] text-sage">{formatTimeAgo(row.created_at)}</span>
            <SeverityPill severity={row.severity} />
          </div>
        </Link>
      ))}
    </div>
  );
}
