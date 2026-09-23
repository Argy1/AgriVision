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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Navigasi ditangani otomatis oleh auth guard di app_router.dart.
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MossHeroPanel(headline: 'Diagnosis dini,\npanen lebih baik.'),
            AuthBottomSheetCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masuk ke akun Anda',
                      style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pantau kesehatan tanaman dari genggaman tangan.',
                      style: TextStyle(fontSize: 13, color: AppColors.sage),
                    ),
                    const SizedBox(height: 20),
                    const Text('Email', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'nama@email.com'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
                    ),
                    const SizedBox(height: 13),
                    const Text('Kata sandi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Masukkan kata sandi' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(RoutePaths.forgotPassword),
                        child: const Text('Lupa kata sandi?'),
                      ),
                    ),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12.5)),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 6),
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
                            : const Text('Masuk'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12.5, color: AppColors.sage),
                          children: [
                            TextSpan(text: 'Belum punya akun?\n'),
                            TextSpan(
                              text: 'Hubungi admin di wilayah Anda',
                              style: TextStyle(color: AppColors.moss, fontWeight: FontWeight.w600),
                            ),
                          ],
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
