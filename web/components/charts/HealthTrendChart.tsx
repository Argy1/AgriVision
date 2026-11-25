"use client";

import { useId } from "react";
import { format } from "date-fns";
import { id as idLocale } from "date-fns/locale";
import { Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

import { parseDateOnly } from "@/lib/format";

export interface TrendPoint {
  date: string;
  value: number | null;
  /** true = hari itu ada pemeriksaan foto. false = `value` hanya nilai terakhir yang
   * dibawa maju, jadi TIDAK digambar sebagai titik. undefined = anggap terukur. */
  measured?: boolean;
}

const LINE_COLOR = "#46603C"; // moss (warna brand); garis tunggal, bukan makna status
const AXIS_TICK = { fontSize: 11.5, fill: "#8B9280" }; // sage
const GRID_COLOR = "#EEEADC";

function formatDay(date: string) {
  return format(parseDateOnly(date), "d MMM", { locale: idLocale });
}

// Tanggal diambil dari data titik yang disorot (payload[0].payload.date), bukan dari
// `label`, supaya tooltip tidak bergantung pada konfigurasi sumbu X.
function CustomTooltip({ active, payload }: { active?: boolean; payload?: Array<{ value: number | null; payload?: TrendPoint }> }) {
  if (!active || !payload?.length || payload[0].value == null) return null;
  const date = payload[0].payload?.date;
  return (
    <div className="rounded-sm border border-border-soft bg-paper px-3 py-1.5 font-sans text-[12.5px] shadow-sm">
      <div className="text-sage">{date && formatDay(date)}</div>
      <div className="font-semibold text-ink">Skor kesehatan {Math.round(payload[0].value)}/100</div>
    </div>
  );
}

/** Tren skor kesehatan (0-100) satu seri: area chart dengan sumbu Y 0-100 dan tanggal
 * di sumbu X. Titik hanya digambar di hari yang benar-benar ada pemeriksaan, lalu
 * disambung; hari tanpa pemeriksaan tidak diisi nilai palsu. */
export function HealthTrendChart({ data }: { data: TrendPoint[] }) {
  const gradientId = `health-fill-${useId().replace(/:/g, "")}`;
  const chartData = data.map((d) => ({ ...d, value: d.measured === false ? null : d.value }));
  const hasData = chartData.some((d) => d.value != null);

  if (!hasData) {
    return (
      <div className="flex h-[220px] items-center justify-center font-sans text-[13px] text-sage">
        Belum ada data kesehatan tanaman.
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={220}>
      <AreaChart data={chartData} margin={{ top: 10, right: 12, left: 0, bottom: 0 }}>
        <defs>
          <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={LINE_COLOR} stopOpacity={0.18} />
            <stop offset="100%" stopColor={LINE_COLOR} stopOpacity={0.02} />
          </linearGradient>
        </defs>
        <CartesianGrid vertical={false} stroke={GRID_COLOR} />
        <XAxis
          dataKey="date"
          tickFormatter={(v) => formatDay(String(v))}
          tick={AXIS_TICK}
          axisLine={false}
          tickLine={false}
          minTickGap={28}
          interval="preserveStartEnd"
        />
        <YAxis
          domain={[0, 100]}
          ticks={[0, 25, 50, 75, 100]}
          width={34}
          tick={AXIS_TICK}
          axisLine={false}
          tickLine={false}
        />
        <Tooltip content={<CustomTooltip />} cursor={{ stroke: "#DED9C7" }} />
        <Area
          type="monotone"
          dataKey="value"
          stroke={LINE_COLOR}
          strokeWidth={2}
          fill={`url(#${gradientId})`}
          connectNulls
          isAnimationActive={false}
          dot={{ r: 4, fill: LINE_COLOR, stroke: "#FFFFFF", strokeWidth: 2 }}
          activeDot={{ r: 6, fill: LINE_COLOR, stroke: "#FFFFFF", strokeWidth: 2 }}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
