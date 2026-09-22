import "server-only";

import { createClient } from "@/lib/supabase/server";

import { getUser } from "./auth";

export async function getZones() {
  await getUser();
  const supabase = await createClient();

  const { data, error } = await supabase.from("zones").select("*").order("name");

  if (error) throw new Error(error.message);
  return data;
}

export async function getZone(zoneId: string) {
  await getUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("zones")
    .select("id, name, crop_type, location_note, owner_id, created_at")
    .eq("id", zoneId)
    .maybeSingle();

  if (error) throw new Error(error.message);
  return data;
}
