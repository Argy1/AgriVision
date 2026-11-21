import type { Metadata } from "next";

import { HistoryTable } from "@/components/history/HistoryTable";
import { Pagination } from "@/components/history/Pagination";
import { PageContainer } from "@/components/layout/PageContainer";
import { Card, CardTitle } from "@/components/ui/Card";
import { getDiagnosesHistory } from "@/lib/data/history";
import { getZones } from "@/lib/data/zones";
import type { Enums } from "@/types/database.types";

export const metadata: Metadata = { title: "Riwayat — AgriVision" };

interface SearchParams {
  zona?: string;
  severity?: string;
  page?: string;
}

export default async function RiwayatPage({
  searchParams,
}: {
  searchParams: Promise<SearchParams>;
}) {
  const params = await searchParams;
  const page = Number(params.page) > 0 ? Number(params.page) : 1;

  const [zones, history] = await Promise.all([
    getZones(),
    getDiagnosesHistory({
      zoneId: params.zona || undefined,
      severity: (params.severity as Enums<"severity_level">) || undefined,
      page,
    }),
  ]);

  const totalPages = Math.max(1, Math.ceil(history.total / history.pageSize));

  function buildHref(overrides: Partial<Omit<SearchParams, "page">> & { page?: string | number }) {
    const merged = { ...params, ...overrides };
    const usp = new URLSearchParams();
    if (merged.zona) usp.set("zona", merged.zona);
    if (merged.severity) usp.set("severity", merged.severity);
    if (merged.page && String(merged.page) !== "1") usp.set("page", String(merged.page));
    const qs = usp.toString();
    return qs ? `/riwayat?${qs}` : "/riwayat";
  }

  return (
    <PageContainer>
      <div>
        <h1 className="font-display text-[27px] font-semibold text-ink">Riwayat Diagnosis</h1>
        <p className="mt-1.5 font-sans text-[14px] text-sage">
          {history.total} diagnosis tercatat
        </p>
      </div>

      <form method="get" className="flex flex-wrap items-end gap-3 rounded-md border border-border-soft bg-paper p-4">
        <div className="flex min-w-[140px] flex-1 flex-col gap-1 sm:flex-none">
          <label className="font-sans text-[12px] font-medium text-sage">Zona</label>
          <select
            name="zona"
            defaultValue={params.zona ?? ""}
            className="rounded-sm border border-input-border bg-input-bg px-3 py-2 font-sans text-[16px] text-ink sm:text-[13.5px]"
          >
            <option value="">Semua zona</option>
            {zones.map((z) => (
              <option key={z.id} value={z.id}>
                {z.name}
              </option>
            ))}
          </select>
        </div>
        <div className="flex min-w-[140px] flex-1 flex-col gap-1 sm:flex-none">
          <label className="font-sans text-[12px] font-medium text-sage">Tingkat keparahan</label>
          <select
            name="severity"
            defaultValue={params.severity ?? ""}
            className="rounded-sm border border-input-border bg-input-bg px-3 py-2 font-sans text-[16px] text-ink sm:text-[13.5px]"
          >
            <option value="">Semua</option>
            <option value="ringan">Ringan</option>
            <option value="sedang">Sedang</option>
            <option value="parah">Parah</option>
          </select>
        </div>
        <button
          type="submit"
          className="rounded-sm bg-moss px-5 py-2 font-sans text-[13.5px] font-semibold text-white"
        >
          Terapkan Filter
        </button>
        {(params.zona || params.severity) && (
          <a href="/riwayat" className="font-sans text-[13px] font-medium text-sage">
            Hapus filter
          </a>
        )}
      </form>

      <Card className="p-4 sm:p-5">
        <CardTitle className="mb-3">Semua Diagnosis</CardTitle>
        <HistoryTable rows={history.rows} />
        <Pagination page={page} totalPages={totalPages} buildHref={(p) => buildHref({ page: p })} />
      </Card>
    </PageContainer>
  );
}
