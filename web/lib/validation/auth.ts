import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email({ message: "Masukkan email yang valid." }),
  password: z.string().min(1, { message: "Kata sandi wajib diisi." }),
  remember: z.boolean().optional(),
});
export type LoginInput = z.infer<typeof loginSchema>;

// Pendaftaran publik: TIDAK ada field role -- akun baru selalu 'petani'
// (dipaksa trigger handle_new_user di DB; admin_ppl dinaikkan manual).
export const registerSchema = z
  .object({
    fullName: z
      .string()
      .trim()
      .min(2, { message: "Nama minimal 2 karakter." })
      .max(100, { message: "Nama maksimal 100 karakter." }),
    email: z.string().email({ message: "Masukkan email yang valid." }),
    password: z.string().min(8, { message: "Kata sandi minimal 8 karakter." }),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Konfirmasi kata sandi tidak cocok.",
    path: ["confirmPassword"],
  });
export type RegisterInput = z.infer<typeof registerSchema>;

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
