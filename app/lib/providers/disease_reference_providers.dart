import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/models/disease_reference.dart';
import '../data/models/enums.dart';
import 'repository_providers.dart';

final diseaseReferenceProvider = FutureProvider<List<DiseaseReference>>((ref) {
  return ref.watch(diseaseReferenceRepositoryProvider).getAll();
});

/// Tab Tomat/Cabai di layar Panduan Penyakit -- filter client-side, tidak
/// perlu re-query (cuma 16 baris total).
final diseaseGuideCropFilterProvider = StateProvider<CropType>((ref) => CropType.tomat);
