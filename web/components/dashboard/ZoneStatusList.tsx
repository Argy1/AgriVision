import Link from "next/link";

import { ChevronRightIcon } from "@/components/icons";
import { ZONE_STATUS_DOT_CLASSES } from "@/components/severity/tokens";
import { CROP_LABEL } from "@/lib/format";
import type { Enums } from "@/types/database.types";

export interface ZoneStatusRow {
  zone: { id: string; name: string; crop_type: Enums<"crop_type"> };
  status: Enums<"zone_status"> | null;
}

export function ZoneStatusList({ rows }: { rows: ZoneStatusRow[] }) {
  if (rows.length === 0) {
    return <p className="font-sans text-[13.5px] text-sage">Belum ada zona.</p>;
  }

  return (
    <div className="flex flex-col">
      {rows.map((row, i) => (
        <Link
          key={row.zone.id}
          href={`/zona/${row.zone.id}`}
          className={`flex items-center gap-2.5 py-2.5 ${
            i < rows.length - 1 ? "border-b border-leaf-panel-bg" : ""
          }`}
        >
          <div
            className={`h-2 w-2 shrink-0 rounded-full ${
              row.status ? ZONE_STATUS_DOT_CLASSES[row.status] : "bg-sage"
            }`}
          />
          <span className="flex-1 font-sans text-[13.5px] text-ink">
            {row.zone.name} — {CROP_LABEL[row.zone.crop_type]}
          </span>
          <ChevronRightIcon size={14} className="text-muted-2" />
        </Link>
      ))}
    </div>
  );
}
