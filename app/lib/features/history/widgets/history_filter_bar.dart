import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/history_filter.dart';
import '../../../data/models/zone.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.filter,
    required this.zones,
    required this.onChanged,
  });

  final HistoryFilter filter;
  final List<Zone> zones;
  final ValueChanged<HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: filter.zoneId == null
                ? 'Semua Zona'
                : zones.where((z) => z.id == filter.zoneId).firstOrNullName(),
            selected: filter.zoneId != null,
            onTap: () => _showZonePicker(context),
          ),
          const SizedBox(width: 8),
          for (final severity in SeverityLevel.values) ...[
            _FilterChip(
              label: severity.label,
              selected: filter.severity == severity,
              onTap: () => onChanged(
                filter.severity == severity
                    ? filter.copyWith(clearSeverity: true)
                    : filter.copyWith(severity: severity),
              ),
            ),
            const SizedBox(width: 8),
          ],
          for (final crop in CropType.values) ...[
            _FilterChip(
              label: crop.label,
              selected: filter.cropType == crop,
              onTap: () => onChanged(
                filter.cropType == crop
                    ? filter.copyWith(clearCropType: true)
                    : filter.copyWith(cropType: crop),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _showZonePicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.paper,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Semua Zona'), onTap: () => Navigator.pop(context, '')),
            for (final z in zones)
              ListTile(title: Text(z.displayLabel), onTap: () => Navigator.pop(context, z.id)),
          ],
        ),
      ),
    );
    if (picked == null) return;
    onChanged(picked.isEmpty ? filter.copyWith(clearZoneId: true) : filter.copyWith(zoneId: picked));
  }
}

extension on Iterable<Zone> {
  String firstOrNullName() {
    for (final z in this) {
      return z.name;
    }
    return 'Zona';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.mossTint,
      backgroundColor: AppColors.paper,
      side: BorderSide(color: selected ? AppColors.moss : AppColors.border),
      labelStyle: TextStyle(color: selected ? AppColors.mossDeep : AppColors.ink),
    );
  }
}
