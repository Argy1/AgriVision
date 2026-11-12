import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/color_tokens.dart';
import '../../data/models/enums.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/zones_providers.dart';
import '../../routing/route_paths.dart';

/// Langkah 2 setelah daftar: buat zona pertama supaya akun baru langsung siap
/// upload foto. Bisa dilewati; zona juga bisa ditambah nanti di tab Profil.
class FirstZoneScreen extends ConsumerStatefulWidget {
  const FirstZoneScreen({super.key});

  @override
  ConsumerState<FirstZoneScreen> createState() => _FirstZoneScreenState();
}

class _FirstZoneScreenState extends ConsumerState<FirstZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final note = _noteController.text.trim();
      final zone = await ref.read(zonesProvider.notifier).createZone(
            name: _nameController.text.trim(),
            cropType: CropType.tomat,
            locationNote: note.isEmpty ? null : note,
          );
      ref.invalidate(dashboardSummaryProvider);
      if (mounted) context.go('${RoutePaths.unggah}?zone=${zone.id}');
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Gagal membuat zona. Coba lagi.');
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
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LANGKAH 2 DARI 2',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.sage,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Buat zona pertama Anda',
                  style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Zona adalah satu petak lahan yang Anda pantau. Zona lain bisa ditambah kapan saja di tab Profil.',
                  style: TextStyle(fontSize: 13, color: AppColors.sage, height: 1.4),
                ),
                const SizedBox(height: 22),
                _label('Nama zona'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Contoh: A1'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama zona wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _label('Catatan lokasi (opsional)'),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(hintText: 'Contoh: Blok belakang gudang'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12.5)),
                ],
                const SizedBox(height: 22),
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
                        : const Text('Buat zona & mulai'),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : () => context.go(RoutePaths.beranda),
                    child: const Text('Lewati dulu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
