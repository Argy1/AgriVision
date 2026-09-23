import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../data/models/enums.dart';
import '../../../providers/zones_providers.dart';

Future<void> showAddZoneBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const AddZoneSheetContent(),
  );
}

class AddZoneSheetContent extends ConsumerStatefulWidget {
  const AddZoneSheetContent({super.key});

  @override
  ConsumerState<AddZoneSheetContent> createState() => _AddZoneSheetContentState();
}

class _AddZoneSheetContentState extends ConsumerState<AddZoneSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  CropType _cropType = CropType.tomat;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(zonesProvider.notifier).createZone(
            name: _nameController.text.trim(),
            cropType: _cropType,
            locationNote: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Zona Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Nama Zona', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Contoh: A4'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama zona wajib diisi' : null,
            ),
            const SizedBox(height: 13),
            const Text('Jenis Tanaman', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<CropType>(
              initialValue: _cropType,
              items: CropType.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _cropType = v ?? CropType.tomat),
            ),
            const SizedBox(height: 13),
            const Text('Catatan Lokasi (opsional)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Contoh: Blok belakang gudang'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.rustText, fontSize: 12.5)),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Simpan Zona'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
