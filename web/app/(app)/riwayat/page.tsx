import type { Metadata } from "next";

import { HistoryTable } from "@/components/history/HistoryTable";
import { Pagination } from "@/components/history/Pagination";
import { Card, CardTitle } from "@/components/ui/Card";
import { getDiagnosesHistory } from "@/lib/data/history";
import { getZones } from "@/lib/data/zones";
import type { Enums } from "@/types/database.types";

export const metadata: Metadata = { title: "Riwayat — AgriVision" };

interface SearchParams {
  zona?: string;
  crop?: string;
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
      cropType: (params.crop as Enums<"crop_type">) || undefined,
      severity: (params.severity as Enums<"severity_level">) || undefined,
      page,
    }),
  ]);

  const totalPages = Math.max(1, Math.ceil(history.total / history.pageSize));

  function buildHref(overrides: Partial<Omit<SearchParams, "page">> & { page?: string | number }) {
    const merged = { ...params, ...overrides };
    const usp = new URLSearchParams();
    if (merged.zona) usp.set("zona", merged.zona);
    if (merged.crop) usp.set("crop", merged.crop);
    if (merged.severity) usp.set("severity", merged.severity);
    if (merged.page && String(merged.page) !== "1") usp.set("page", String(merged.page));
    const qs = usp.toString();
    return qs ? `/riwayat?${qs}` : "/riwayat";
  }

  return (
    <div className="flex h-screen flex-col gap-5 overflow-y-auto p-9 pb-16">
      <div>
        <h1 className="font-display text-[27px] font-semibold text-ink">Riwayat Diagnosis</h1>
        <p className="mt-1.5 font-sans text-[14px] text-sage">
          {history.total} diagnosis tercatat
        </p>
      </div>

      <form method="get" className="flex flex-wrap items-end gap-3 rounded-md border border-border-soft bg-paper p-4">
        <div className="flex flex-col gap-1">
          <label className="font-sans text-[12px] font-medium text-sage">Zona</label>
          <select
            name="zona"
            defaultValue={params.zona ?? ""}
            className="rounded-sm border border-input-border bg-input-bg px-3 py-2 font-sans text-[13.5px] text-ink"
          >
            <option value="">Semua zona</option>
            {zones.map((z) => (
              <option key={z.id} value={z.id}>
                {z.name}
              </option>
            ))}
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <label className="font-sans text-[12px] font-medium text-sage">Jenis tanaman</label>
          <select
            name="crop"
            defaultValue={params.crop ?? ""}
            className="rounded-sm border border-input-border bg-input-bg px-3 py-2 font-sans text-[13.5px] text-ink"
          >
            <option value="">Semua</option>
            <option value="tomat">Tomat</option>
            <option value="cabai">Cabai</option>
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <label className="font-sans text-[12px] font-medium text-sage">Tingkat keparahan</label>
          <select
            name="severity"
            defaultValue={params.severity ?? ""}
            className="rounded-sm border border-input-border bg-input-bg px-3 py-2 font-sans text-[13.5px] text-ink"
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
        {(params.zona || params.crop || params.severity) && (
          <a href="/riwayat" className="font-sans text-[13px] font-medium text-sage">
            Hapus filter
          </a>
        )}
      </form>

      <Card className="flex-1 p-5">
        <CardTitle className="mb-3">Semua Diagnosis</CardTitle>
        <HistoryTable rows={history.rows} />
        <Pagination page={page} totalPages={totalPages} buildHref={(p) => buildHref({ page: p })} />
      </Card>
    </div>
  );
}
