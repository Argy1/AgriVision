enum NotificationType { zoneNeedsAttention, severeDiagnosis }

/// Notifikasi dihitung on-open dari data yang sudah ada (zone_health_daily +
/// diagnoses parah) -- BUKAN push notification, tidak ada infra baru.
class AppNotification {
  const AppNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.zoneId,
    this.diagnosisId,
  });

  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final String zoneId;
  final String? diagnosisId;
}
