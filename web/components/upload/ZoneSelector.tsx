"use client";

import { useState } from "react";

import { ChevronDownIcon } from "@/components/icons";
import type { Tables } from "@/types/database.types";

const CROP_LABEL: Record<Tables<"zones">["crop_type"], string> = {
  tomat: "Tomat",
  cabai: "Cabai",
};

export function ZoneSelector({
  zones,
  selectedZoneId,
  onSelect,
  onAddNew,
}: {
  zones: Tables<"zones">[];
  selectedZoneId: string | null;
  onSelect: (zoneId: string) => void;
  onAddNew: () => void;
}) {
  const [open, setOpen] = useState(false);
  const selected = zones.find((z) => z.id === selectedZoneId);

  return (
    <div className="relative">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="flex items-center gap-2 rounded-pill border border-border bg-paper px-4 py-2.5 font-sans text-[13.5px] text-ink"
      >
        {selected ? `Zona: ${selected.name} — ${CROP_LABEL[selected.crop_type]}` : "Pilih zona"}
        <ChevronDownIcon size={15} className="text-sage" />
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-10" onClick={() => setOpen(false)} />
          <div className="absolute right-0 z-20 mt-2 w-64 rounded-md border border-border-soft bg-paper py-2 shadow-lg">
            {zones.length === 0 && (
              <p className="px-4 py-2 font-sans text-[13px] text-sage">Belum ada zona.</p>
            )}
            {zones.map((zone) => (
              <button
                key={zone.id}
                type="button"
                onClick={() => {
                  onSelect(zone.id);
                  setOpen(false);
                }}
                className="block w-full px-4 py-2 text-left font-sans text-[13.5px] text-ink hover:bg-parchment"
              >
                {zone.name} — {CROP_LABEL[zone.crop_type]}
              </button>
            ))}
            <div className="my-1 border-t border-border-soft" />
            <button
              type="button"
              onClick={() => {
                onAddNew();
                setOpen(false);
              }}
              className="block w-full px-4 py-2 text-left font-sans text-[13.5px] font-medium text-moss hover:bg-moss-tint"
            >
              + Tambah zona baru
            </button>
          </div>
        </>
      )}
    </div>
  );
}
