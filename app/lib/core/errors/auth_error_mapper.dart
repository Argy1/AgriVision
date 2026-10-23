/// Pemetaan pesan error Supabase Auth ke Bahasa Indonesia. Dipisah per konteks
/// karena kata kunci yang sama (mis. "invalid") berarti hal berbeda di login,
/// verifikasi OTP, dan pendaftaran. Fungsi murni supaya mudah diuji.
abstract final class AuthErrorMapper {
  static String signIn(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
    }
    return message;
  }

  static String otp(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('expired') || msg.contains('invalid')) {
      return 'Kode tidak valid atau sudah kedaluwarsa.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
    }
    return message;
  }

  static String signUp(String message, {String? code}) {
    final msg = message.toLowerCase();
    if (code == 'user_already_exists' || msg.contains('already registered')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (code == 'weak_password' || msg.contains('password')) {
      return 'Kata sandi terlalu lemah — gunakan minimal 8 karakter.';
    }
    if (code == 'over_request_rate_limit' ||
        msg.contains('rate limit') ||
        msg.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
    }
    if (code == 'email_address_invalid' ||
        (msg.contains('invalid') && msg.contains('email'))) {
      return 'Alamat email tidak valid.';
    }
    return message;
  }
}
