class VegetationIndexReading {
  const VegetationIndexReading({
    required this.id,
    required this.uploadId,
    required this.exgScore,
    required this.variScore,
    required this.healthScore,
    required this.createdAt,
  });

  final String id;
  final String uploadId;
  final double exgScore;
  final double variScore;
  final double healthScore;
  final DateTime createdAt;

  factory VegetationIndexReading.fromJson(Map<String, dynamic> json) =>
      VegetationIndexReading(
        id: json['id'] as String,
        uploadId: json['upload_id'] as String,
        exgScore: (json['exg_score'] as num).toDouble(),
        variScore: (json['vari_score'] as num).toDouble(),
        healthScore: (json['health_score'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
