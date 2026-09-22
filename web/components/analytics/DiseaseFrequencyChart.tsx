"use client";

import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

export function DiseaseFrequencyChart({
  data,
}: {
  data: { disease_name: string; count: number }[];
}) {
  if (data.length === 0) {
    return (
      <div className="flex h-[260px] items-center justify-center font-sans text-[13px] text-sage">
        Belum ada data diagnosis pada rentang ini.
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={Math.max(220, data.length * 36)}>
      <BarChart data={data} layout="vertical" margin={{ top: 4, right: 24, left: 4, bottom: 4 }}>
        <CartesianGrid horizontal={false} stroke="#EEEADC" />
        <XAxis type="number" allowDecimals={false} tick={{ fontSize: 11.5, fill: "#B7B2A0" }} axisLine={false} tickLine={false} />
        <YAxis
          type="category"
          dataKey="disease_name"
          width={180}
          tick={{ fontSize: 12.5, fill: "#20261B" }}
          axisLine={false}
          tickLine={false}
        />
        <Tooltip
          formatter={(value) => [`${value}×`, "Jumlah"]}
          contentStyle={{ fontSize: 12.5, borderRadius: 8, borderColor: "#E3DFCF" }}
        />
        {/* Warna netral (moss-mid) -- SENGAJA bukan moss/ochre/rust, supaya urutan
            frekuensi ini tidak salah dibaca sebagai indikator severity/status. */}
        <Bar dataKey="count" radius={[0, 4, 4, 0]} barSize={16} fill="#5C7A4E" />
      </BarChart>
    </ResponsiveContainer>
  );
}
