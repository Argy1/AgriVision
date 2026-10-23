import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/color_tokens.dart';
import '../../providers/repository_providers.dart';
import '../../routing/route_paths.dart';
import 'widgets/auth_bottom_sheet_card.dart';
import 'widgets/moss_hero_panel.dart';

/// Pendaftaran publik. Sukses -> sesi aktif -> router mengalihkan /daftar ke
/// /mulai (onboarding zona pertama), lihat `routing/app_router.dart`.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUp(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Navigasi otomatis: auth guard mengalihkan /daftar -> /mulai.
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MossHeroPanel(headline: 'Mulai pantau\ntanaman Anda.'),
            AuthBottomSheetCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat akun baru',
                      style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gratis — cukup satu menit untuk mulai.',
                      style: TextStyle(fontSize: 13, color: AppColors.sage),
                    ),
                    const SizedBox(height: 20),
                    _label('Nama lengkap'),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(hintText: 'Nama Anda'),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.length < 2) return 'Nama minimal 2 karakter';
                        if (t.length > 100) return 'Nama maksimal 100 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 13),
                    _label('Email'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(hintText: 'nama@email.com'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
                    ),
                    const SizedBox(height: 13),
                    _label('Kata sandi'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        hintText: 'Minimal 8 karakter',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 8) ? 'Kata sandi minimal 8 karakter' : null,
                    ),
                    const SizedBox(height: 13),
                    _label('Konfirmasi kata sandi'),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: const InputDecoration(hintText: 'Ulangi kata sandi'),
                      validator: (v) => v != _passwordController.text
                          ? 'Konfirmasi kata sandi tidak cocok'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
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
                            : const Text('Daftar'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go(RoutePaths.login),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12.5, color: AppColors.sage),
                            children: [
                              TextSpan(text: 'Sudah punya akun?\n'),
                              TextSpan(
                                text: 'Masuk',
                                style: TextStyle(color: AppColors.moss, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
