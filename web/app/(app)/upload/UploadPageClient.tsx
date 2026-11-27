"use client";

import { useSearchParams } from "next/navigation";
import { useState } from "react";

import { PageHeader } from "@/components/layout/PageHeader";
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
      <PageHeader
        eyebrow="Diagnosis baru"
        title="Unggah foto daun tomat"
        subtitle="Ambil atau unggah foto satu daun — Si Tomat akan memeriksanya untuk Anda."
        pose="lens"
        actions={
          <ZoneSelector
            zones={zones}
            selectedZoneId={selectedZoneId}
            onSelect={setSelectedZoneId}
            onAddNew={() => setModalOpen(true)}
          />
        }
      />

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
