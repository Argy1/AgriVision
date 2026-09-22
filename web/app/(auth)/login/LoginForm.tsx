"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type LoginInput, loginSchema } from "@/lib/validation/auth";

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginInput>({ resolver: zodResolver(loginSchema) });

  async function onSubmit(values: LoginInput) {
    setFormError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({
      email: values.email,
      password: values.password,
    });

    if (error) {
      setFormError(
        error.message === "Invalid login credentials"
          ? "Email atau kata sandi salah."
          : error.message,
      );
      return;
    }

    router.replace(searchParams.get("redirectTo") || "/dashboard");
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" placeholder="nama@email.com" {...register("email")} />
        <FieldError>{errors.email?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="password">Kata sandi</Label>
        <Input
          id="password"
          type="password"
          placeholder="••••••••"
          {...register("password")}
        />
        <FieldError>{errors.password?.message}</FieldError>
      </div>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          <input
            id="remember"
            type="checkbox"
            className="h-[15px] w-[15px] accent-moss"
            {...register("remember")}
          />
          <label htmlFor="remember" className="font-sans text-[13px] text-sage">
            Ingat saya
          </label>
        </div>
        <Link href="/forgot-password" className="font-sans text-[13px] font-medium text-moss">
          Lupa kata sandi?
        </Link>
      </div>

      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}

      <Button type="submit" className="mt-1.5" loading={isSubmitting}>
        Masuk
      </Button>
    </form>
  );
}
