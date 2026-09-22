"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type ResetPasswordInput, resetPasswordSchema } from "@/lib/validation/auth";

export function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [formError, setFormError] = useState<string | null>(null);
  // Tanpa ?code=..., tidak ada apa pun untuk ditukar -- form langsung siap
  // (nilai awal dihitung sekali, bukan lewat setState di dalam effect).
  const [ready, setReady] = useState(() => !searchParams.get("code"));

  // Link reset password Supabase membawa ?code=... (PKCE) -- tukar dengan
  // sesi asli sebelum form ini bisa dipakai untuk updateUser().
  useEffect(() => {
    const code = searchParams.get("code");
    if (!code) return;

    const supabase = createClient();
    supabase.auth.exchangeCodeForSession(code).then(({ error }) => {
      if (error) setFormError("Tautan reset tidak valid atau sudah kedaluwarsa.");
      setReady(true);
    });
  }, [searchParams]);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ResetPasswordInput>({ resolver: zodResolver(resetPasswordSchema) });

  async function onSubmit(values: ResetPasswordInput) {
    setFormError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.updateUser({ password: values.password });

    if (error) {
      setFormError(error.message);
      return;
    }

    router.replace("/dashboard");
    router.refresh();
  }

  if (!ready) {
    return <p className="font-sans text-[13.5px] text-sage">Memverifikasi tautan…</p>;
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="password">Kata sandi baru</Label>
        <Input id="password" type="password" placeholder="Minimal 8 karakter" {...register("password")} />
        <FieldError>{errors.password?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="confirmPassword">Konfirmasi kata sandi</Label>
        <Input id="confirmPassword" type="password" {...register("confirmPassword")} />
        <FieldError>{errors.confirmPassword?.message}</FieldError>
      </div>
      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}
      <Button type="submit" loading={isSubmitting}>
        Simpan Kata Sandi Baru
      </Button>
    </form>
  );
}
