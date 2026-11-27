import type { Metadata } from "next";

import { PageContainer } from "@/components/layout/PageContainer";
import { PageHeader } from "@/components/layout/PageHeader";
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
    <PageContainer>
      <PageHeader
        eyebrow="Pengaturan"
        title="Akun & kebun Anda"
        subtitle="Kelola profil, zona kebun, dan keamanan akun."
        pose="happy"
      />

      <div className="grid gap-5 md:grid-cols-2 xl:max-w-[860px]">
        <Card className="min-w-0 p-4 sm:p-5.5">
          <CardTitle className="mb-4">Profil</CardTitle>
          <ProfileForm initial={{ full_name: profile.full_name, phone: profile.phone }} />
        </Card>

        <Card className="min-w-0 p-4 sm:p-5.5">
          <CardTitle className="mb-4">Ubah Kata Sandi</CardTitle>
          <ChangePasswordForm />
        </Card>
      </div>

      <Card className="p-4 sm:p-5.5">
        <CardTitle className="mb-1">Kelola Zona</CardTitle>
        <p className="mb-4 font-sans text-[12.5px] text-sage">
          Zona tidak bisa dihapus untuk menjaga histori diagnosis tetap utuh — hubungi admin
          kalau ada zona yang perlu dinonaktifkan.
        </p>
        <ZoneManageList initialZones={zones} />
      </Card>

      <Card className="p-4 sm:p-5.5">
        <CardTitle className="mb-1">Akun</CardTitle>
        <p className="mb-4 font-sans text-[12.5px] text-sage">Keluar dari sesi Anda saat ini.</p>
        <SignOutButton />
      </Card>
    </PageContainer>
  );
}
