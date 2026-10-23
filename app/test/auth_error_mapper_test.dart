import 'package:agrivision_app/core/errors/auth_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthErrorMapper.signUp', () {
    test('email sudah terdaftar (lewat code atau pesan)', () {
      expect(AuthErrorMapper.signUp('x', code: 'user_already_exists'), contains('sudah terdaftar'));
      expect(AuthErrorMapper.signUp('User already registered'), contains('sudah terdaftar'));
    });

    test('password lemah', () {
      expect(AuthErrorMapper.signUp('x', code: 'weak_password'), contains('lemah'));
      expect(AuthErrorMapper.signUp('Password should be at least 8 characters'), contains('lemah'));
    });

    test('rate limit dan email tidak valid', () {
      expect(AuthErrorMapper.signUp('x', code: 'over_request_rate_limit'), contains('Terlalu banyak'));
      expect(AuthErrorMapper.signUp('Email address "a" is invalid'), contains('tidak valid'));
    });

    test('error tak dikenal diteruskan apa adanya', () {
      expect(AuthErrorMapper.signUp('Sesuatu terjadi'), 'Sesuatu terjadi');
    });

    test('kata "invalid" di pendaftaran TIDAK diberi label kode OTP', () {
      expect(AuthErrorMapper.signUp('Email address "a" is invalid'), isNot(contains('Kode')));
    });
  });

  group('AuthErrorMapper.signIn / otp', () {
    test('login salah', () {
      expect(AuthErrorMapper.signIn('Invalid login credentials'), 'Email atau kata sandi salah.');
    });

    test('otp kedaluwarsa/invalid', () {
      expect(AuthErrorMapper.otp('Token has expired or is invalid'), contains('Kode tidak valid'));
    });
  });
}
