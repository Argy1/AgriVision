import 'enums.dart';

class HistoryFilter {
  const HistoryFilter({
    this.zoneId,
    this.cropType,
    this.severity,
    this.dateFrom,
    this.dateTo,
  });

  final String? zoneId;
  final CropType? cropType;
  final SeverityLevel? severity;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  bool get isEmpty =>
      zoneId == null && cropType == null && severity == null && dateFrom == null && dateTo == null;

  HistoryFilter copyWith({
    String? zoneId,
    bool clearZoneId = false,
    CropType? cropType,
    bool clearCropType = false,
    SeverityLevel? severity,
    bool clearSeverity = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDateRange = false,
  }) => HistoryFilter(
    zoneId: clearZoneId ? null : (zoneId ?? this.zoneId),
    cropType: clearCropType ? null : (cropType ?? this.cropType),
    severity: clearSeverity ? null : (severity ?? this.severity),
    dateFrom: clearDateRange ? null : (dateFrom ?? this.dateFrom),
    dateTo: clearDateRange ? null : (dateTo ?? this.dateTo),
  );
}
