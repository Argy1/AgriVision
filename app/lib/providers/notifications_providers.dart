import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_notification.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

/// Dihitung ulang tiap layar dibuka (computed-on-open) -- BUKAN cache
/// jangka panjang, sesuai desain "tanpa infra push".
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return const [];
  return ref.watch(notificationsRepositoryProvider).getComputedNotifications(profile.id);
});
