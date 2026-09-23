import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../providers/diagnosis_providers.dart';
import '../../routing/route_paths.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/severity_chip.dart';
import '../../shared/widgets/severity_meter_bar.dart';
import '../../shared/widgets/stat_tile.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/diagnosis_history_dot_strip.dart';
import 'widgets/leaf_illustration_card.dart';
import 'widgets/recommendation_callout_card.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  const DiagnosisResultScreen({super.key, required this.diagnosisId});
  final String diagnosisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(diagnosisDetailProvider(diagnosisId));

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorStateView(
            message: 'Gagal memuat hasil diagnosis: $e',
            onRetry: () => ref.invalidate(diagnosisDetailProvider(diagnosisId)),
          ),
          data: (detail) {
            final d = detail.diagnosis;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 4),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Diagnosis',
                            style: GoogleFonts.fraunces(fontSize: 19, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Zona ${detail.zone.name} — ${Formatters.relativeOrTime(d.createdAt)}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.sage),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
                    children: [
                      Center(
                        child: LeafIllustrationCard(
                          severity: d.severity,
                          affectedAreaPct: d.affectedAreaPct,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Diagnosis', style: TextStyle(fontSize: 12, color: AppColors.sage)),
                      const SizedBox(height: 2),
                      Text(
                        d.diseaseName,
                        style: GoogleFonts.fraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.25),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ConfidenceChip(confidence: d.confidence),
                          SeverityChip(severity: d.severity),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SeverityMeterBar(severity: d.severity),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              value: Formatters.percent(d.affectedAreaPct),
                              label: 'area terdampak',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatTile(
                              value: detail.daysSinceFirstOccurrence == null
                                  ? '—'
                                  : '${detail.daysSinceFirstOccurrence} hari',
                              label: 'sejak gejala pertama',
                            ),
                          ),
                        ],
                      ),
                      if (detail.vegetationIndex != null) ...[
                        const SizedBox(height: 10),
                        StatTile(
                          value: Formatters.healthScore(detail.vegetationIndex!.healthScore),
                          label: 'skor kesehatan (ExG/VARI)',
                          icon: AppIcons.leaf,
                        ),
                      ],
                      const SizedBox(height: 16),
                      RecommendationCalloutCard(recommendation: detail.recommendation),
                      const SizedBox(height: 16),
                      Text(
                        'Riwayat Zona ${detail.zone.name}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DiagnosisHistoryDotStrip(items: detail.recentHistory, currentId: diagnosisId),
                      TextButton(
                        onPressed: () => context.push('${RoutePaths.riwayat}?zone=${detail.zone.id}'),
                        child: const Text('Lihat riwayat lengkap'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tersimpan di riwayat.')),
                        );
                        context.go(RoutePaths.riwayat);
                      },
                      child: const Text('Simpan ke Riwayat'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
