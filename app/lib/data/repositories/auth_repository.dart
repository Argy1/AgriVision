import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;

import '../../core/errors/app_exception.dart';
import '../models/profile.dart';

/// Login TIDAK punya self-signup -- akun disediakan admin (lihat copy di
/// mockup login: "Belum punya akun? Hubungi admin di wilayah Anda"). Reset
/// password pakai flow OTP 6-digit (bukan magic-link), supaya tidak perlu
/// setup Android App Links / iOS Universal Links yang tidak sepadan untuk
/// app thesis.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on supa.AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Langkah 1 lupa password: minta kode OTP 6-digit dikirim ke email.
  Future<void> requestPasswordResetOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email, shouldCreateUser: false);
    } on supa.AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Langkah 2: verifikasi kode OTP -- sukses berarti sesi aktif, siap untuk
  /// `updatePassword`.
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
    } on supa.AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on supa.AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<Profile?> getCurrentProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('profiles')
        .select('id, full_name, role, phone')
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client
        .from('profiles')
        .update({
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
        })
        .eq('id', userId);
  }

  AuthException _mapAuthError(supa.AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return const AuthException('Email atau kata sandi salah.');
    }
    if (msg.contains('token has expired') || msg.contains('invalid')) {
      return const AuthException('Kode tidak valid atau sudah kedaluwarsa.');
    }
    return AuthException(e.message);
  }
}
