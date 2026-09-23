import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import '../../data/models/enums.dart';
import '../../providers/disease_reference_providers.dart';
import '../../routing/route_paths.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/disease_guide_tile.dart';

/// Browse seluruh `disease_reference` -- LIST + DETAIL DIGABUNG jadi satu
/// layar dengan expand/collapse (bukan push-to-detail terpisah), supaya
/// petani tidak perlu bolak-balik tap-back berulang saat melihat referensi
/// di lapangan (16 baris total, cukup kecil untuk satu layar scroll).
class DiseaseGuideScreen extends ConsumerWidget {
  const DiseaseGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(diseaseReferenceProvider);
    final cropFilter = ref.watch(diseaseGuideCropFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.canPop() ? context.pop() : context.go(RoutePaths.beranda),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(AppIcons.back, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Panduan Penyakit', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 4, 22, 0),
              child: Text(
                'Referensi gejala & rekomendasi penanganan untuk tomat dan cabai.',
                style: TextStyle(fontSize: 12.5, color: AppColors.sage),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: CropType.values.map((crop) {
                  final selected = cropFilter == crop;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(crop.label),
                      selected: selected,
                      onSelected: (_) => ref.read(diseaseGuideCropFilterProvider.notifier).state = crop,
                      selectedColor: AppColors.mossTint,
                      side: BorderSide(color: selected ? AppColors.moss : AppColors.border),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: allAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorStateView(
                  message: 'Gagal memuat panduan: $e',
                  onRetry: () => ref.invalidate(diseaseReferenceProvider),
                ),
                data: (all) {
                  final filtered = all.where((e) => e.cropType == cropFilter).toList();
                  if (filtered.isEmpty) {
                    return const EmptyState(message: 'Belum ada data untuk kategori ini.');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => DiseaseGuideTile(entry: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
