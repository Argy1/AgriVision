import type { Metadata } from "next";

import { DiseaseFrequencyChart } from "@/components/analytics/DiseaseFrequencyChart";
import { SeverityTrendChart } from "@/components/analytics/SeverityTrendChart";
import { Card, CardTitle } from "@/components/ui/Card";
import { getAverageConfidence, getDiseaseFrequency, getSeverityTrendByWeek } from "@/lib/data/analytics";

export const metadata: Metadata = { title: "Analitik — AgriVision" };

export default async function AnalitikPage() {
  const [diseaseFrequency, severityTrend, avgConfidence] = await Promise.all([
    getDiseaseFrequency(),
    getSeverityTrendByWeek(),
    getAverageConfidence(),
  ]);

  return (
    <div className="flex h-screen flex-col gap-5 overflow-y-auto p-9 pb-16">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-display text-[27px] font-semibold text-ink">Analitik</h1>
          <p className="mt-1.5 font-sans text-[14px] text-sage">
            Insight agregat lintas zona dari 8 minggu terakhir
          </p>
        </div>
      </div>

      <Card className="w-fit p-4.5">
        <div className="font-display text-[26px] font-semibold text-ink">
          {avgConfidence != null ? `${Math.round(avgConfidence * 100)}%` : "—"}
        </div>
        <div className="font-sans text-[12.5px] text-sage">
          Rata-rata Keyakinan Model{" "}
          <span className="text-muted-2">(bukan ukuran akurasi — lihat catatan evaluasi model)</span>
        </div>
      </Card>

      <div className="flex gap-5">
        <Card className="flex-1 p-5.5">
          <CardTitle className="mb-1">Distribusi Penyakit</CardTitle>
          <p className="mb-3 font-sans text-[12.5px] text-sage">
            Penyakit paling sering terdeteksi (8 minggu terakhir)
          </p>
          <DiseaseFrequencyChart data={diseaseFrequency} />
        </Card>

        <Card className="flex-1 p-5.5">
          <CardTitle className="mb-1">Tren Tingkat Keparahan</CardTitle>
          <p className="mb-3 font-sans text-[12.5px] text-sage">Jumlah diagnosis per minggu</p>
          <SeverityTrendChart data={severityTrend} />
        </Card>
      </div>
    </div>
  );
}
