import Link from "next/link";

import { SeverityPill } from "@/components/severity/SeverityBadge";
import { formatRelativeDateTime } from "@/lib/format";
import type { Enums } from "@/types/database.types";

export interface HistoryRow {
  id: string;
  disease_name: string;
  severity: Enums<"severity_level">;
  confidence: number;
  created_at: string;
  zoneName: string;
}

export function HistoryTable({ rows, showZoneColumn = true }: { rows: HistoryRow[]; showZoneColumn?: boolean }) {
  if (rows.length === 0) {
    return (
      <p className="py-8 text-center font-sans text-[13.5px] text-sage">
        Tidak ada riwayat yang cocok.
      </p>
    );
  }

  // Container query: pada lebar kartu >= 576px tampil sebagai tabel berkolom; lebih
  // sempit (HP, atau kartu yang berbagi baris di layar sedang) tiap baris jadi kartu
  // bertumpuk supaya tidak ada kolom yang terpotong / tidak sejajar.
  const cols = showZoneColumn
    ? "@xl:grid-cols-[minmax(0,1fr)_auto_auto_auto]"
    : "@xl:grid-cols-[minmax(0,1fr)_auto_auto]";

  return (
    <div className="@container flex flex-col">
      <div className={`hidden gap-4 border-b border-border-soft pb-2.5 font-sans text-[12px] font-medium text-sage @xl:grid ${cols}`}>
        <span>Diagnosis</span>
        {showZoneColumn && <span>Zona</span>}
        <span>Keyakinan</span>
        <span>Tanggal</span>
      </div>
      {rows.map((row) => (
        <Link
          key={row.id}
          href={`/diagnosis/${row.id}`}
          className={`grid grid-cols-1 gap-1.5 border-b border-leaf-panel-bg py-3 last:border-0 @xl:items-center @xl:gap-4 ${cols}`}
        >
          <div className="flex min-w-0 flex-wrap items-center gap-x-2.5 gap-y-1.5 @xl:flex-nowrap">
            <div className="@xl:shrink-0">
              <SeverityPill severity={row.severity} />
            </div>
            <span className="min-w-0 basis-full font-sans text-[13.5px] text-ink @xl:flex-1 @xl:basis-auto">
              {row.disease_name}
            </span>
          </div>
          <div className="flex flex-wrap gap-x-3 gap-y-0.5 font-sans text-[13px] text-sage @xl:contents">
            {showZoneColumn && <span><span className="@xl:hidden">Zona </span>{row.zoneName}</span>}
            <span>{Math.round(row.confidence * 100)}%</span>
            <span>{formatRelativeDateTime(row.created_at)}</span>
          </div>
        </Link>
      ))}
    </div>
  );
}
