import { notFound } from "next/navigation";
import Link from "next/link";

import { HealthTrendChart } from "@/components/charts/HealthTrendChart";
import { ZoneStatusPill } from "@/components/severity/SeverityBadge";
import { Card, CardTitle } from "@/components/ui/Card";
import { HistoryTable } from "@/components/history/HistoryTable";
import { getDiagnosesHistory, getZoneDiseaseFrequency } from "@/lib/data/history";
import { getZone } from "@/lib/data/zones";
import { buildDailyAverageSeries, getZoneHealthHistory } from "@/lib/data/zone-health";
import { CROP_LABEL, daysSince } from "@/lib/format";

const ALL_TIME_DAYS = 3650;
const DISPLAY_DAYS = 90;

export default async function ZonaDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const zone = await getZone(id);
  if (!zone) notFound();

  const [history, diseaseFrequency, diagnosesHistory] = await Promise.all([
    getZoneHealthHistory(ALL_TIME_DAYS, [id]),
    getZoneDiseaseFrequency(id),
    getDiagnosesHistory({ zoneId: id, pageSize: 10 }),
  ]);

  const trendSeries = buildDailyAverageSeries(history, DISPLAY_DAYS);
  const latest = [...history].sort((a, b) => b.date.localeCompare(a.date))[0];
  const totalDiagnoses = diseaseFrequency.reduce((sum, d) => sum + d.count, 0);

  return (
    <div className="flex h-screen flex-col gap-5 overflow-y-auto p-9 pb-16">
      <div className="flex items-start justify-between">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="font-display text-[27px] font-semibold text-ink">Zona {zone.name}</h1>
            <span className="rounded-pill bg-moss-tint px-2.5 py-1 font-sans text-[12px] font-medium text-moss-deep">
              {CROP_LABEL[zone.crop_type]}
            </span>
          </div>
          {zone.location_note && (
            <p className="mt-1.5 font-sans text-[13.5px] text-sage">{zone.location_note}</p>
          )}
        </div>
        <Link
          href={`/upload?zone=${zone.id}`}
          className="rounded-sm bg-moss px-5 py-2.5 font-sans text-[13.5px] font-semibold text-white"
        >
          Unggah Foto untuk Zona Ini
        </Link>
      </div>

      <div className="flex gap-4">
        <Card className="flex-1 p-4.5">
          <div className="font-display text-[24px] font-semibold text-ink">
            {latest?.avg_health_score != null ? Math.round(latest.avg_health_score) : "—"}
            <span className="text-[13px] font-normal text-sage">/100</span>
          </div>
          <div className="font-sans text-[12.5px] text-sage">Skor kesehatan terkini</div>
        </Card>
        <Card className="flex-1 p-4.5">
          {latest ? <ZoneStatusPill status={latest.status} /> : <span className="font-sans text-[13px] text-sage">—</span>}
          <div className="mt-2 font-sans text-[12.5px] text-sage">Status zona</div>
        </Card>
        <Card className="flex-1 p-4.5">
          <div className="font-display text-[24px] font-semibold text-ink">{totalDiagnoses}</div>
          <div className="font-sans text-[12.5px] text-sage">Total diagnosis</div>
        </Card>
        <Card className="flex-1 p-4.5">
          <div className="font-display text-[24px] font-semibold text-ink">
            {daysSince(zone.created_at)} hari
          </div>
          <div className="font-sans text-[12.5px] text-sage">Umur zona</div>
        </Card>
      </div>

      <Card className="p-5.5">
        <CardTitle className="mb-4">Tren kesehatan — {DISPLAY_DAYS} hari terakhir</CardTitle>
        <HealthTrendChart data={trendSeries} />
      </Card>

      <div className="flex gap-5">
        <Card className="w-[340px] shrink-0 p-5">
          <CardTitle className="mb-3">Frekuensi Penyakit</CardTitle>
          {diseaseFrequency.length === 0 ? (
            <p className="font-sans text-[13.5px] text-sage">Belum ada data.</p>
          ) : (
            <div className="flex flex-col gap-2">
              {diseaseFrequency.map((d) => (
                <div key={d.disease_name} className="flex items-center justify-between">
                  <span className="font-sans text-[13.5px] text-ink">{d.disease_name}</span>
                  <span className="font-sans text-[13px] font-semibold text-sage">{d.count}×</span>
                </div>
              ))}
            </div>
          )}
        </Card>

        <Card className="flex-1 p-5">
          <CardTitle className="mb-3">Riwayat Diagnosis Zona Ini</CardTitle>
          <HistoryTable rows={diagnosesHistory.rows} showZoneColumn={false} />
        </Card>
      </div>
    </div>
  );
}
