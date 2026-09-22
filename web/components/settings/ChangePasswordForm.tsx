"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type ChangePasswordInput, changePasswordSchema } from "@/lib/validation/settings";

export function ChangePasswordForm() {
  const [saved, setSaved] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<ChangePasswordInput>({ resolver: zodResolver(changePasswordSchema) });

  async function onSubmit(values: ChangePasswordInput) {
    setFormError(null);
    setSaved(false);
    const supabase = createClient();
    const { error } = await supabase.auth.updateUser({ password: values.password });

    if (error) {
      setFormError(error.message);
      return;
    }
    reset();
    setSaved(true);
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="new-password">Kata sandi baru</Label>
        <Input id="new-password" type="password" placeholder="Minimal 8 karakter" {...register("password")} />
        <FieldError>{errors.password?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="confirm-password">Konfirmasi kata sandi</Label>
        <Input id="confirm-password" type="password" {...register("confirmPassword")} />
        <FieldError>{errors.confirmPassword?.message}</FieldError>
      </div>
      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}
      {saved && <p className="font-sans text-[13px] text-moss-deep">Kata sandi berhasil diubah.</p>}
      <Button type="submit" variant="outline" className="w-fit" loading={isSubmitting}>
        Ubah Kata Sandi
      </Button>
    </form>
  );
}
