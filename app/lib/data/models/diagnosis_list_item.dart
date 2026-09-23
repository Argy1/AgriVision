import 'enums.dart';

/// Baris diagnosis + info zona-nya, dipakai di Riwayat, Detail Zona, dan
/// aktivitas terbaru dashboard -- hasil join `diagnoses` + `uploads` +
/// `zones` (tidak ada FK langsung diagnoses->zones).
class DiagnosisListItem {
  const DiagnosisListItem({
    required this.diagnosisId,
    required this.diseaseLabel,
    required this.diseaseName,
    required this.severity,
    required this.confidence,
    required this.createdAt,
    required this.zoneId,
    required this.zoneName,
    required this.cropType,
  });

  final String diagnosisId;
  final String diseaseLabel;
  final String diseaseName;
  final SeverityLevel severity;
  final double confidence;
  final DateTime createdAt;
  final String zoneId;
  final String zoneName;
  final CropType cropType;

  factory DiagnosisListItem.fromJoinedJson(Map<String, dynamic> json) {
    final upload = json['uploads'] as Map<String, dynamic>;
    final zone = upload['zones'] as Map<String, dynamic>;
    return DiagnosisListItem(
      diagnosisId: json['id'] as String,
      diseaseLabel: json['disease_label'] as String,
      diseaseName: json['disease_name'] as String,
      severity: SeverityLevel.fromJson(json['severity'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      zoneId: zone['id'] as String,
      zoneName: zone['name'] as String,
      cropType: CropType.fromJson(zone['crop_type'] as String),
    );
  }
}
