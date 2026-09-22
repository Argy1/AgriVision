import { notFound } from "next/navigation";
import Link from "next/link";

import { BackArrowIcon } from "@/components/icons";
import { LeafIllustration } from "@/components/leaf-illustration/LeafIllustration";
import { ConfidencePill, SeverityPill } from "@/components/severity/SeverityBadge";
import { SeverityMeter } from "@/components/severity/SeverityMeter";
import { RecommendationCard } from "@/components/diagnosis/RecommendationCard";
import { ZoneHistoryDots } from "@/components/diagnosis/ZoneHistoryDots";
import { getDiagnosisDetail } from "@/lib/data/diagnoses";
import { CROP_LABEL, daysSince, formatRelativeDateTime } from "@/lib/format";

export default async function DiagnosisPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const result = await getDiagnosisDetail(id);

  if (!result) notFound();

  const { diagnosis, vegetationIndex, zoneHistory, firstOccurrence } = result;
  const zone = diagnosis.uploads.zones;
  const recommendation = diagnosis.recommendations;
  const daysSinceFirst = firstOccurrence ? daysSince(firstOccurrence.created_at) : null;

  return (
    <div className="flex h-screen flex-col gap-4.5 overflow-y-auto p-9 pb-16">
      <div className="flex items-center gap-2.5">
        <Link
          href="/upload"
          className="flex h-[30px] w-[30px] items-center justify-center rounded-sm border border-border bg-paper"
        >
          <BackArrowIcon size={16} className="text-ink" />
        </Link>
        <div>
          <h1 className="font-display text-[25px] font-semibold text-ink">Hasil Diagnosis</h1>
          <p className="mt-0.5 font-sans text-[13px] text-sage">
            {formatRelativeDateTime(diagnosis.created_at)} • Zona {zone.name} — Blok{" "}
            {CROP_LABEL[zone.crop_type]}
          </p>
        </div>
      </div>

      <div className="flex gap-8 rounded-xl border border-border-soft bg-paper p-7">
        <div className="flex w-[260px] shrink-0 flex-col items-center gap-2.5">
          <div className="flex h-60 w-60 items-center justify-center overflow-hidden rounded-lg bg-leaf-panel-bg">
            <LeafIllustration severity={diagnosis.severity} affectedAreaPct={diagnosis.affected_area_pct} />
          </div>
          <span className="font-sans text-[12px] text-sage">Area terdampak disorot</span>
        </div>

        <div className="flex min-w-0 flex-1 flex-col gap-3.5">
          <div>
            <span className="font-sans text-[13px] font-medium text-sage">Diagnosis</span>
            <h2 className="mt-1 font-display text-[29px] font-semibold text-ink">
              {diagnosis.disease_name}
            </h2>
          </div>

          <div className="flex gap-2.5">
            <ConfidencePill confidence={diagnosis.confidence} />
            <SeverityPill severity={diagnosis.severity} />
          </div>

          <SeverityMeter severity={diagnosis.severity} />

          <div className="mt-1 flex gap-7">
            <div>
              <div className="font-display text-[24px] font-semibold text-ink">
                {diagnosis.affected_area_pct}%
              </div>
              <div className="font-sans text-[12.5px] text-sage">permukaan daun terdampak</div>
            </div>
            {daysSinceFirst !== null && (
              <div>
                <div className="font-display text-[24px] font-semibold text-ink">
                  {daysSinceFirst} hari
                </div>
                <div className="font-sans text-[12.5px] text-sage">
                  sejak gejala pertama terdeteksi
                </div>
              </div>
            )}
            {vegetationIndex && (
              <div>
                <div className="font-display text-[24px] font-semibold text-ink">
                  {Math.round(vegetationIndex.health_score)}
                  <span className="text-[14px] font-normal text-sage">/100</span>
                </div>
                <div className="font-sans text-[12.5px] text-sage">skor kesehatan (ExG/VARI)</div>
              </div>
            )}
          </div>
        </div>
      </div>

      {recommendation && (
        <RecommendationCard
          recommendationText={recommendation.recommendation_text}
          applicationSchedule={recommendation.application_schedule}
          dosage={recommendation.dosage}
          warningNote={recommendation.warning_note}
        />
      )}

      <ZoneHistoryDots
        zoneId={zone.id}
        zoneName={zone.name}
        severities={zoneHistory.map((h) => h.severity).reverse()}
      />
    </div>
  );
}
