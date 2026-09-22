"use client";

import { format } from "date-fns";
import { id as idLocale } from "date-fns/locale";
import { Line, LineChart, ResponsiveContainer, Tooltip, YAxis } from "recharts";
import type { DotItemDotProps } from "recharts";

import { parseDateOnly } from "@/lib/format";

export interface TrendPoint {
  date: string;
  value: number | null;
}

function CustomTooltip({ active, payload, label }: { active?: boolean; payload?: Array<{ value: number }>; label?: string }) {
  if (!active || !payload?.length || payload[0].value == null) return null;
  return (
    <div className="rounded-sm border border-border-soft bg-paper px-3 py-1.5 font-sans text-[12.5px] shadow-sm">
      <div className="text-sage">{label && format(parseDateOnly(label), "d MMM", { locale: idLocale })}</div>
      <div className="font-semibold text-moss-deep">{Math.round(payload[0].value)}/100</div>
    </div>
  );
}

/** Line chart minimal ala mockup (garis moss, tanpa axis berlebih) tapi data-driven
 * lewat Recharts, bukan hand-roll SVG -- supaya beneran merepresentasikan data asli. */
export function HealthTrendChart({ data }: { data: TrendPoint[] }) {
  const hasData = data.some((d) => d.value != null);

  if (!hasData) {
    return (
      <div className="flex h-[170px] items-center justify-center font-sans text-[13px] text-sage">
        Belum ada data kesehatan tanaman.
      </div>
    );
  }

  const labelStep = Math.max(1, Math.floor(data.length / 5));

  // Titik terakhir yang punya nilai nyata -- ditandai bulatan solid persis
  // seperti mockup (<circle cx="560" cy="50" r="4.5" fill="#46603C"/>). Ini
  // juga yang membuat grafik tetap terlihat saat baru ada satu titik data
  // (dot={false} + connectNulls tanpa ini akan render kosong sama sekali,
  // karena garis butuh >=2 titik nyata untuk punya segmen yang bisa digambar).
  const lastRealIndex = data.reduce((acc, d, i) => (d.value != null ? i : acc), -1);
  function renderDot(props: DotItemDotProps) {
    if (props.index !== lastRealIndex || props.cx == null || props.cy == null) {
      return <g key={props.index} />;
    }
    return <circle key={props.index} cx={props.cx} cy={props.cy} r={4.5} fill="#46603C" />;
  }

  return (
    <div>
      <ResponsiveContainer width="100%" height={170}>
        <LineChart data={data} margin={{ top: 8, right: 8, left: 8, bottom: 0 }}>
          <YAxis domain={[0, 100]} hide />
          <Tooltip content={<CustomTooltip />} />
          <Line
            type="monotone"
            dataKey="value"
            stroke="#46603C"
            strokeWidth={2.5}
            dot={renderDot}
            activeDot={{ r: 4.5, fill: "#46603C" }}
            connectNulls
          />
        </LineChart>
      </ResponsiveContainer>
      <div className="mt-1 flex justify-between font-sans text-[11.5px] text-muted-2">
        {data
          .filter((_, i) => i % labelStep === 0)
          .map((d) => (
            <span key={d.date}>{format(parseDateOnly(d.date), "d MMM", { locale: idLocale })}</span>
          ))}
      </div>
    </div>
  );
}
