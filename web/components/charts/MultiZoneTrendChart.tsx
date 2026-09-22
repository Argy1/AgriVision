"use client";

import { format } from "date-fns";
import { id as idLocale } from "date-fns/locale";
import { Line, LineChart, ResponsiveContainer, Tooltip, YAxis } from "recharts";
import type { DotItemDotProps } from "recharts";

import { parseDateOnly } from "@/lib/format";

// Palet kategorikal untuk perbandingan multi-zona -- SENGAJA tidak memakai
// hijau/oranye/kuning-ochre/merah-rust supaya tidak bentrok makna dengan trio
// warna status (moss=sehat, ochre=waspada, rust=perlu tindakan) yang dipakai
// di seluruh app. Divalidasi lewat skill dataviz (validate_palette.js): lolos
// semua gate wajib, satu WARN pita CVD 6-8 (legal dengan direct label/legend,
// yang sudah disediakan di bawah).
export const ZONE_CHART_COLORS = ["#2a78d6", "#1baf7a", "#e87ba4", "#4a3aa7", "#e34948"];
const MAX_ZONES_ON_CHART = ZONE_CHART_COLORS.length;

export interface ZoneSeries {
  zoneId: string;
  zoneName: string;
  points: { date: string; value: number | null }[];
}

export function MultiZoneTrendChart({ series }: { series: ZoneSeries[] }) {
  const shown = series.slice(0, MAX_ZONES_ON_CHART);
  const overflow = series.length - shown.length;

  if (shown.length === 0) {
    return (
      <div className="flex h-[220px] items-center justify-center font-sans text-[13px] text-sage">
        Belum ada data untuk zona yang dipilih.
      </div>
    );
  }

  const dates = shown[0].points.map((p) => p.date);
  const chartData = dates.map((date, i) => {
    const row: Record<string, string | number | null> = { date };
    shown.forEach((s) => {
      row[s.zoneId] = s.points[i]?.value ?? null;
    });
    return row;
  });

  return (
    <div>
      <div className="mb-3 flex flex-wrap gap-x-4 gap-y-1.5">
        {shown.map((s, i) => (
          <div key={s.zoneId} className="flex items-center gap-1.5">
            <span
              className="h-2.5 w-2.5 rounded-full"
              style={{ backgroundColor: ZONE_CHART_COLORS[i] }}
            />
            <span className="font-sans text-[12.5px] text-ink">{s.zoneName}</span>
          </div>
        ))}
      </div>

      <ResponsiveContainer width="100%" height={220}>
        <LineChart data={chartData} margin={{ top: 8, right: 8, left: 8, bottom: 0 }}>
          <YAxis domain={[0, 100]} hide />
          <Tooltip
            labelFormatter={(label) => format(parseDateOnly(String(label)), "d MMM", { locale: idLocale })}
            formatter={(value, name) => {
              const key = String(name);
              const zone = shown.find((s) => s.zoneId === key);
              return [value != null ? `${Math.round(Number(value))}/100` : "-", zone?.zoneName ?? key];
            }}
            contentStyle={{ fontSize: 12.5, borderRadius: 8, borderColor: "#E3DFCF" }}
          />
          {shown.map((s, i) => {
            // Sama seperti HealthTrendChart: tandai titik TERAKHIR yang punya
            // nilai nyata per zona, supaya garis dengan cuma 1 titik data tetap
            // terlihat (dot={false} + connectNulls tanpa ini render kosong).
            const lastRealIndex = s.points.reduce(
              (acc, p, idx) => (p.value != null ? idx : acc),
              -1,
            );
            function renderDot(props: DotItemDotProps) {
              if (props.index !== lastRealIndex || props.cx == null || props.cy == null) {
                return <g key={props.index} />;
              }
              return <circle key={props.index} cx={props.cx} cy={props.cy} r={4} fill={ZONE_CHART_COLORS[i]} />;
            }
            return (
              <Line
                key={s.zoneId}
                type="monotone"
                dataKey={s.zoneId}
                stroke={ZONE_CHART_COLORS[i]}
                strokeWidth={2}
                dot={renderDot}
                connectNulls
              />
            );
          })}
        </LineChart>
      </ResponsiveContainer>

      {overflow > 0 && (
        <p className="mt-2 font-sans text-[12px] text-sage">
          +{overflow} zona lainnya tidak ditampilkan di grafik (batas {MAX_ZONES_ON_CHART} garis
          per grafik) — lihat tabel ranking di bawah untuk semua zona.
        </p>
      )}
    </div>
  );
}
