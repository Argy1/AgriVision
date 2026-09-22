import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email({ message: "Masukkan email yang valid." }),
  password: z.string().min(1, { message: "Kata sandi wajib diisi." }),
  remember: z.boolean().optional(),
});
export type LoginInput = z.infer<typeof loginSchema>;

export const signupSchema = z.object({
  fullName: z.string().min(2, { message: "Nama minimal 2 karakter." }),
  email: z.string().email({ message: "Masukkan email yang valid." }),
  password: z.string().min(8, { message: "Kata sandi minimal 8 karakter." }),
  role: z.enum(["petani", "admin_ppl"], { message: "Pilih peran." }),
});
export type SignupInput = z.infer<typeof signupSchema>;

export const forgotPasswordSchema = z.object({
  email: z.string().email({ message: "Masukkan email yang valid." }),
});
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;

export const resetPasswordSchema = z
  .object({
    password: z.string().min(8, { message: "Kata sandi minimal 8 karakter." }),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Konfirmasi kata sandi tidak cocok.",
    path: ["confirmPassword"],
  });
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
