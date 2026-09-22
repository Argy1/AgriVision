"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

import {
  BarChartIcon,
  CameraIcon,
  ClockIcon,
  GridIcon,
  LeafLogoIcon,
  SlidersIcon,
  TrendLineIcon,
} from "@/components/icons";
import type { Enums } from "@/types/database.types";

const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", icon: GridIcon },
  { href: "/upload", label: "Unggah Foto", icon: CameraIcon },
  { href: "/monitoring", label: "Monitoring", icon: TrendLineIcon },
  { href: "/analitik", label: "Analitik", icon: BarChartIcon },
  { href: "/riwayat", label: "Riwayat", icon: ClockIcon },
  { href: "/pengaturan", label: "Pengaturan", icon: SlidersIcon },
] as const;

const ROLE_LABEL: Record<Enums<"user_role">, string> = {
  admin_ppl: "Admin PPL",
  petani: "Petani",
};

function initials(fullName: string) {
  return fullName
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("");
}

export function Sidebar({ fullName, role }: { fullName: string; role: Enums<"user_role"> }) {
  const pathname = usePathname();

  return (
    <div className="flex h-screen w-[240px] shrink-0 flex-col justify-between bg-ink">
      <div>
        <div className="flex items-center gap-2.5 px-6 pb-6 pt-7">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-parchment">
            <LeafLogoIcon size={17} className="text-ink" />
          </div>
          <span className="font-sans text-[17px] font-semibold text-parchment">AgriVision</span>
        </div>
        <nav className="flex flex-col gap-1 px-4 py-2">
          {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
            const active = pathname === href || pathname.startsWith(`${href}/`);
            return (
              <Link
                key={href}
                href={href}
                className={`flex items-center gap-3 rounded-sm px-3.5 py-2.5 font-sans text-[14.5px] font-medium transition-colors ${
                  active ? "bg-moss text-white" : "text-sidebar-muted hover:bg-white/5"
                }`}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>
      </div>
      <div className="flex items-center gap-2.5 border-t border-sidebar-divider px-6 pb-7 pt-5">
        <div className="flex h-[34px] w-[34px] shrink-0 items-center justify-center rounded-full bg-moss font-sans text-[13px] font-semibold text-white">
          {initials(fullName)}
        </div>
        <div className="flex flex-col leading-tight">
          <span className="font-sans text-[13.5px] font-medium text-parchment">{fullName}</span>
          <span className="font-sans text-[12px] text-sage">{ROLE_LABEL[role]}</span>
        </div>
      </div>
    </div>
  );
}
