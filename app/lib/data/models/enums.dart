/// Enum Dart yang memetakan persis ke enum Postgres di `database/schema.sql`.
/// Nilai string HARUS sama persis dengan nilai di database (dipakai untuk
/// serialisasi request/response, bukan cuma label tampilan).
library;

enum CropType {
  tomat,
  cabai;

  static CropType fromJson(String value) => CropType.values.byName(value);

  String toJson() => name;

  String get label => switch (this) {
    CropType.tomat => 'Tomat',
    CropType.cabai => 'Cabai',
  };
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
