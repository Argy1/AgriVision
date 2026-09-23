import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import '../../providers/notifications_providers.dart';
import '../../routing/route_paths.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.canPop() ? context.pop() : context.go(RoutePaths.beranda),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(AppIcons.back, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Notifikasi', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorStateView(
                  message: 'Gagal memuat notifikasi: $e',
                  onRetry: () => ref.invalidate(notificationsProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(message: 'Tidak ada notifikasi baru.', icon: AppIcons.bell);
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(notificationsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => NotificationTile(notification: items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
