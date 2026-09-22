"use client";

import { useSearchParams } from "next/navigation";
import { useState } from "react";

import { CreateZoneModal } from "@/components/upload/CreateZoneModal";
import { Dropzone } from "@/components/upload/Dropzone";
import { ZoneSelector } from "@/components/upload/ZoneSelector";
import type { Tables } from "@/types/database.types";

export function UploadPageClient({ initialZones }: { initialZones: Tables<"zones">[] }) {
  const searchParams = useSearchParams();
  const [zones, setZones] = useState(initialZones);
  const [selectedZoneId, setSelectedZoneId] = useState<string | null>(
    searchParams.get("zone") || initialZones[0]?.id || null,
  );
  const [modalOpen, setModalOpen] = useState(false);

  const selectedZone = zones.find((z) => z.id === selectedZoneId) ?? null;

  return (
    <>
      <div className="flex items-start justify-between">
        <div>
          <h1 className="font-display text-[27px] font-semibold text-ink">Unggah Foto Tanaman</h1>
          <p className="mt-1.5 font-sans text-[14px] text-sage">
            Ambil atau unggah foto daun untuk mulai diagnosis
          </p>
        </div>
        <ZoneSelector
          zones={zones}
          selectedZoneId={selectedZoneId}
          onSelect={setSelectedZoneId}
          onAddNew={() => setModalOpen(true)}
        />
      </div>

      <Dropzone zone={selectedZone} />

      <CreateZoneModal
        open={modalOpen}
        onOpenChange={setModalOpen}
        onCreated={(zone) => {
          setZones((prev) => [...prev, zone]);
          setSelectedZoneId(zone.id);
        }}
      />
    </>
  );
}
