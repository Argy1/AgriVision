import "server-only";

import { createClient } from "@/lib/supabase/server";

import { getUser } from "./auth";

export async function getDashboardStats() {
  await getUser();
  const supabase = await createClient();

  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);

  const [{ count: zoneCount }, { count: diagnosisWeekCount }] = await Promise.all([
    supabase.from("zones").select("*", { count: "exact", head: true }),
    supabase
      .from("diagnoses")
      .select("*", { count: "exact", head: true })
      .gte("created_at", weekAgo.toISOString()),
  ]);

  return {
    zoneCount: zoneCount ?? 0,
    diagnosisWeekCount: diagnosisWeekCount ?? 0,
  };
}

export async function getRecentActivity(limit = 5) {
  await getUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("diagnoses")
    .select("id, disease_name, severity, created_at, uploads!inner(zones!inner(id, name))")
    .order("created_at", { ascending: false })
    .limit(limit);

  if (error) throw new Error(error.message);
  return data;
}
