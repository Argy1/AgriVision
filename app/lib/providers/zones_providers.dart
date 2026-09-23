import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/models/enums.dart';
import '../data/models/zone.dart';
import '../data/models/zone_detail_data.dart';
import 'repository_providers.dart';

class ZonesNotifier extends AsyncNotifier<List<Zone>> {
  @override
  Future<List<Zone>> build() {
    return ref.watch(zonesRepositoryProvider).getOwnZones();
  }

  Future<Zone> createZone({
    required String name,
    required CropType cropType,
    String? locationNote,
  }) async {
    final repo = ref.read(zonesRepositoryProvider);
    final zone = await repo.createZone(
      name: name,
      cropType: cropType,
      locationNote: locationNote,
    );
    state = AsyncData([...(state.value ?? []), zone]);
    return zone;
  }
}

final zonesProvider = AsyncNotifierProvider<ZonesNotifier, List<Zone>>(ZonesNotifier.new);

/// Zona yang sedang dipilih di layar Unggah Foto -- default ke zona pertama
/// begitu daftar zona berhasil dimuat (lihat listener di layar Unggah).
final selectedZoneIdProvider = StateProvider<String?>((ref) => null);

final zoneDetailProvider = FutureProvider.family<ZoneDetailData, String>((ref, zoneId) {
  return ref.watch(zonesRepositoryProvider).getZoneDetail(zoneId);
});
