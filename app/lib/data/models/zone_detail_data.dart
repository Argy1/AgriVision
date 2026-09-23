import 'diagnosis_list_item.dart';
import 'disease_frequency_entry.dart';
import 'zone.dart';
import 'zone_health_daily.dart';

/// Data lengkap untuk layar Detail Zona -- fitur baru yang memaksimalkan
/// Modul 2 (monitoring), dulu cuma numpang lewat sebagai satu sparkline
/// kecil di dashboard.
class ZoneDetailData {
  const ZoneDetailData({
    required this.zone,
    required this.healthHistory,
    required this.diseaseFrequency,
    required this.recentDiagnoses,
  });

  final Zone zone;

  /// Seluruh histori `zone_health_daily` zona ini (bukan dibatasi 30 hari).
  final List<ZoneHealthDaily> healthHistory;
  final List<DiseaseFrequencyEntry> diseaseFrequency;
  final List<DiagnosisListItem> recentDiagnoses;

  ZoneHealthDaily? get latest => healthHistory.isEmpty ? null : healthHistory.last;
}
