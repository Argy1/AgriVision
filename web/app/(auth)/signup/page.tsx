import { redirect } from "next/navigation";

// Rute lama (dulu tersembunyi, untuk bootstrap akun admin). Pendaftaran sekarang
// publik di /register -- role tidak bisa lagi dipilih dari form.
export default function SignupPage() {
  redirect("/register");
}
