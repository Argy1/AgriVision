import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_providers.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/notifications_providers.dart';
import '../../routing/route_paths.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/stat_tile.dart';
import 'widgets/trend_sparkline_card.dart';
import 'widgets/zone_status_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = notificationsAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(notificationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(AppIcons.leaf, size: 14, color: AppColors.parchment),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AgriVision',
                        style: GoogleFonts.ibmPlexSans(fontSize: 15.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push(RoutePaths.notifikasi),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Center(child: Icon(AppIcons.bell, size: 18)),
                          if (unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.rust, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              profileAsync.when(
                data: (profile) => Text(
                  '${Formatters.greeting()}, ${profile?.firstName ?? ''}',
                  style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                loading: () => const SizedBox(height: 28),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.fullDateJakarta(DateTime.now().toUtc()),
                style: const TextStyle(fontSize: 12.5, color: AppColors.sage),
              ),
              const SizedBox(height: 16),
              summaryAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorStateView(
                  message: 'Gagal memuat ringkasan: $e',
                  onRetry: () => ref.invalidate(dashboardSummaryProvider),
                ),
                data: (summary) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatTileGrid(
                      tiles: [
                        StatTile(
                          value: '${summary.zoneCount}',
                          label: 'Zona dipantau',
                          icon: AppIcons.grid,
                        ),
                        StatTile(
                          value: '${summary.weekDiagnosisCount}',
                          label: 'Diagnosis minggu ini',
                          icon: AppIcons.camera,
                        ),
                        StatTile(
                          value: '${summary.needsAttentionCount}',
                          label: 'Perlu perhatian',
                          icon: AppIcons.warning,
                          alert: summary.needsAttentionCount > 0,
                        ),
                        StatTile(
                          value: Formatters.healthScore(summary.avgHealthScore),
                          label: 'Skor kesehatan',
                          icon: AppIcons.leaf,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TrendSparklineCard(points: summary.trendPoints, days: 30),
                    const SizedBox(height: 14),
                    ZoneStatusList(zones: summary.zoneStatuses),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
