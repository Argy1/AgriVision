"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type ProfileInput, profileSchema } from "@/lib/validation/settings";

export function ProfileForm({ initial }: { initial: { full_name: string; phone: string | null } }) {
  const [saved, setSaved] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ProfileInput>({
    resolver: zodResolver(profileSchema),
    defaultValues: { full_name: initial.full_name, phone: initial.phone ?? "" },
  });

  async function onSubmit(values: ProfileInput) {
    setFormError(null);
    setSaved(false);
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return;

    const { error } = await supabase
      .from("profiles")
      .update({ full_name: values.full_name, phone: values.phone || null })
      .eq("id", user.id);

    if (error) {
      setFormError(error.message);
      return;
    }
    setSaved(true);
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="full_name">Nama lengkap</Label>
        <Input id="full_name" {...register("full_name")} />
        <FieldError>{errors.full_name?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="phone">Nomor telepon</Label>
        <Input id="phone" placeholder="08xxxxxxxxxx" {...register("phone")} />
      </div>
      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}
      {saved && <p className="font-sans text-[13px] text-moss-deep">Profil tersimpan.</p>}
      <Button type="submit" variant="outline" className="w-fit" loading={isSubmitting}>
        Simpan Profil
      </Button>
    </form>
  );
}
