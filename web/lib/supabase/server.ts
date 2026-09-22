import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

import type { Database } from "@/types/database.types";

// Server-side client -- pakai JWT user asli dari cookie (RLS aktif penuh).
// TIDAK PERNAH pakai service role key di sini -- itu cuma milik ml-service.
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // Dipanggil dari Server Component render -- proxy.ts yang
            // menangani refresh sesi, jadi ini aman diabaikan.
          }
        },
      },
    },
  );
}
