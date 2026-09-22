import Link from "next/link";

import { SeverityPill } from "@/components/severity/SeverityBadge";
import { CROP_LABEL, formatRelativeDateTime } from "@/lib/format";
import type { Enums } from "@/types/database.types";

export interface HistoryRow {
  id: string;
  disease_name: string;
  severity: Enums<"severity_level">;
  confidence: number;
  created_at: string;
  zoneName: string;
  cropType: Enums<"crop_type">;
}

export function HistoryTable({ rows, showZoneColumn = true }: { rows: HistoryRow[]; showZoneColumn?: boolean }) {
  if (rows.length === 0) {
    return (
      <p className="py-8 text-center font-sans text-[13.5px] text-sage">
        Tidak ada riwayat yang cocok.
      </p>
    );
  }

  return (
    <div className="flex flex-col">
      <div className="grid grid-cols-[1fr_auto_auto_auto] gap-4 border-b border-border-soft pb-2.5 font-sans text-[12px] font-medium text-sage">
        <span>Diagnosis</span>
        {showZoneColumn && <span>Zona</span>}
        <span>Keyakinan</span>
        <span>Tanggal</span>
      </div>
      {rows.map((row) => (
        <Link
          key={row.id}
          href={`/diagnosis/${row.id}`}
          className="grid grid-cols-[1fr_auto_auto_auto] items-center gap-4 border-b border-leaf-panel-bg py-3 last:border-0"
        >
          <div className="flex items-center gap-2.5">
            <SeverityPill severity={row.severity} />
            <span className="font-sans text-[13.5px] text-ink">{row.disease_name}</span>
          </div>
          {showZoneColumn && (
            <span className="font-sans text-[13px] text-sage">
              {row.zoneName} · {CROP_LABEL[row.cropType]}
            </span>
          )}
          <span className="font-sans text-[13px] text-sage">{Math.round(row.confidence * 100)}%</span>
          <span className="font-sans text-[13px] text-sage">{formatRelativeDateTime(row.created_at)}</span>
        </Link>
      ))}
    </div>
  );
}
