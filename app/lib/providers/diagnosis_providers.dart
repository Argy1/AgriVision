import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/diagnosis_detail.dart';
import 'repository_providers.dart';

final diagnosisDetailProvider = FutureProvider.family<DiagnosisDetail, String>((ref, diagnosisId) {
  return ref.watch(diagnosisRepositoryProvider).getDiagnosisDetail(diagnosisId);
});
