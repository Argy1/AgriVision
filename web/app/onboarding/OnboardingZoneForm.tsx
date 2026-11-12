"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useRouter } from "next/navigation";
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

export function OnboardingZoneForm() {
  const router = useRouter();
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<CreateZoneInput>({ resolver: zodResolver(createZoneSchema) });

  async function onSubmit(values: CreateZoneInput) {
    setFormError(null);
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      router.replace("/login");
      return;
    }

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

    router.replace(`/upload?zone=${data.id}`);
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="zone-name">Nama zona</Label>
        <Input id="zone-name" placeholder="Contoh: A1" {...register("name")} />
        <FieldError>{errors.name?.message}</FieldError>
      </div>

      <div className="flex flex-col gap-1.5">
        <Label htmlFor="zone-note">Catatan lokasi (opsional)</Label>
        <Input
          id="zone-note"
          placeholder="Contoh: Blok belakang gudang"
          {...register("location_note")}
        />
      </div>

      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}

      <Button type="submit" className="mt-1.5" loading={isSubmitting}>
        Buat zona &amp; mulai
      </Button>
      <Link
        href="/dashboard"
        className="text-center font-sans text-[13px] font-medium text-moss"
      >
        Lewati dulu
      </Link>
    </form>
  );
}
