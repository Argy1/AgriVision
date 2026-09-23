import 'enums.dart';
import 'zone.dart';

class TrendPoint {
  const TrendPoint({required this.date, required this.value});
  final DateTime date;
  final double? value;
}

class ZoneStatusSummary {
  const ZoneStatusSummary({
    required this.zone,
    this.healthScore,
    this.status,
    this.trendDelta,
  });

  final Zone zone;
  final double? healthScore;
  final ZoneStatus? status;

  /// Selisih rata-rata 7 hari terakhir vs 7 hari sebelumnya -- null kalau
  /// datanya belum cukup untuk dihitung.
  final double? trendDelta;

  bool get isTrendingUp => (trendDelta ?? 0) >= 1;
  bool get isTrendingDown => (trendDelta ?? 0) <= -1;
}

/// Ringkasan untuk Beranda -- skala kecil (zona milik satu petani), tidak
/// perlu forward-fill kompleks seperti versi admin di web.
class DashboardSummary {
  const DashboardSummary({
    required this.zoneCount,
    required this.weekDiagnosisCount,
    required this.needsAttentionCount,
    required this.avgHealthScore,
    required this.trendPoints,
    required this.zoneStatuses,
  });

  final int zoneCount;
  final int weekDiagnosisCount;
  final int needsAttentionCount;
  final double? avgHealthScore;
  final List<TrendPoint> trendPoints;
  final List<ZoneStatusSummary> zoneStatuses;
}
