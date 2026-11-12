/// Enum Dart yang memetakan persis ke enum Postgres di `database/schema.sql`.
/// Nilai string HARUS sama persis dengan nilai di database (dipakai untuk
/// serialisasi request/response, bukan cuma label tampilan).
library;

/// Proyek fokus ke tomat saja. Enum Postgres `crop_type` masih memuat 'cabai'
/// (tidak bisa di-drop dengan rapi), jadi `fromJson` sengaja toleran: nilai lain
/// dipetakan ke tomat supaya baris lama tidak membuat layar crash.
enum CropType {
  tomat;

  static CropType fromJson(String value) => CropType.tomat;

  String toJson() => name;

  String get label => 'Tomat';
}

enum SeverityLevel {
  ringan,
  sedang,
  parah;

  static SeverityLevel fromJson(String value) => SeverityLevel.values.byName(value);

  String toJson() => name;

  String get label => switch (this) {
    SeverityLevel.ringan => 'Ringan',
    SeverityLevel.sedang => 'Sedang',
    SeverityLevel.parah => 'Parah',
  };
}

enum ZoneStatus {
  sehat,
  waspada,
  perluTindakan;

  static ZoneStatus fromJson(String value) => switch (value) {
    'sehat' => ZoneStatus.sehat,
    'waspada' => ZoneStatus.waspada,
    'perlu_tindakan' => ZoneStatus.perluTindakan,
    _ => throw ArgumentError('Unknown zone_status: $value'),
  };

  String toJson() => switch (this) {
    ZoneStatus.sehat => 'sehat',
    ZoneStatus.waspada => 'waspada',
    ZoneStatus.perluTindakan => 'perlu_tindakan',
  };

  String get label => switch (this) {
    ZoneStatus.sehat => 'Sehat',
    ZoneStatus.waspada => 'Waspada',
    ZoneStatus.perluTindakan => 'Perlu tindakan',
  };
}

enum UserRole {
  adminPpl,
  petani;

  static UserRole fromJson(String value) => switch (value) {
    'admin_ppl' => UserRole.adminPpl,
    'petani' => UserRole.petani,
    _ => throw ArgumentError('Unknown role: $value'),
  };

  String toJson() => switch (this) {
    UserRole.adminPpl => 'admin_ppl',
    UserRole.petani => 'petani',
  };
}
