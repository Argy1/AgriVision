"use client";

import { format } from "date-fns";
import { id as idLocale } from "date-fns/locale";
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

import { parseDateOnly } from "@/lib/format";

export interface WeeklySeverity {
  week: string;
  ringan: number;
  sedang: number;
  parah: number;
}

const LEGEND_LABEL: Record<string, string> = { ringan: "Ringan", sedang: "Sedang", parah: "Parah" };

export function SeverityTrendChart({ data }: { data: WeeklySeverity[] }) {
  if (data.every((d) => d.ringan + d.sedang + d.parah === 0)) {
    return (
      <div className="flex h-[240px] items-center justify-center font-sans text-[13px] text-sage">
        Belum ada data diagnosis pada rentang ini.
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={240}>
      <BarChart data={data} margin={{ top: 4, right: 8, left: 8, bottom: 0 }}>
        <CartesianGrid vertical={false} stroke="#EEEADC" />
        <XAxis
          dataKey="week"
          tickFormatter={(v: string) => format(parseDateOnly(v), "d MMM", { locale: idLocale })}
          tick={{ fontSize: 11.5, fill: "#B7B2A0" }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis allowDecimals={false} tick={{ fontSize: 11.5, fill: "#B7B2A0" }} axisLine={false} tickLine={false} />
        <Tooltip
          labelFormatter={(label) => `Minggu ${format(parseDateOnly(String(label)), "d MMM", { locale: idLocale })}`}
          formatter={(value, name) => [value, LEGEND_LABEL[String(name)] ?? String(name)]}
          contentStyle={{ fontSize: 12.5, borderRadius: 8, borderColor: "#E3DFCF" }}
        />
        <Legend
          formatter={(value) => (
            <span className="font-sans text-[12px] text-ink">{LEGEND_LABEL[String(value)] ?? String(value)}</span>
          )}
        />
        <Bar dataKey="ringan" stackId="s" fill="#46603C" radius={[0, 0, 0, 0]} />
        <Bar dataKey="sedang" stackId="s" fill="#BD8A2E" />
        <Bar dataKey="parah" stackId="s" fill="#AE4F2E" radius={[3, 3, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}
