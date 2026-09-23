import 'enums.dart';

/// Baris agregat harian `zone_health_daily` -- diisi oleh trigger DB
/// `upsert_zone_health_daily` (SECURITY DEFINER) setiap ada
/// `vegetation_index_readings` baru. `date` adalah tanggal kalender
/// Asia/Jakarta, BUKAN UTC (lihat `core/utils/jakarta_date.dart`).
class ZoneHealthDaily {
  const ZoneHealthDaily({
    required this.id,
    required this.zoneId,
    required this.date,
    required this.diagnosisCount,
    required this.status,
    this.avgHealthScore,
  });

  final String id;
  final String zoneId;
  final DateTime date;
  final double? avgHealthScore;
  final int diagnosisCount;
  final ZoneStatus status;

  factory ZoneHealthDaily.fromJson(Map<String, dynamic> json) => ZoneHealthDaily(
    id: json['id'] as String,
    zoneId: json['zone_id'] as String,
    date: DateTime.parse(json['date'] as String),
    avgHealthScore: (json['avg_health_score'] as num?)?.toDouble(),
    diagnosisCount: json['diagnosis_count'] as int? ?? 0,
    status: ZoneStatus.fromJson(json['status'] as String? ?? 'sehat'),
  );
}
