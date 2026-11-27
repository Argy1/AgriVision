import type { Metadata } from "next";

import { DiseaseFrequencyChart } from "@/components/analytics/DiseaseFrequencyChart";
import { SeverityTrendChart } from "@/components/analytics/SeverityTrendChart";
import { PageContainer } from "@/components/layout/PageContainer";
import { PageHeader } from "@/components/layout/PageHeader";
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
    <PageContainer>
      <PageHeader
        eyebrow="Analitik"
        title="Wawasan kebun 8 minggu terakhir"
        subtitle="Ringkasan penyakit yang paling sering muncul dan tren keparahannya di semua zona."
        pose="happy"
        actions={
          <div className="rounded-xl bg-white/10 px-4 py-3 ring-1 ring-white/20 backdrop-blur-sm">
            <div className="font-display text-[26px] font-semibold leading-none text-white">
              {avgConfidence != null ? `${Math.round(avgConfidence * 100)}%` : "—"}
            </div>
            <div className="mt-1 font-sans text-[12px] text-white/80">
              Rata-rata keyakinan model
              <span className="block text-[11px] text-white/60">bukan ukuran akurasi</span>
            </div>
          </div>
        }
      />

      <div className="grid gap-5 md:grid-cols-2">
        <Card className="min-w-0 p-4 sm:p-5.5">
          <CardTitle className="mb-1">Distribusi Penyakit</CardTitle>
          <p className="mb-3 font-sans text-[12.5px] text-sage">
            Penyakit paling sering terdeteksi (8 minggu terakhir)
          </p>
          <DiseaseFrequencyChart data={diseaseFrequency} />
        </Card>

        <Card className="min-w-0 p-4 sm:p-5.5">
          <CardTitle className="mb-1">Tren Tingkat Keparahan</CardTitle>
          <p className="mb-3 font-sans text-[12.5px] text-sage">Jumlah diagnosis per minggu</p>
          <SeverityTrendChart data={severityTrend} />
        </Card>
      </div>
    </PageContainer>
  );
}
