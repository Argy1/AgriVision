import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/diagnosis_repository.dart';
import '../data/repositories/disease_reference_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/notifications_repository.dart';
import '../data/repositories/uploads_repository.dart';
import '../data/repositories/zones_repository.dart';
import '../data/sources/ml_service_client.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final mlServiceClientProvider = Provider<MlServiceClient>((ref) {
  return MlServiceClient(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final zonesRepositoryProvider = Provider<ZonesRepository>((ref) {
  return ZonesRepository(ref.watch(supabaseClientProvider));
});

final uploadsRepositoryProvider = Provider<UploadsRepository>((ref) {
  return UploadsRepository(ref.watch(supabaseClientProvider));
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return DiagnosisRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(mlServiceClientProvider),
  );
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(supabaseClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(supabaseClientProvider));
});

final diseaseReferenceRepositoryProvider = Provider<DiseaseReferenceRepository>((ref) {
  return DiseaseReferenceRepository(ref.watch(supabaseClientProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(supabaseClientProvider));
});
