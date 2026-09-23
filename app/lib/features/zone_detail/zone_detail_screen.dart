import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../providers/zones_providers.dart';
import '../../routing/route_paths.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/severity_chip.dart';
import '../../shared/widgets/stat_tile.dart';
import '../../shared/widgets/state_views.dart';
import '../history/widgets/history_list_tile.dart';
import 'widgets/disease_frequency_breakdown.dart';
import 'widgets/zone_trend_chart_card.dart';

class ZoneDetailScreen extends ConsumerWidget {
  const ZoneDetailScreen({super.key, required this.zoneId});
  final String zoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(zoneDetailProvider(zoneId));

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorStateView(
            message: 'Gagal memuat detail zona: $e',
            onRetry: () => ref.invalidate(zoneDetailProvider(zoneId)),
          ),
          data: (detail) {
            final latest = detail.latest;
            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              children: [
                Row(
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
                    Expanded(
                      child: Text(
                        detail.zone.displayLabel,
                        style: GoogleFonts.fraunces(fontSize: 19, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (latest?.status != null) ZoneStatusPill(status: latest!.status),
                  ],
                ),
                if (detail.zone.locationNote != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(
                      detail.zone.locationNote!,
                      style: const TextStyle(fontSize: 12, color: AppColors.sage),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: Formatters.healthScore(latest?.avgHealthScore),
                        label: 'skor kesehatan terkini',
                        icon: AppIcons.leaf,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        value: '${detail.recentDiagnoses.length}+',
                        label: 'total diagnosis',
                        icon: AppIcons.camera,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('${RoutePaths.unggah}?zone=${detail.zone.id}'),
                    icon: const Icon(AppIcons.camera, size: 16),
                    label: const Text('Unggah Foto untuk Zona Ini'),
                  ),
                ),
                const SizedBox(height: 16),
                ZoneTrendChartCard(history: detail.healthHistory),
                const SizedBox(height: 14),
                DiseaseFrequencyBreakdown(entries: detail.diseaseFrequency),
                const SizedBox(height: 16),
                const Text('Riwayat Diagnosis', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (detail.recentDiagnoses.isEmpty)
                  const EmptyState(message: 'Belum ada diagnosis di zona ini.')
                else
                  ...detail.recentDiagnoses.map((d) => HistoryListTile(item: d)),
              ],
            );
          },
        ),
      ),
    );
  }
}
