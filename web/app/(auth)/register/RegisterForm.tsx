"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { mapSignUpError } from "@/lib/auth-errors";
import { createClient } from "@/lib/supabase/client";
import { type RegisterInput, registerSchema } from "@/lib/validation/auth";

export function RegisterForm() {
  const router = useRouter();
  const [formError, setFormError] = useState<string | null>(null);
  const [emailTaken, setEmailTaken] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RegisterInput>({ resolver: zodResolver(registerSchema) });

  async function onSubmit(values: RegisterInput) {
    setFormError(null);
    setEmailTaken(false);
    const supabase = createClient();

    const { data, error } = await supabase.auth.signUp({
      email: values.email,
      password: values.password,
      options: { data: { full_name: values.fullName } },
    });

    if (error) {
      const mapped = mapSignUpError(error);
      setFormError(mapped.message);
      setEmailTaken(mapped.emailTaken);
      return;
    }

    // Tanpa verifikasi email, signUp langsung mengembalikan sesi. Kalau sesi
    // kosong berarti "Confirm email" di Supabase Dashboard belum dimatikan.
    if (!data.session) {
      setFormError(
        "Akun dibuat, tapi belum bisa langsung masuk karena verifikasi email masih aktif di server. Hubungi admin.",
      );
      return;
    }

    router.replace("/onboarding");
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="fullName">Nama lengkap</Label>
        <Input id="fullName" autoComplete="name" placeholder="Nama Anda" {...register("fullName")} />
        <FieldError>{errors.fullName?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          autoComplete="email"
          placeholder="nama@email.com"
          {...register("email")}
        />
        <FieldError>{errors.email?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="password">Kata sandi</Label>
        <div className="relative">
          <Input
            id="password"
            type={showPassword ? "text" : "password"}
            autoComplete="new-password"
            placeholder="Minimal 8 karakter"
            className="pr-24"
            {...register("password")}
          />
          <button
            type="button"
            onClick={() => setShowPassword((v) => !v)}
            className="absolute right-3 top-1/2 -translate-y-1/2 font-sans text-[12.5px] font-medium text-moss"
          >
            {showPassword ? "Sembunyikan" : "Tampilkan"}
          </button>
        </div>
        <FieldError>{errors.password?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="confirmPassword">Konfirmasi kata sandi</Label>
        <Input
          id="confirmPassword"
          type={showPassword ? "text" : "password"}
          autoComplete="new-password"
          placeholder="Ulangi kata sandi"
          {...register("confirmPassword")}
        />
        <FieldError>{errors.confirmPassword?.message}</FieldError>
      </div>

      {formError && (
        <p className="font-sans text-[13px] text-rust-text">
          {formError}{" "}
          {emailTaken && (
            <Link href="/login" className="font-semibold underline">
              Masuk di sini
            </Link>
          )}
        </p>
      )}

      <Button type="submit" className="mt-1.5" loading={isSubmitting}>
        Daftar
      </Button>
    </form>
  );
}
