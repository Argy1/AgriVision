import type { Metadata } from "next";
import Link from "next/link";

import { HealthTrendChart } from "@/components/charts/HealthTrendChart";
import { RecentActivityList } from "@/components/dashboard/RecentActivityList";
import { StatTile } from "@/components/dashboard/StatTile";
import { ZoneStatusList } from "@/components/dashboard/ZoneStatusList";
import { CameraIcon, GridIcon, LeafLogoIcon, WarningTriangleIcon } from "@/components/icons";
import { PageContainer } from "@/components/layout/PageContainer";
import { PageHeader } from "@/components/layout/PageHeader";
import { Card, CardTitle } from "@/components/ui/Card";
import { getProfile } from "@/lib/data/auth";
import { getDashboardStats, getRecentActivity } from "@/lib/data/dashboard";
import { buildDailyAverageSeries, getLatestZoneHealth, getZoneHealthHistory } from "@/lib/data/zone-health";
import { formatLongDate, inJakarta } from "@/lib/format";

export const metadata: Metadata = { title: "Dashboard — AgriVision" };

function firstName(fullName: string) {
  return fullName.split(" ")[0];
}

function greeting() {
  const hour = inJakarta(new Date()).getHours(); // jam WIB, bukan jam server (Vercel = UTC)
  if (hour < 11) return "Selamat pagi";
  if (hour < 15) return "Selamat siang";
  if (hour < 19) return "Selamat sore";
  return "Selamat malam";
}

export default async function DashboardPage() {
  const [profile, stats, zoneHealth, healthHistory, activity] = await Promise.all([
    getProfile(),
    getDashboardStats(),
    getLatestZoneHealth(),
    getZoneHealthHistory(30),
    getRecentActivity(5),
  ]);

  const attentionZones = zoneHealth.filter((z) => z.health?.status === "perlu_tindakan").length;
  const scores = zoneHealth.map((z) => z.health?.avg_health_score).filter((v): v is number => v != null);
  const avgHealthScore = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : null;

  const trendSeries = buildDailyAverageSeries(healthHistory, 30);

  return (
    <PageContainer>
      <PageHeader
        eyebrow={formatLongDate(new Date())}
        title={`${greeting()}, ${firstName(profile.full_name)}`}
        subtitle="Ringkasan kesehatan kebun tomat Anda hari ini."
        pose="wave"
        actions={
          <>
            <Link
              href="/upload"
              className="inline-flex items-center gap-2 rounded-sm bg-straw px-4 py-2.5 font-sans text-[13.5px] font-semibold text-ink hover:brightness-105"
            >
              <CameraIcon size={16} /> Diagnosis baru
            </Link>
            <Link
              href="/monitoring"
              className="inline-flex items-center rounded-sm border border-white/40 px-4 py-2.5 font-sans text-[13.5px] font-semibold text-white hover:bg-white/10"
            >
              Lihat monitoring
            </Link>
          </>
        }
      />

      <div className="grid grid-cols-2 gap-3 sm:gap-4 md:grid-cols-4">
        <StatTile icon={<GridIcon size={19} className="text-moss" />} value={stats.zoneCount} label="Zona dipantau" />
        <StatTile
          icon={<CameraIcon size={19} className="text-ink" />}
          value={stats.diagnosisWeekCount}
          label="Diagnosis minggu ini"
        />
        <StatTile
          icon={<WarningTriangleIcon size={19} className={attentionZones > 0 ? "text-rust" : "text-sage"} />}
          value={attentionZones}
          label="Zona perlu perhatian"
          variant={attentionZones > 0 ? "attention" : "default"}
        />
        <StatTile
          icon={<LeafLogoIcon size={19} className="text-moss" />}
          value={avgHealthScore ?? "—"}
          suffix={avgHealthScore != null ? "/100" : undefined}
          label="Skor kesehatan rata-rata"
        />
      </div>

      <div className="grid gap-5 md:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]">
        <Card className="min-w-0 p-4 sm:p-5.5">
          <CardTitle className="mb-4">Tren kesehatan tanaman — 30 hari terakhir</CardTitle>
          <HealthTrendChart data={trendSeries} />
        </Card>

        <Card className="min-w-0 p-4 sm:p-5.5">
          <CardTitle className="mb-3.5">Status zona</CardTitle>
          <ZoneStatusList
            rows={zoneHealth.map((z) => ({ zone: z.zone, status: z.health?.status ?? null }))}
          />
        </Card>
      </div>

      <Card className="p-4.5">
        <CardTitle className="mb-3">Aktivitas terbaru</CardTitle>
        <RecentActivityList
          rows={activity.map((a) => ({
            id: a.id,
            disease_name: a.disease_name,
            severity: a.severity,
            created_at: a.created_at,
            zoneName: a.uploads.zones.name,
          }))}
        />
      </Card>
    </PageContainer>
  );
}
