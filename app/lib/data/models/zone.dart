import 'enums.dart';

class Zone {
  const Zone({
    required this.id,
    required this.name,
    required this.cropType,
    required this.ownerId,
    required this.createdAt,
    this.locationNote,
  });

  final String id;
  final String name;
  final CropType cropType;
  final String ownerId;
  final String? locationNote;
  final DateTime createdAt;

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
    id: json['id'] as String,
    name: json['name'] as String,
    cropType: CropType.fromJson(json['crop_type'] as String),
    ownerId: json['owner_id'] as String,
    locationNote: json['location_note'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'name': name,
    'crop_type': cropType.toJson(),
    'owner_id': ownerId,
    if (locationNote != null && locationNote!.isNotEmpty) 'location_note': locationNote,
  };

  /// "A3 — Blok Tomat", sesuai gaya mockup.
  String get displayLabel => '$name — Blok ${cropType.label}';
}
