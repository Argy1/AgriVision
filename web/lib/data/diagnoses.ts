import "server-only";

import { createClient } from "@/lib/supabase/server";

import { getUser } from "./auth";

export async function getRecentDiagnoses(limit = 3) {
  await getUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("diagnoses")
    .select(
      "id, disease_name, severity, created_at, uploads!inner(zone_id, zones!inner(id, name, crop_type))",
    )
    .order("created_at", { ascending: false })
    .limit(limit);

  if (error) throw new Error(error.message);
  return data;
}

export async function getDiagnosisDetail(diagnosisId: string) {
  await getUser();
  const supabase = await createClient();

  const { data: diagnosis, error } = await supabase
    .from("diagnoses")
    .select(
      `id, disease_label, disease_name, confidence, severity, affected_area_pct, created_at, upload_id,
       recommendations(recommendation_text, dosage, application_schedule, warning_note),
       uploads!inner(id, zone_id, captured_at, zones!inner(id, name, crop_type, location_note))`,
    )
    .eq("id", diagnosisId)
    .maybeSingle();

  if (error) throw new Error(error.message);
  if (!diagnosis) return null;

  const uploadId = diagnosis.upload_id;
  const zoneId = diagnosis.uploads.zone_id;

  const [{ data: vegetationIndex }, { data: zoneHistory }, { data: firstOccurrence }] =
    await Promise.all([
      supabase
        .from("vegetation_index_readings")
        .select("exg_score, vari_score, health_score")
        .eq("upload_id", uploadId)
        .maybeSingle(),
      supabase
        .from("diagnoses")
        .select("id, severity, created_at, uploads!inner(zone_id)")
        .eq("uploads.zone_id", zoneId)
        .order("created_at", { ascending: false })
        .limit(5),
      supabase
        .from("diagnoses")
        .select("created_at, uploads!inner(zone_id)")
        .eq("uploads.zone_id", zoneId)
        .eq("disease_label", diagnosis.disease_label)
        .order("created_at", { ascending: true })
        .limit(1)
        .maybeSingle(),
    ]);

  return { diagnosis, vegetationIndex, zoneHistory: zoneHistory ?? [], firstOccurrence };
}
