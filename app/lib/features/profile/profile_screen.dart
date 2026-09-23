import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/color_tokens.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repository_providers.dart';
import '../../shared/widgets/card_container.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/zone_management_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          children: [
            Text('Profil', style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text(
              'Kelola profil, zona, dan keamanan akun Anda',
              style: TextStyle(fontSize: 13, color: AppColors.sage),
            ),
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorStateView(message: 'Gagal memuat profil: $e'),
              data: (profile) => CardContainer(
                child: _ProfileForm(
                  initialName: profile?.fullName ?? '',
                  initialPhone: profile?.phone ?? '',
                ),
              ),
            ),
            const SizedBox(height: 14),
            CardContainer(child: const _ChangePasswordForm()),
            const SizedBox(height: 14),
            CardContainer(child: const ZoneManagementSection()),
            const SizedBox(height: 14),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Akun', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Keluar dari sesi Anda saat ini.', style: TextStyle(fontSize: 11.5, color: AppColors.sage)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rustText,
                        side: const BorderSide(color: AppColors.rustDivider),
                      ),
                      onPressed: () => ref.read(authRepositoryProvider).signOut(),
                      icon: const Icon(AppIcons.logout, size: 16),
                      label: const Text('Keluar dari Akun'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.initialName, required this.initialPhone});
  final String initialName;
  final String initialPhone;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _phoneController = TextEditingController(text: widget.initialPhone);
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
      ref.invalidate(currentProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil disimpan.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profil', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Text('Nama lengkap', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _nameController),
        const SizedBox(height: 12),
        const Text('Nomor telepon', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _loading ? null : _save,
            child: const Text('Simpan Profil'),
          ),
        ),
      ],
    );
  }
}

class _ChangePasswordForm extends ConsumerStatefulWidget {
  const _ChangePasswordForm();

  @override
  ConsumerState<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<_ChangePasswordForm> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_newPasswordController.text.length < 8) {
      setState(() => _error = 'Kata sandi minimal 8 karakter.');
      return;
    }
    if (_newPasswordController.text != _confirmController.text) {
      setState(() => _error = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).updatePassword(_newPasswordController.text);
      _newPasswordController.clear();
      _confirmController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi diubah.')));
      }
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ubah Kata Sandi', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Text('Kata sandi baru', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _newPasswordController, obscureText: true),
        const SizedBox(height: 12),
        const Text('Konfirmasi kata sandi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _confirmController, obscureText: true),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12)),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _loading ? null : _submit,
            child: const Text('Ubah Kata Sandi'),
          ),
        ),
      ],
    );
  }
}
