import 'diagnosis.dart';
import 'diagnosis_list_item.dart';
import 'recommendation.dart';
import 'vegetation_index_reading.dart';
import 'zone.dart';

/// Data lengkap Hasil Diagnosis -- dipakai baik setelah upload baru maupun
/// saat dibuka lewat Riwayat/Detail Zona (satu layar, satu sumber data,
/// selalu di-load ulang dari DB lewat `diagnosisId` supaya konsisten).
///
/// Pengayaan di atas mockup 7 (data sudah tersedia lewat query paralel
/// tambahan, pola sama seperti web `diagnosis/[id]`):
/// - `healthScore` dari `vegetation_index_readings` (join by upload_id)
/// - `daysSinceFirstOccurrence`: diagnosis pertama dengan disease_label sama
///   di zona yang sama
/// - `recentHistory`: 5 diagnosis terakhir di zona itu (strip dot histori)
class DiagnosisDetail {
  const DiagnosisDetail({
    required this.diagnosis,
    required this.recommendation,
    required this.zone,
    required this.recentHistory,
    this.vegetationIndex,
    this.daysSinceFirstOccurrence,
  });

  final Diagnosis diagnosis;
  final Recommendation recommendation;
  final VegetationIndexReading? vegetationIndex;
  final Zone zone;
  final int? daysSinceFirstOccurrence;
  final List<DiagnosisListItem> recentHistory;
}
