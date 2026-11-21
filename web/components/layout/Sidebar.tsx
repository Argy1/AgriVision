"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

import {
  BarChartIcon,
  CameraIcon,
  ClockIcon,
  CloseIcon,
  GridIcon,
  LeafLogoIcon,
  MenuIcon,
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

/**
 * Navigasi utama. >= lg: sidebar tetap 240px di kiri. < lg (tablet & HP): top bar
 * dengan tombol menu yang membuka sidebar sebagai drawer (menutup saat tautan diklik
 * atau latar digelapkan diketuk).
 */
export function Sidebar({ fullName, role }: { fullName: string; role: Enums<"user_role"> }) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <>
      <header className="sticky top-0 z-30 flex items-center justify-between bg-ink px-4 py-3 lg:hidden">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-parchment">
            <LeafLogoIcon size={17} className="text-ink" />
          </div>
          <span className="font-sans text-[17px] font-semibold text-parchment">AgriVision</span>
        </div>
        <button
          type="button"
          aria-label="Buka menu navigasi"
          aria-expanded={open}
          onClick={() => setOpen(true)}
          className="flex h-10 w-10 items-center justify-center rounded-sm text-parchment hover:bg-white/10"
        >
          <MenuIcon size={22} />
        </button>
      </header>

      {open && (
        <div
          className="fixed inset-0 z-40 bg-ink/50 lg:hidden"
          onClick={() => setOpen(false)}
          aria-hidden
        />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-50 flex w-[260px] max-w-[85vw] flex-col justify-between overflow-y-auto bg-ink transition-[transform,visibility] duration-200 lg:sticky lg:top-0 lg:z-auto lg:h-screen lg:w-[240px] lg:max-w-none lg:shrink-0 lg:translate-x-0 ${
          open ? "translate-x-0" : "-translate-x-full max-lg:invisible"
        }`}
      >
        <div>
          <div className="flex items-center justify-between gap-2.5 px-6 pb-6 pt-7">
            <div className="flex items-center gap-2.5">
              <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-parchment">
                <LeafLogoIcon size={17} className="text-ink" />
              </div>
              <span className="font-sans text-[17px] font-semibold text-parchment">AgriVision</span>
            </div>
            <button
              type="button"
              aria-label="Tutup menu navigasi"
              onClick={() => setOpen(false)}
              className="flex h-9 w-9 items-center justify-center rounded-sm text-parchment hover:bg-white/10 lg:hidden"
            >
              <CloseIcon size={20} />
            </button>
          </div>
          <nav className="flex flex-col gap-1 px-4 py-2">
            {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
              const active = pathname === href || pathname.startsWith(`${href}/`);
              return (
                <Link
                  key={href}
                  href={href}
                  onClick={() => setOpen(false)}
                  className={`flex items-center gap-3 rounded-sm px-3.5 py-3 font-sans text-[14.5px] font-medium transition-colors lg:py-2.5 ${
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
          <div className="flex min-w-0 flex-col leading-tight">
            <span className="truncate font-sans text-[13.5px] font-medium text-parchment">{fullName}</span>
            <span className="font-sans text-[12px] text-sage">{ROLE_LABEL[role]}</span>
          </div>
        </div>
      </aside>
    </>
  );
}
