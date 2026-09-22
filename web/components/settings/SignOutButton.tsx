"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { createClient } from "@/lib/supabase/client";

export function SignOutButton() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function handleSignOut() {
    setLoading(true);
    const supabase = createClient();
    await supabase.auth.signOut();
    router.replace("/login");
    router.refresh();
  }

  return (
    <button
      type="button"
      onClick={handleSignOut}
      disabled={loading}
      className="w-fit rounded-sm border border-rust-divider px-5 py-2.5 font-sans text-[13.5px] font-semibold text-rust-text disabled:opacity-60"
    >
      {loading ? "Keluar…" : "Keluar dari Akun"}
    </button>
  );
}
