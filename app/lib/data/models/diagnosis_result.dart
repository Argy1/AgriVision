import 'enums.dart';

/// Envelope response `POST /api/diagnose` -- persis 3 field sesuai
/// `docs/04-api-contract.md` / `ml-service/app/schemas.py`. Selalu berisi
/// ketiganya sekaligus, tidak pernah dipecah jadi beberapa panggilan.
class DiagnosisResultData {
  const DiagnosisResultData({
    required this.diagnosisId,
    required this.diseaseLabel,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.affectedAreaPct,
    required this.exgScore,
    required this.variScore,
    required this.healthScore,
    required this.recommendationText,
    this.dosage,
    this.applicationSchedule,
    this.warningNote,
  });

  final String diagnosisId;
  final String diseaseLabel;
  final String diseaseName;
  final double confidence;
  final SeverityLevel severity;
  final double affectedAreaPct;

  final double exgScore;
  final double variScore;
  final double healthScore;

  final String recommendationText;
  final String? dosage;
  final String? applicationSchedule;
  final String? warningNote;

  factory DiagnosisResultData.fromJson(Map<String, dynamic> json) {
    final diagnosis = json['diagnosis'] as Map<String, dynamic>;
    final vegIndex = json['vegetation_index'] as Map<String, dynamic>;
    final recommendation = json['recommendation'] as Map<String, dynamic>;
    return DiagnosisResultData(
      diagnosisId: diagnosis['id'] as String,
      diseaseLabel: diagnosis['disease_label'] as String,
      diseaseName: diagnosis['disease_name'] as String,
      confidence: (diagnosis['confidence'] as num).toDouble(),
      severity: SeverityLevel.fromJson(diagnosis['severity'] as String),
      affectedAreaPct: (diagnosis['affected_area_pct'] as num).toDouble(),
      exgScore: (vegIndex['exg_score'] as num).toDouble(),
      variScore: (vegIndex['vari_score'] as num).toDouble(),
      healthScore: (vegIndex['health_score'] as num).toDouble(),
      recommendationText: recommendation['recommendation_text'] as String,
      dosage: recommendation['dosage'] as String?,
      applicationSchedule: recommendation['application_schedule'] as String?,
      warningNote: recommendation['warning_note'] as String?,
    );
  }
}
