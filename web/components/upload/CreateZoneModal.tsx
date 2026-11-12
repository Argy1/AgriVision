"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import * as Dialog from "@radix-ui/react-dialog";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import {
  type CreateZoneInput,
  createZoneSchema,
  ZONE_CROP_TYPE,
} from "@/lib/validation/zone";
import type { Tables } from "@/types/database.types";

export function CreateZoneModal({
  open,
  onOpenChange,
  onCreated,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onCreated: (zone: Tables<"zones">) => void;
}) {
  const [formError, setFormError] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<CreateZoneInput>({ resolver: zodResolver(createZoneSchema) });

  async function onSubmit(values: CreateZoneInput) {
    setFormError(null);
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return;

    const { data, error } = await supabase
      .from("zones")
      .insert({
        name: values.name,
        crop_type: ZONE_CROP_TYPE,
        location_note: values.location_note || null,
        owner_id: user.id,
      })
      .select()
      .single();

    if (error || !data) {
      setFormError(error?.message ?? "Gagal membuat zona.");
      return;
    }

    reset();
    onCreated(data);
    onOpenChange(false);
  }

  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-ink/40" />
        <Dialog.Content className="fixed left-1/2 top-1/2 z-50 w-[420px] -translate-x-1/2 -translate-y-1/2 rounded-lg border border-border-soft bg-paper p-6 shadow-lg">
          <Dialog.Title className="font-display text-[20px] font-semibold text-ink">
            Tambah Zona Baru
          </Dialog.Title>
          <form onSubmit={handleSubmit(onSubmit)} className="mt-4 flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="zone-name">Nama zona</Label>
              <Input id="zone-name" placeholder="Contoh: A4" {...register("name")} />
              <FieldError>{errors.name?.message}</FieldError>
            </div>
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="zone-note">Catatan lokasi (opsional)</Label>
              <Input id="zone-note" placeholder="Contoh: Blok belakang gudang" {...register("location_note")} />
            </div>
            {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}
            <div className="mt-1 flex justify-end gap-2">
              <Button type="button" variant="ghost" onClick={() => onOpenChange(false)}>
                Batal
              </Button>
              <Button type="submit" loading={isSubmitting}>
                Simpan Zona
              </Button>
            </div>
          </form>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
