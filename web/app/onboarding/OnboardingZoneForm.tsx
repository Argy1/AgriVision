"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type CreateZoneInput, createZoneSchema } from "@/lib/validation/zone";

const CROPS = [
  { value: "tomat", label: "Tomat", hint: "10 jenis penyakit dikenali" },
  { value: "cabai", label: "Cabai", hint: "6 jenis penyakit dikenali" },
] as const;

export function OnboardingZoneForm() {
  const router = useRouter();
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<CreateZoneInput>({
    resolver: zodResolver(createZoneSchema),
    defaultValues: { crop_type: "tomat" },
  });

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
        crop_type: values.crop_type,
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

      <fieldset className="flex flex-col gap-1.5">
        <legend className="mb-1.5 font-sans text-[13.5px] font-medium text-ink">
          Jenis tanaman
        </legend>
        <div className="grid grid-cols-2 gap-3">
          {CROPS.map((crop) => (
            <label key={crop.value} className="cursor-pointer">
              <input
                type="radio"
                value={crop.value}
                className="peer sr-only"
                {...register("crop_type")}
              />
              <div className="rounded-sm border border-input-border bg-input-bg px-4 py-3.5 transition-colors peer-checked:border-moss peer-checked:bg-moss-tint peer-focus-visible:ring-2 peer-focus-visible:ring-moss">
                <p className="font-display text-[18px] font-semibold text-ink">{crop.label}</p>
                <p className="mt-0.5 font-sans text-[12px] text-sage">{crop.hint}</p>
              </div>
            </label>
          ))}
        </div>
        <FieldError>{errors.crop_type?.message}</FieldError>
      </fieldset>

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
