import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/color_tokens.dart';
import '../../providers/repository_providers.dart';

/// Satu route, dua sub-state (masukkan kode -> masukkan kata sandi baru) --
/// error kode salah/kedaluwarsa ditampilkan inline, tidak route balik.
class ForgotPasswordVerifyScreen extends ConsumerStatefulWidget {
  const ForgotPasswordVerifyScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<ForgotPasswordVerifyScreen> createState() => _ForgotPasswordVerifyScreenState();
}

class _ForgotPasswordVerifyScreenState extends ConsumerState<ForgotPasswordVerifyScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _codeVerified = false;
  bool _loading = false;
  String? _error;
  bool _done = false;

  Future<void> _verifyCode() async {
    if (_codeController.text.trim().length != 6) {
      setState(() => _error = 'Kode harus 6 digit.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyPasswordResetOtp(
            email: widget.email,
            token: _codeController.text.trim(),
          );
      setState(() => _codeVerified = true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitNewPassword() async {
    if (_newPasswordController.text.length < 8) {
      setState(() => _error = 'Kata sandi minimal 8 karakter.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).updatePassword(_newPasswordController.text);
      setState(() => _done = true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).requestPasswordResetOtp(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode baru sudah dikirim.')),
        );
      }
    } on AppException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(backgroundColor: AppColors.paper, elevation: 0, foregroundColor: AppColors.ink),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 10, 26, 30),
        child: _done ? _buildDone(context) : (_codeVerified ? _buildNewPassword() : _buildCodeEntry()),
      ),
    );
  }

  Widget _buildCodeEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verifikasi Kode', style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'Masukkan kode 6 digit yang dikirim ke ${widget.email}.',
          style: const TextStyle(fontSize: 13, color: AppColors.sage, height: 1.4),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(counterText: '', hintText: '000000'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12.5)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _verifyCode,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Verifikasi'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(onPressed: _resend, child: const Text('Kirim ulang kode')),
        ),
      ],
    );
  }

  Widget _buildNewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kata Sandi Baru', style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text(
          'Kode terverifikasi -- buat kata sandi baru untuk akun Anda.',
          style: TextStyle(fontSize: 13, color: AppColors.sage),
        ),
        const SizedBox(height: 20),
        const Text('Kata sandi baru', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Minimal 8 karakter'),
        ),
        const SizedBox(height: 13),
        const Text('Konfirmasi kata sandi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Ulangi kata sandi baru'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12.5)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submitNewPassword,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Simpan Kata Sandi Baru'),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, size: 56, color: AppColors.moss),
        const SizedBox(height: 16),
        Text(
          'Kata sandi berhasil diubah',
          style: GoogleFonts.fraunces(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/beranda'),
            child: const Text('Ke Beranda'),
          ),
        ),
      ],
    );
  }
}
