import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification.dart';
import '../models/zone.dart';

/// Notifikasi in-app dihitung ULANG setiap layar dibuka (bukan disimpan,
/// bukan push) -- memberi fungsi nyata ke ikon lonceng dashboard yang di
/// mockup cuma dekoratif, tanpa infra push baru.
class NotificationsRepository {
  NotificationsRepository(this._client);

  final SupabaseClient _client;

  Future<List<AppNotification>> getComputedNotifications(String ownerId) async {
    final zonesRows = await _client.from('zones').select('*').eq('owner_id', ownerId);
    final zones = {
      for (final r in zonesRows as List) (r as Map<String, dynamic>)['id'] as String: Zone.fromJson(r),
    };
    if (zones.isEmpty) return const [];

    final zoneIds = zones.keys.toList();
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));

    final results = await Future.wait([
      _client
          .from('zone_health_daily')
          .select('*')
          .inFilter('zone_id', zoneIds)
          .eq('status', 'perlu_tindakan')
          .order('date', ascending: false),
      _client
          .from('diagnoses')
          .select('id, disease_name, created_at, uploads!inner(zone_id)')
          .inFilter('uploads.zone_id', zoneIds)
          .eq('severity', 'parah')
          .gte('created_at', sevenDaysAgo.toIso8601String())
          .order('created_at', ascending: false),
    ]);

    final notifications = <AppNotification>[];
    final seenZonesForStatus = <String>{};

    for (final row in results[0] as List) {
      final map = row as Map<String, dynamic>;
      final zoneId = map['zone_id'] as String;
      if (!seenZonesForStatus.add(zoneId)) continue; // satu notif per zona
      final zone = zones[zoneId];
      if (zone == null) continue;
      notifications.add(
        AppNotification(
          type: NotificationType.zoneNeedsAttention,
          title: 'Zona ${zone.name} perlu perhatian',
          message: 'Skor kesehatan zona ini menunjukkan status perlu tindakan.',
          createdAt: DateTime.parse(map['date'] as String),
          zoneId: zoneId,
        ),
      );
    }

    for (final row in results[1] as List) {
      final map = row as Map<String, dynamic>;
      final upload = map['uploads'] as Map<String, dynamic>;
      final zoneId = upload['zone_id'] as String;
      final zone = zones[zoneId];
      if (zone == null) continue;
      notifications.add(
        AppNotification(
          type: NotificationType.severeDiagnosis,
          title: '${map['disease_name']} terdeteksi parah',
          message: 'Di zona ${zone.name} -- segera tindak lanjuti.',
          createdAt: DateTime.parse(map['created_at'] as String),
          zoneId: zoneId,
          diagnosisId: map['id'] as String,
        ),
      );
    }

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }
}
