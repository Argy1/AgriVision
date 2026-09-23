import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/profile.dart';
import 'repository_providers.dart';

/// Sumber kebenaran tunggal status auth -- dibaca oleh auth guard di
/// `routing/app_router.dart`.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  // Ikut berubah tiap authState berubah (login/logout) supaya profil
  // ter-refresh otomatis.
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).getCurrentProfile();
});
