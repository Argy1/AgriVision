import "server-only";

import { cache } from "react";
import { redirect } from "next/navigation";

import { createClient } from "@/lib/supabase/server";

/**
 * Data Access Layer -- proxy.ts only does an optimistic redirect; every real
 * auth check happens here, close to the data (per Next.js's own auth guide).
 * cache() dedupes this across a single render pass (layout + page both call it).
 */
export const getUser = cache(async () => {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  return user;
});

export const getProfile = cache(async () => {
  const user = await getUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("profiles")
    .select("id, full_name, role, phone")
    .eq("id", user.id)
    .single();

  // Trigger handle_new_user() selalu membuat baris profil saat daftar, jadi ini
  // seharusnya tidak terjadi -- tapi jangan sampai layout seluruh app crash
  // untuk akun yang baris profilnya hilang; tampilkan fallback minimal.
  if (error || !data) {
    return {
      id: user.id,
      full_name: user.email?.split("@")[0] ?? "Pengguna",
      role: "petani" as const,
      phone: null,
    };
  }

  return data;
});
