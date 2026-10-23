import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;

import '../../core/errors/app_exception.dart';
import '../../core/errors/auth_error_mapper.dart';
import '../models/profile.dart';

/// Pendaftaran publik (`signUp`) membuat akun `petani` -- role dipaksa trigger
/// DB handle_new_user(); admin_ppl dinaikkan manual. Tanpa verifikasi email
/// (Confirm email dimatikan di Supabase), jadi signUp langsung mengembalikan
/// sesi. Reset password pakai flow OTP 6-digit (bukan magic-link), supaya
/// tidak perlu setup Android App Links / iOS Universal Links.
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
      throw AuthException(AuthErrorMapper.signIn(e.message));
    }
  }

  /// Daftar akun baru. Melempar [AuthException] bila gagal, atau bila server
  /// tidak mengembalikan sesi (berarti "Confirm email" masih aktif di Supabase).
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (res.session == null) {
        throw const AuthException(
          'Akun dibuat, tapi verifikasi email masih aktif di server sehingga belum bisa langsung masuk. Hubungi admin.',
        );
      }
    } on supa.AuthException catch (e) {
      throw AuthException(AuthErrorMapper.signUp(e.message, code: e.code));
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Langkah 1 lupa password: minta kode OTP 6-digit dikirim ke email.
  Future<void> requestPasswordResetOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email, shouldCreateUser: false);
    } on supa.AuthException catch (e) {
      throw AuthException(AuthErrorMapper.otp(e.message));
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
      throw AuthException(AuthErrorMapper.otp(e.message));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
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

}
