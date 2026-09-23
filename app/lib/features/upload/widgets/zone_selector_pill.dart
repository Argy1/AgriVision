import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/zone.dart';
import '../../../shared/widgets/icons.dart';

class ZoneSelectorPill extends StatelessWidget {
  const ZoneSelectorPill({
    super.key,
    required this.zones,
    required this.selectedZone,
    required this.onSelect,
  });

  final List<Zone> zones;
  final Zone? selectedZone;
  final ValueChanged<Zone> onSelect;

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<Zone>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Zona', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            for (final z in zones)
              ListTile(
                title: Text(z.displayLabel),
                trailing: selectedZone?.id == z.id ? const Icon(AppIcons.check, color: AppColors.moss) : null,
                onTap: () => Navigator.of(context).pop(z),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) onSelect(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: zones.isEmpty ? null : () => _openPicker(context),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedZone == null ? 'Belum ada zona -- tambah di tab Profil' : 'Zona: ${selectedZone!.displayLabel}',
              style: const TextStyle(fontSize: 13.5),
              overflow: TextOverflow.ellipsis,
            ),
            const Icon(AppIcons.chevronDown, size: 18, color: AppColors.sage),
          ],
        ),
      ),
    );
  }
}
