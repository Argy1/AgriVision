import "server-only";

import { createClient } from "@/lib/supabase/server";
import type { Enums } from "@/types/database.types";

import { getUser } from "./auth";

export interface HistoryFilters {
  zoneId?: string;
  cropType?: Enums<"crop_type">;
  severity?: Enums<"severity_level">;
  dateFrom?: string;
  dateTo?: string;
  page?: number;
  pageSize?: number;
}

export async function getDiagnosesHistory(filters: HistoryFilters = {}) {
  await getUser();
  const supabase = await createClient();
  const page = filters.page ?? 1;
  const pageSize = filters.pageSize ?? 20;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from("diagnoses")
    .select(
      "id, disease_name, severity, confidence, created_at, uploads!inner(zone_id, zones!inner(id, name, crop_type))",
      { count: "exact" },
    )
    .order("created_at", { ascending: false })
    .range(from, to);

  if (filters.zoneId) query = query.eq("uploads.zone_id", filters.zoneId);
  if (filters.cropType) query = query.eq("uploads.zones.crop_type", filters.cropType);
  if (filters.severity) query = query.eq("severity", filters.severity);
  if (filters.dateFrom) query = query.gte("created_at", filters.dateFrom);
  if (filters.dateTo) query = query.lte("created_at", filters.dateTo);

  const { data, error, count } = await query;
  if (error) throw new Error(error.message);

  return {
    rows: data.map((d) => ({
      id: d.id,
      disease_name: d.disease_name,
      severity: d.severity,
      confidence: d.confidence,
      created_at: d.created_at,
      zoneName: d.uploads.zones.name,
      cropType: d.uploads.zones.crop_type,
    })),
    total: count ?? 0,
    page,
    pageSize,
  };
}

export async function getZoneDiseaseFrequency(zoneId: string) {
  await getUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("diagnoses")
    .select("disease_name, uploads!inner(zone_id)")
    .eq("uploads.zone_id", zoneId);

  if (error) throw new Error(error.message);

  const counts = new Map<string, number>();
  for (const row of data) {
    counts.set(row.disease_name, (counts.get(row.disease_name) ?? 0) + 1);
  }

  return [...counts.entries()]
    .map(([disease_name, count]) => ({ disease_name, count }))
    .sort((a, b) => b.count - a.count);
}
