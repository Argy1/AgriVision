import type { Metadata } from "next";
import { Suspense } from "react";

import { MultiZoneTrendChart } from "@/components/charts/MultiZoneTrendChart";
import { TimeRangeToggle } from "@/components/monitoring/TimeRangeToggle";
import { ZoneHealthRanking } from "@/components/monitoring/ZoneHealthRanking";
import { PageContainer } from "@/components/layout/PageContainer";
import { PageHeader } from "@/components/layout/PageHeader";
import { Card, CardTitle } from "@/components/ui/Card";
import { getLatestZoneHealth, buildPerZoneSeries, computeTrendDelta, getZoneHealthHistory } from "@/lib/data/zone-health";

export const metadata: Metadata = { title: "Monitoring — AgriVision" };

const VALID_RANGES = ["7", "30", "90"];

export default async function MonitoringPage({
  searchParams,
}: {
  searchParams: Promise<{ range?: string }>;
}) {
  const { range } = await searchParams;
  const days = VALID_RANGES.includes(range ?? "") ? Number(range) : 30;

  const [zoneHealth, history] = await Promise.all([
    getLatestZoneHealth(),
    getZoneHealthHistory(Math.max(days, 14)), // butuh >=14 hari untuk hitung delta tren 7 hari
  ]);

  const zoneIds = zoneHealth.map((z) => z.zone.id);
  const perZoneSeries = buildPerZoneSeries(history, zoneIds, Math.max(days, 14));

  const chartSeries = zoneHealth.map((z) => {
    const series = perZoneSeries.find((s) => s.zoneId === z.zone.id);
    const points = series ? series.points.slice(-days) : [];
    return { zoneId: z.zone.id, zoneName: z.zone.name, points };
  });

  const rankingRows = zoneHealth
    .map((z) => {
      const series = perZoneSeries.find((s) => s.zoneId === z.zone.id);
      return {
        zoneId: z.zone.id,
        zoneName: z.zone.name,
        status: z.health?.status ?? null,
        currentScore: z.health?.avg_health_score ?? null,
        trendDelta: series ? computeTrendDelta(series.points) : null,
      };
    })
    .sort((a, b) => (a.currentScore ?? 100) - (b.currentScore ?? 100));

  return (
    <PageContainer>
      <PageHeader
        eyebrow="Monitoring"
        title="Kesehatan tanaman per zona"
        subtitle="Pantau tren skor kesehatan seluruh zona kebun dari waktu ke waktu."
        pose="lens"
        actions={
          <Suspense fallback={null}>
            <TimeRangeToggle current={String(days)} />
          </Suspense>
        }
      />

      <Card className="p-4 sm:p-5.5">
        <CardTitle className="mb-4">
          Perbandingan tren kesehatan — {days} hari terakhir
        </CardTitle>
        <MultiZoneTrendChart series={chartSeries} />
      </Card>

      <Card className="p-4 sm:p-5.5">
        <CardTitle className="mb-2">Ranking zona berdasarkan kesehatan</CardTitle>
        <p className="mb-3 font-sans text-[12.5px] text-sage">
          Diurutkan dari skor kesehatan terendah — zona yang paling butuh perhatian di atas.
        </p>
        <ZoneHealthRanking rows={rankingRows} />
      </Card>
    </PageContainer>
  );
}
