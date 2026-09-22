import { getProfile } from "@/lib/data/auth";
import { Sidebar } from "@/components/layout/Sidebar";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const profile = await getProfile();

  return (
    <div className="flex min-h-screen bg-parchment">
      <Sidebar fullName={profile.full_name} role={profile.role} />
      <main className="min-w-0 flex-1">{children}</main>
    </div>
  );
}
