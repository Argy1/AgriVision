import { CalendarIcon, DropletIcon, WarningTriangleIcon } from "@/components/icons";

export function RecommendationCard({
  recommendationText,
  applicationSchedule,
  dosage,
  warningNote,
}: {
  recommendationText: string;
  applicationSchedule: string | null;
  dosage: string | null;
  warningNote: string | null;
}) {
  return (
    <div className="rounded-md border-l-4 border-rust bg-rust-soft px-6 py-5">
      <div className="mb-3 flex items-center gap-2.5">
        <DropletIcon size={18} className="text-rust" />
        <h3 className="font-sans text-[16px] font-semibold text-ink">Rekomendasi Penanganan</h3>
      </div>
      <div className="flex flex-col gap-2.5">
        <div className="flex items-start gap-2.5">
          <DropletIcon size={16} className="mt-0.5 shrink-0 text-rust-text" />
          <span className="font-sans text-[13.5px] leading-relaxed text-recommendation-text">
            {recommendationText}
            {dosage ? ` — dosis ${dosage}` : ""}
          </span>
        </div>
        {applicationSchedule && (
          <div className="flex items-start gap-2.5">
            <CalendarIcon size={16} className="mt-0.5 shrink-0 text-rust-text" />
            <span className="font-sans text-[13.5px] leading-relaxed text-recommendation-text">
              {applicationSchedule}
            </span>
          </div>
        )}
        {warningNote && (
          <div className="mt-1 flex items-start gap-2.5 border-t border-rust-divider pt-2.5">
            <WarningTriangleIcon size={16} className="mt-0.5 shrink-0 text-rust" />
            <span className="font-sans text-[13px] leading-relaxed text-rust-text">
              {warningNote}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}
