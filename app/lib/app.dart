import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_providers.dart';
import 'providers/dashboard_providers.dart';
import 'providers/history_providers.dart';
import 'providers/notifications_providers.dart';
import 'providers/upload_flow_controller.dart';
import 'providers/zones_providers.dart';
import 'routing/app_router.dart';

class AgriVisionApp extends ConsumerWidget {
  const AgriVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // Banyak orang bisa daftar/login di satu perangkat: begitu akun berganti
    // (login, daftar, atau logout), buang semua state yang tersimpan dari akun
    // sebelumnya supaya data zona/riwayat orang lain tidak sempat tampil.
    ref.listen(authStateProvider, (previous, next) {
      final prevId = previous?.value?.session?.user.id;
      final nextId = next.value?.session?.user.id;
      if (prevId == nextId) return;
      ref.invalidate(zonesProvider);
      ref.invalidate(selectedZoneIdProvider);
      ref.invalidate(historyListProvider);
      ref.invalidate(historyFilterProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(uploadFlowControllerProvider);
    });

    return MaterialApp.router(
      title: 'AgriVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: router,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
