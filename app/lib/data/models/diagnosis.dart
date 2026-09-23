import 'enums.dart';

class Diagnosis {
  const Diagnosis({
    required this.id,
    required this.uploadId,
    required this.diseaseLabel,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.affectedAreaPct,
    required this.modelVersion,
    required this.createdAt,
  });

  final String id;
  final String uploadId;
  final String diseaseLabel;
  final String diseaseName;
  final double confidence;
  final SeverityLevel severity;
  final double affectedAreaPct;
  final String modelVersion;
  final DateTime createdAt;

  factory Diagnosis.fromJson(Map<String, dynamic> json) => Diagnosis(
    id: json['id'] as String,
    uploadId: json['upload_id'] as String,
    diseaseLabel: json['disease_label'] as String,
    diseaseName: json['disease_name'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    severity: SeverityLevel.fromJson(json['severity'] as String),
    affectedAreaPct: (json['affected_area_pct'] as num).toDouble(),
    modelVersion: json['model_version'] as String? ?? 'v1',
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  bool get isHealthy => diseaseLabel.endsWith('_healthy');
}
