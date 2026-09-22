import { z } from "zod";

export const profileSchema = z.object({
  full_name: z.string().min(2, { message: "Nama minimal 2 karakter." }),
  phone: z.string().optional(),
});
export type ProfileInput = z.infer<typeof profileSchema>;

export const changePasswordSchema = z
  .object({
    password: z.string().min(8, { message: "Kata sandi minimal 8 karakter." }),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Konfirmasi kata sandi tidak cocok.",
    path: ["confirmPassword"],
  });
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
