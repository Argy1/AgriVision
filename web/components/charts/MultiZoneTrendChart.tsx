"use client";

import { format } from "date-fns";
import { id as idLocale } from "date-fns/locale";
import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

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
  /** measured=false: `value` hanya nilai terakhir yang dibawa maju -> tidak digambar. */
  points: { date: string; value: number | null; measured?: boolean }[];
}

const AXIS_TICK = { fontSize: 11.5, fill: "#8B9280" }; // sage

function formatDay(date: string) {
  return format(parseDateOnly(date), "d MMM", { locale: idLocale });
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
      const p = s.points[i];
      // Hanya hari yang benar-benar ada pemeriksaan; garis menyambung titik-titik itu.
      row[s.zoneId] = p && p.measured !== false ? p.value : null;
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

      <ResponsiveContainer width="100%" height={240}>
        <LineChart data={chartData} margin={{ top: 10, right: 12, left: 0, bottom: 0 }}>
          <CartesianGrid vertical={false} stroke="#EEEADC" />
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
          <Tooltip
            // Tanggal diambil dari data titik yang disorot (bukan `label`), supaya
            // tooltip tidak bergantung pada konfigurasi sumbu X.
            labelFormatter={(_, payload) => {
              const date = payload?.[0]?.payload?.date;
              return date ? formatDay(String(date)) : "";
            }}
            cursor={{ stroke: "#DED9C7" }}
            formatter={(value, name) => {
              const key = String(name);
              const zone = shown.find((s) => s.zoneId === key);
              return [value != null ? `${Math.round(Number(value))}/100` : "-", zone?.zoneName ?? key];
            }}
            contentStyle={{ fontSize: 12.5, borderRadius: 8, borderColor: "#E3DFCF" }}
          />
          {shown.map((s, i) => (
            // Titik di setiap hari pemeriksaan (cincin putih memisahkan titik yang
            // bertumpuk antar-zona), garis menyambung hari-hari itu.
            <Line
              key={s.zoneId}
              type="monotone"
              dataKey={s.zoneId}
              stroke={ZONE_CHART_COLORS[i]}
              strokeWidth={2}
              dot={{ r: 4, fill: ZONE_CHART_COLORS[i], stroke: "#FFFFFF", strokeWidth: 2 }}
              activeDot={{ r: 6, fill: ZONE_CHART_COLORS[i], stroke: "#FFFFFF", strokeWidth: 2 }}
              connectNulls
              isAnimationActive={false}
            />
          ))}
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
