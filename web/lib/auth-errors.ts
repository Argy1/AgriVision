/** Pesan error pendaftaran dalam Bahasa Indonesia dari error Supabase Auth. */
export function mapSignUpError(error: { message: string; code?: string; status?: number }): {
  message: string;
  emailTaken: boolean;
} {
  const msg = error.message.toLowerCase();

  if (error.code === "user_already_exists" || msg.includes("already registered")) {
    return { message: "Email ini sudah terdaftar.", emailTaken: true };
  }
  if (error.code === "weak_password" || msg.includes("password")) {
    return { message: "Kata sandi terlalu lemah — gunakan minimal 8 karakter.", emailTaken: false };
  }
  if (error.code === "over_request_rate_limit" || error.status === 429 || msg.includes("rate limit")) {
    return { message: "Terlalu banyak percobaan. Coba lagi beberapa menit lagi.", emailTaken: false };
  }
  if (error.code === "email_address_invalid" || (msg.includes("invalid") && msg.includes("email"))) {
    return { message: "Alamat email tidak valid.", emailTaken: false };
  }
  return { message: error.message, emailTaken: false };
}
