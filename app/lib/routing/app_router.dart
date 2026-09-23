import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_request_screen.dart';
import '../features/auth/forgot_password_verify_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/diagnosis/diagnosis_result_screen.dart';
import '../features/disease_guide/disease_guide_screen.dart';
import '../features/history/history_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/upload/upload_screen.dart';
import '../features/zone_detail/zone_detail_screen.dart';
import '../providers/auth_providers.dart';
import '../shared/widgets/app_shell.dart';
import 'route_paths.dart';

/// Menjembatani stream auth state Riverpod ke `Listenable` yang dibutuhkan
/// go_router's `refreshListenable` -- go_router sendiri tidak Riverpod-aware.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: RoutePaths.beranda,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.value?.session != null;
      final path = state.matchedLocation;

      const publicPaths = {
        RoutePaths.login,
        RoutePaths.forgotPassword,
        RoutePaths.verifyCode,
      };
      final isPublicPath = publicPaths.contains(path);

      if (!isLoggedIn && !isPublicPath) return RoutePaths.login;
      if (isLoggedIn && isPublicPath) return RoutePaths.beranda;
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (_, _) => const ForgotPasswordRequestScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyCode,
        builder: (_, state) => ForgotPasswordVerifyScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: RoutePaths.beranda, builder: (_, _) => const DashboardScreen()),
          GoRoute(
            path: RoutePaths.unggah,
            builder: (_, state) => UploadScreen(
              preselectZoneId: state.uri.queryParameters['zone'],
            ),
          ),
          GoRoute(
            path: RoutePaths.riwayat,
            builder: (_, state) => HistoryScreen(
              preselectZoneId: state.uri.queryParameters['zone'],
            ),
          ),
          GoRoute(path: RoutePaths.profil, builder: (_, _) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: RoutePaths.diagnosisResult,
        builder: (_, state) => DiagnosisResultScreen(diagnosisId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.zonaDetail,
        builder: (_, state) => ZoneDetailScreen(zoneId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.panduanPenyakit,
        builder: (_, _) => const DiseaseGuideScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifikasi,
        builder: (_, _) => const NotificationsScreen(),
      ),
    ],
  );
});
