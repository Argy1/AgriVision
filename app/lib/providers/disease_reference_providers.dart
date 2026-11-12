import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/disease_reference.dart';
import 'repository_providers.dart';

final diseaseReferenceProvider = FutureProvider<List<DiseaseReference>>((ref) {
  return ref.watch(diseaseReferenceRepositoryProvider).getAll();
});
