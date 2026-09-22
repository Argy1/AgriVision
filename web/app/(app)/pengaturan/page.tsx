import type { Metadata } from "next";

import { Card, CardTitle } from "@/components/ui/Card";
import { ChangePasswordForm } from "@/components/settings/ChangePasswordForm";
import { ProfileForm } from "@/components/settings/ProfileForm";
import { SignOutButton } from "@/components/settings/SignOutButton";
import { ZoneManageList } from "@/components/settings/ZoneManageList";
import { getProfile } from "@/lib/data/auth";
import { getZones } from "@/lib/data/zones";

export const metadata: Metadata = { title: "Pengaturan — AgriVision" };

export default async function PengaturanPage() {
  const [profile, zones] = await Promise.all([getProfile(), getZones()]);

  return (
    <div className="flex h-screen flex-col gap-5 overflow-y-auto p-9 pb-16">
      <div>
        <h1 className="font-display text-[27px] font-semibold text-ink">Pengaturan</h1>
        <p className="mt-1.5 font-sans text-[14px] text-sage">
          Kelola profil, zona, dan keamanan akun Anda
        </p>
      </div>

      <div className="flex gap-5">
        <Card className="w-[420px] shrink-0 p-5.5">
          <CardTitle className="mb-4">Profil</CardTitle>
          <ProfileForm initial={{ full_name: profile.full_name, phone: profile.phone }} />
        </Card>

        <Card className="w-[420px] shrink-0 p-5.5">
          <CardTitle className="mb-4">Ubah Kata Sandi</CardTitle>
          <ChangePasswordForm />
        </Card>
      </div>

      <Card className="p-5.5">
        <CardTitle className="mb-1">Kelola Zona</CardTitle>
        <p className="mb-4 font-sans text-[12.5px] text-sage">
          Zona tidak bisa dihapus untuk menjaga histori diagnosis tetap utuh — hubungi admin
          kalau ada zona yang perlu dinonaktifkan.
        </p>
        <ZoneManageList initialZones={zones} />
      </Card>

      <Card className="p-5.5">
        <CardTitle className="mb-1">Akun</CardTitle>
        <p className="mb-4 font-sans text-[12.5px] text-sage">Keluar dari sesi Anda saat ini.</p>
        <SignOutButton />
      </Card>
    </div>
  );
}
