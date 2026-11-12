import 'enums.dart';

class HistoryFilter {
  const HistoryFilter({
    this.zoneId,
    this.severity,
    this.dateFrom,
    this.dateTo,
  });

  final String? zoneId;
  final SeverityLevel? severity;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  bool get isEmpty => zoneId == null && severity == null && dateFrom == null && dateTo == null;

  HistoryFilter copyWith({
    String? zoneId,
    bool clearZoneId = false,
    SeverityLevel? severity,
    bool clearSeverity = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDateRange = false,
  }) => HistoryFilter(
    zoneId: clearZoneId ? null : (zoneId ?? this.zoneId),
    severity: clearSeverity ? null : (severity ?? this.severity),
    dateFrom: clearDateRange ? null : (dateFrom ?? this.dateFrom),
    dateTo: clearDateRange ? null : (dateTo ?? this.dateTo),
  );
}
