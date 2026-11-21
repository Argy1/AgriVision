"use client";

import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { CreateZoneModal } from "@/components/upload/CreateZoneModal";
import { createClient } from "@/lib/supabase/client";
import type { Tables } from "@/types/database.types";

export function ZoneManageList({ initialZones }: { initialZones: Tables<"zones">[] }) {
  const [zones, setZones] = useState(initialZones);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [draftName, setDraftName] = useState("");
  const [modalOpen, setModalOpen] = useState(false);

  async function saveEdit(zoneId: string) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("zones")
      .update({ name: draftName })
      .eq("id", zoneId)
      .select()
      .single();

    if (!error && data) {
      setZones((prev) => prev.map((z) => (z.id === zoneId ? data : z)));
    }
    setEditingId(null);
  }

  return (
    <div className="flex flex-col gap-3">
      {zones.map((zone) => (
        <div
          key={zone.id}
          className="flex flex-wrap items-center gap-x-3 gap-y-2 rounded-sm border border-border-soft px-4 py-3"
        >
          {editingId === zone.id ? (
            <>
              <Input
                value={draftName}
                onChange={(e) => setDraftName(e.target.value)}
                className="min-w-[160px] flex-1"
              />
              <Button variant="outline" onClick={() => saveEdit(zone.id)} className="w-fit px-4 py-2 text-[13px]">
                Simpan
              </Button>
              <button
                type="button"
                onClick={() => setEditingId(null)}
                className="font-sans text-[13px] text-sage"
              >
                Batal
              </button>
            </>
          ) : (
            <>
              <span className="min-w-0 flex-1 break-words font-sans text-[13.5px] text-ink">
                {zone.name}
              </span>
              <button
                type="button"
                onClick={() => {
                  setEditingId(zone.id);
                  setDraftName(zone.name);
                }}
                className="font-sans text-[13px] font-medium text-moss"
              >
                Ubah nama
              </button>
            </>
          )}
        </div>
      ))}

      <Button variant="outline" className="w-fit" onClick={() => setModalOpen(true)}>
        + Tambah Zona Baru
      </Button>

      <CreateZoneModal
        open={modalOpen}
        onOpenChange={setModalOpen}
        onCreated={(zone) => setZones((prev) => [...prev, zone])}
      />
    </div>
  );
}
