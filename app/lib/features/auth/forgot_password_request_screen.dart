import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/color_tokens.dart';
import '../../providers/repository_providers.dart';
import '../../routing/route_paths.dart';

class ForgotPasswordRequestScreen extends ConsumerStatefulWidget {
  const ForgotPasswordRequestScreen({super.key});

  @override
  ConsumerState<ForgotPasswordRequestScreen> createState() => _ForgotPasswordRequestScreenState();
}

class _ForgotPasswordRequestScreenState extends ConsumerState<ForgotPasswordRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailController.text.trim();
    try {
      await ref.read(authRepositoryProvider).requestPasswordResetOtp(email);
      if (mounted) {
        context.push('${RoutePaths.verifyCode}?email=${Uri.encodeComponent(email)}');
      }
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(backgroundColor: AppColors.paper, elevation: 0, foregroundColor: AppColors.ink),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 10, 26, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lupa Kata Sandi', style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text(
                'Masukkan email akun Anda -- kami akan mengirim kode 6 digit untuk mengatur ulang kata sandi.',
                style: TextStyle(fontSize: 13, color: AppColors.sage, height: 1.4),
              ),
              const SizedBox(height: 20),
              const Text('Email', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'nama@email.com'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12.5)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kirim Kode'),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Kembali ke halaman masuk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
