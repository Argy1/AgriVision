"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useForm } from "react-hook-form";

import { Button } from "@/components/ui/Button";
import { FieldError, Input, Label } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { type SignupInput, signupSchema } from "@/lib/validation/auth";

export function SignupForm() {
  const router = useRouter();
  const [formError, setFormError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<SignupInput>({
    resolver: zodResolver(signupSchema),
    defaultValues: { role: "petani" },
  });

  async function onSubmit(values: SignupInput) {
    setFormError(null);
    const supabase = createClient();

    const { data, error } = await supabase.auth.signUp({
      email: values.email,
      password: values.password,
      options: { data: { full_name: values.fullName } },
    });

    if (error) {
      setFormError(error.message);
      return;
    }

    const userId = data.user?.id;
    if (!userId) {
      setFormError("Akun berhasil dibuat, tapi sesi belum aktif — coba masuk manual.");
      return;
    }

    // Trigger handle_new_user() selalu set role default 'petani'. Timpa kalau
    // user memilih admin_ppl, selagi sesi baru ini masih aktif (valid karena
    // RLS profiles_update_own mengizinkan user mengubah row miliknya sendiri).
    if (values.role === "admin_ppl") {
      await supabase.from("profiles").update({ role: "admin_ppl" }).eq("id", userId);
    }

    router.replace("/dashboard");
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="fullName">Nama lengkap</Label>
        <Input id="fullName" placeholder="Nama Anda" {...register("fullName")} />
        <FieldError>{errors.fullName?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" placeholder="nama@email.com" {...register("email")} />
        <FieldError>{errors.email?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="password">Kata sandi</Label>
        <Input id="password" type="password" placeholder="Minimal 8 karakter" {...register("password")} />
        <FieldError>{errors.password?.message}</FieldError>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="role">Peran</Label>
        <select
          id="role"
          className="w-full rounded-sm border border-input-border bg-input-bg px-3.5 py-3 font-sans text-[14.5px] text-ink focus:border-moss"
          {...register("role")}
        >
          <option value="petani">Petani</option>
          <option value="admin_ppl">Admin PPL</option>
        </select>
        <FieldError>{errors.role?.message}</FieldError>
      </div>

      {formError && <p className="font-sans text-[13px] text-rust-text">{formError}</p>}

      <Button type="submit" className="mt-1.5" loading={isSubmitting}>
        Buat Akun
      </Button>
    </form>
  );
}
