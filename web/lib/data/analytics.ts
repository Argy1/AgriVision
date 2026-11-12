import "server-only";

import { format, startOfWeek } from "date-fns";

import { createClient } from "@/lib/supabase/server";
import type { Enums } from "@/types/database.types";

import { getUser } from "./auth";

const WEEKS_BACK = 8;

async function fetchDiagnosesForAnalytics() {
  const supabase = await createClient();
  const since = new Date();
  since.setDate(since.getDate() - WEEKS_BACK * 7);

  const { data, error } = await supabase
    .from("diagnoses")
    .select("disease_name, severity, confidence, created_at")
    .gte("created_at", since.toISOString());

  if (error) throw new Error(error.message);
  return data;
}

export async function getDiseaseFrequency(topN = 8) {
  await getUser();
  const rows = await fetchDiagnosesForAnalytics();

  const counts = new Map<string, number>();
  for (const row of rows) {
    counts.set(row.disease_name, (counts.get(row.disease_name) ?? 0) + 1);
  }

  return [...counts.entries()]
    .map(([disease_name, count]) => ({ disease_name, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, topN);
}

export async function getSeverityTrendByWeek() {
  await getUser();
  const rows = await fetchDiagnosesForAnalytics();

  const byWeek = new Map<string, { ringan: number; sedang: number; parah: number }>();
  for (const row of rows) {
    // format() pakai getter tanggal LOKAL (bukan toISOString() yang ke UTC),
    // supaya baris di dekat tengah malam tidak salah masuk ke minggu sebelah.
    const weekStart = format(startOfWeek(new Date(row.created_at), { weekStartsOn: 1 }), "yyyy-MM-dd");
    if (!byWeek.has(weekStart)) byWeek.set(weekStart, { ringan: 0, sedang: 0, parah: 0 });
    byWeek.get(weekStart)![row.severity as Enums<"severity_level">] += 1;
  }

  return [...byWeek.entries()]
    .map(([week, counts]) => ({ week, ...counts }))
    .sort((a, b) => a.week.localeCompare(b.week));
}

export async function getAverageConfidence() {
  await getUser();
  const rows = await fetchDiagnosesForAnalytics();
  if (rows.length === 0) return null;
  return rows.reduce((sum, r) => sum + r.confidence, 0) / rows.length;
}
