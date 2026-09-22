import type { Metadata } from "next";

import { HealthTrendChart } from "@/components/charts/HealthTrendChart";
import { RecentActivityList } from "@/components/dashboard/RecentActivityList";
import { StatTile } from "@/components/dashboard/StatTile";
import { ZoneStatusList } from "@/components/dashboard/ZoneStatusList";
import { CameraIcon, GridIcon, LeafLogoIcon, WarningTriangleIcon } from "@/components/icons";
import { Card, CardTitle } from "@/components/ui/Card";
import { getProfile } from "@/lib/data/auth";
import { getDashboardStats, getRecentActivity } from "@/lib/data/dashboard";
import { buildDailyAverageSeries, getLatestZoneHealth, getZoneHealthHistory } from "@/lib/data/zone-health";
import { formatLongDate } from "@/lib/format";

export const metadata: Metadata = { title: "Dashboard — AgriVision" };

function firstName(fullName: string) {
  return fullName.split(" ")[0];
}

function greeting() {
  const hour = new Date().getHours();
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
    <div className="flex h-screen flex-col gap-5 overflow-y-auto p-9 pb-16">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">
            {greeting()}, {firstName(profile.full_name)}
          </h1>
          <p className="mt-1 font-sans text-[13.5px] text-sage">{formatLongDate(new Date())}</p>
        </div>
      </div>

      <div className="flex gap-4">
        <StatTile icon={<GridIcon size={19} className="text-moss" />} value={stats.zoneCount} label="Zona dipantau" />
        <StatTile
          icon={<CameraIcon size={19} className="text-ink" />}
          value={stats.diagnosisWeekCount}
          label="Diagnosis minggu ini"
        />
        <StatTile
          icon={<WarningTriangleIcon size={19} className="text-rust" />}
          value={attentionZones}
          label="Zona perlu perhatian"
          variant="attention"
        />
        <StatTile
          icon={<LeafLogoIcon size={19} className="text-moss" />}
          value={avgHealthScore ?? "—"}
          suffix={avgHealthScore != null ? "/100" : undefined}
          label="Skor kesehatan rata-rata"
        />
      </div>

      <div className="flex min-h-0 flex-1 gap-5">
        <Card className="w-[620px] shrink-0 p-5.5">
          <CardTitle className="mb-4">Tren kesehatan tanaman — 30 hari terakhir</CardTitle>
          <HealthTrendChart data={trendSeries} />
        </Card>

        <Card className="flex-1 p-5.5">
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
    </div>
  );
}
