import 'enums.dart';

/// Baris knowledge-base `disease_reference` -- basis untuk layar Panduan
/// Penyakit (fitur baru, memaksimalkan data yang sudah ada tapi belum pernah
/// bisa di-browse di platform manapun).
class DiseaseReference {
  const DiseaseReference({
    required this.diseaseLabel,
    required this.diseaseName,
    required this.cropType,
    required this.recommendationText,
    required this.isVerified,
    this.description,
    this.dosage,
    this.applicationSchedule,
    this.warningNote,
  });

  final String diseaseLabel;
  final String diseaseName;
  final CropType cropType;
  final String? description;
  final String recommendationText;
  final String? dosage;
  final String? applicationSchedule;
  final String? warningNote;
  final bool isVerified;

  factory DiseaseReference.fromJson(Map<String, dynamic> json) => DiseaseReference(
    diseaseLabel: json['disease_label'] as String,
    diseaseName: json['disease_name'] as String,
    cropType: CropType.fromJson(json['crop_type'] as String),
    description: json['description'] as String?,
    recommendationText: json['recommendation_text'] as String,
    dosage: json['dosage'] as String?,
    applicationSchedule: json['application_schedule'] as String?,
    warningNote: json['warning_note'] as String?,
    isVerified: json['is_verified'] as bool? ?? false,
  );

  bool get isHealthyEntry => diseaseLabel.endsWith('_healthy');
}
