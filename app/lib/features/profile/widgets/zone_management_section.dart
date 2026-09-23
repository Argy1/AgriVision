import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../providers/zones_providers.dart';
import '../../../shared/widgets/icons.dart';
import '../../../shared/widgets/state_views.dart';
import 'add_zone_bottom_sheet.dart';

/// List + tambah zona -- TANPA hapus/edit (menjaga histori diagnosis tetap
/// utuh, sama seperti batasan RLS di web: tidak ada policy DELETE di zones).
class ZoneManagementSection extends ConsumerWidget {
  const ZoneManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kelola Zona', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text(
          'Zona tidak bisa dihapus untuk menjaga histori diagnosis tetap utuh.',
          style: TextStyle(fontSize: 11.5, color: AppColors.sage),
        ),
        const SizedBox(height: 10),
        zonesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorStateView(message: 'Gagal memuat zona: $e'),
          data: (zones) => zones.isEmpty
              ? const EmptyState(message: 'Belum ada zona.')
              : Column(
                  children: zones
                      .map(
                        (z) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderAlt),
                          ),
                          child: Row(
                            children: [
                              const Icon(AppIcons.grid, size: 16, color: AppColors.moss),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(z.displayLabel, style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showAddZoneBottomSheet(context),
            icon: const Icon(AppIcons.add, size: 16),
            label: const Text('Tambah Zona Baru'),
          ),
        ),
      ],
    );
  }
}
