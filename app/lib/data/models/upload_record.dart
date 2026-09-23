class UploadRecord {
  const UploadRecord({
    required this.id,
    required this.zoneId,
    required this.uploadedBy,
    required this.imagePath,
    required this.capturedAt,
    required this.createdAt,
  });

  final String id;
  final String zoneId;
  final String uploadedBy;
  final String imagePath;
  final DateTime capturedAt;
  final DateTime createdAt;

  factory UploadRecord.fromJson(Map<String, dynamic> json) => UploadRecord(
    id: json['id'] as String,
    zoneId: json['zone_id'] as String,
    uploadedBy: json['uploaded_by'] as String,
    imagePath: json['image_path'] as String,
    capturedAt: DateTime.parse(json['captured_at'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
