import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/dashboard_summary.dart';
import '../data/models/diagnosis_list_item.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';
import 'zones_providers.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) {
    return const DashboardSummary(
      zoneCount: 0,
      weekDiagnosisCount: 0,
      needsAttentionCount: 0,
      avgHealthScore: null,
      trendPoints: [],
      zoneStatuses: [],
    );
  }
  // Ikut refresh saat daftar zona berubah (mis. setelah tambah zona baru).
  ref.watch(zonesProvider);
  return ref.watch(dashboardRepositoryProvider).getSummary(ownerId: profile.id);
});

final recentActivityProvider = FutureProvider<List<DiagnosisListItem>>((ref) {
  return ref.watch(historyRepositoryProvider).getRecentActivity();
});
