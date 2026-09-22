"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type ForgotPasswordInput, forgotPasswordSchema } from "@/lib/validation/auth";

export function ForgotPasswordForm() {
  const [sent, setSent] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ForgotPasswordInput>({ resolver: zodResolver(forgotPasswordSchema) });

  async function onSubmit(values: ForgotPasswordInput) {
    setFormError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(values.email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });

    if (error) {
      setFormError(error.message);
      return;
    }
    setSent(true);
  }

  if (sent) {
    return (
      <p className="rounded-sm border border-moss-tint bg-moss-tint px-4 py-3 font-sans text-[13.5px] text-moss-deep">
        Kalau email itu terdaftar, tautan reset kata sandi sudah dikirim. Cek kotak masuk Anda.
      </p>
    );
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" placeholder="nama@email.com" {...register("email")} />
        <FieldError>{errors.email?.message}</FieldError>
      </div>
      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}
      <Button type="submit" loading={isSubmitting}>
        Kirim Tautan Reset
      </Button>
    </form>
  );
}
