import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/jakarta_date.dart';
import '../models/dashboard_summary.dart';
import '../models/enums.dart';
import '../models/zone.dart';
import '../models/zone_health_daily.dart';

/// Ringkasan dashboard petani -- skala kecil (zona milik satu akun), jadi
/// tidak butuh forward-fill lintas-zona serumit versi admin di web.
class DashboardRepository {
  DashboardRepository(this._client);

  final SupabaseClient _client;

  Future<DashboardSummary> getSummary({required String ownerId, int trendDays = 30}) async {
    final zonesRows = await _client.from('zones').select('*').eq('owner_id', ownerId);
    final zones = (zonesRows as List).map((r) => Zone.fromJson(r as Map<String, dynamic>)).toList();

    if (zones.isEmpty) {
      return const DashboardSummary(
        zoneCount: 0,
        weekDiagnosisCount: 0,
        needsAttentionCount: 0,
        avgHealthScore: null,
        trendPoints: [],
        zoneStatuses: [],
      );
    }

    final zoneIds = zones.map((z) => z.id).toList();
    final weekAgoUtc = DateTime.now().toUtc().subtract(const Duration(days: 7));
    final trendStartDate = jakartaDateMinusDays(trendDays);

    final results = await Future.wait([
      _client
          .from('diagnoses')
          .select('id, uploads!inner(zone_id)')
          .inFilter('uploads.zone_id', zoneIds)
          .gte('created_at', weekAgoUtc.toIso8601String()),
      _client
          .from('zone_health_daily')
          .select('*')
          .inFilter('zone_id', zoneIds)
          .gte('date', trendStartDate)
          .order('date'),
    ]);

    final weekDiagnosisRows = results[0] as List;
    final healthRows = (results[1] as List)
        .map((r) => ZoneHealthDaily.fromJson(r as Map<String, dynamic>))
        .toList();

    // Baris terbaru per zona.
    final latestByZone = <String, ZoneHealthDaily>{};
    for (final row in healthRows) {
      final existing = latestByZone[row.zoneId];
      if (existing == null || row.date.isAfter(existing.date)) {
        latestByZone[row.zoneId] = row;
      }
    }

    final needsAttention = latestByZone.values.where((h) => h.status == ZoneStatus.perluTindakan).length;

    final scoresWithValue = latestByZone.values
        .map((h) => h.avgHealthScore)
        .whereType<double>()
        .toList();
    final avgHealth = scoresWithValue.isEmpty
        ? null
        : scoresWithValue.reduce((a, b) => a + b) / scoresWithValue.length;

    // Tren rata-rata lintas zona per hari.
    final byDate = <String, List<double>>{};
    for (final row in healthRows) {
      final score = row.avgHealthScore;
      if (score == null) continue;
      final key = toJakartaDateString(row.date.toUtc());
      byDate.putIfAbsent(key, () => []).add(score);
    }
    final trendPoints = byDate.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return TrendPoint(date: parseDateOnly(e.key), value: avg);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Status per zona, diurutkan skor kesehatan terendah dulu (paling butuh
    // perhatian) -- pola yang sudah terbukti berguna di web.
    final zoneStatuses = zones.map((z) {
      final health = latestByZone[z.id];
      return ZoneStatusSummary(
        zone: z,
        healthScore: health?.avgHealthScore,
        status: health?.status,
      );
    }).toList()
      ..sort((a, b) {
        final aScore = a.healthScore ?? 999;
        final bScore = b.healthScore ?? 999;
        return aScore.compareTo(bScore);
      });

    return DashboardSummary(
      zoneCount: zones.length,
      weekDiagnosisCount: weekDiagnosisRows.length,
      needsAttentionCount: needsAttention,
      avgHealthScore: avgHealth,
      trendPoints: trendPoints,
      zoneStatuses: zoneStatuses,
    );
  }
}
