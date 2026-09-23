class Recommendation {
  const Recommendation({
    required this.id,
    required this.diagnosisId,
    required this.recommendationText,
    this.dosage,
    this.applicationSchedule,
    this.warningNote,
  });

  final String id;
  final String diagnosisId;
  final String recommendationText;
  final String? dosage;
  final String? applicationSchedule;
  final String? warningNote;

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    id: json['id'] as String,
    diagnosisId: json['diagnosis_id'] as String,
    recommendationText: json['recommendation_text'] as String,
    dosage: json['dosage'] as String?,
    applicationSchedule: json['application_schedule'] as String?,
    warningNote: json['warning_note'] as String?,
  );
}
