import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagnosis_list_item.dart';
import '../models/disease_frequency_entry.dart';
import '../models/enums.dart';
import '../models/zone.dart';
import '../models/zone_detail_data.dart';
import '../models/zone_health_daily.dart';

/// RLS `zones_insert` butuh `owner_id = auth.uid()`, tidak dibatasi role --
/// petani BOLEH bikin zona sendiri. Tidak ada operasi hapus/edit di luar
/// nama (menjaga histori diagnosis tetap utuh, sama seperti batasan di web).
class ZonesRepository {
  ZonesRepository(this._client);

  final SupabaseClient _client;

  Future<List<Zone>> getOwnZones() async {
    final rows = await _client.from('zones').select('*').order('name');
    return (rows as List).map((r) => Zone.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Zone?> getZone(String zoneId) async {
    final row = await _client.from('zones').select('*').eq('id', zoneId).maybeSingle();
    return row == null ? null : Zone.fromJson(row);
  }

  Future<Zone> createZone({
    required String name,
    required CropType cropType,
    String? locationNote,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final zone = Zone(
      id: '',
      name: name,
      cropType: cropType,
      ownerId: userId,
      locationNote: locationNote,
      createdAt: DateTime.now(),
    );
    final row = await _client.from('zones').insert(zone.toInsertJson()).select().single();
    return Zone.fromJson(row);
  }

  /// Drill-down satu zona -- memaksimalkan Modul 2 (monitoring): tren
  /// histori PENUH (bukan dibatasi 30 hari seperti dashboard), breakdown
  /// frekuensi penyakit, dan histori diagnosis zona itu.
  Future<ZoneDetailData> getZoneDetail(String zoneId) async {
    final results = await Future.wait([
      _client.from('zones').select('*').eq('id', zoneId).single(),
      _client.from('zone_health_daily').select('*').eq('zone_id', zoneId).order('date'),
      _client
          .from('diagnoses')
          .select('disease_name, uploads!inner(zone_id)')
          .eq('uploads.zone_id', zoneId),
      _client
          .from('diagnoses')
          .select(
            'id, disease_label, disease_name, severity, confidence, created_at, '
            'uploads!inner(zone_id, zones!inner(id, name, crop_type))',
          )
          .eq('uploads.zone_id', zoneId)
          .order('created_at', ascending: false)
          .limit(10),
    ]);

    final zone = Zone.fromJson(results[0] as Map<String, dynamic>);
    final healthHistory = (results[1] as List)
        .map((r) => ZoneHealthDaily.fromJson(r as Map<String, dynamic>))
        .toList();

    final frequencyCounts = <String, int>{};
    for (final row in results[2] as List) {
      final name = (row as Map<String, dynamic>)['disease_name'] as String;
      frequencyCounts[name] = (frequencyCounts[name] ?? 0) + 1;
    }
    final diseaseFrequency = frequencyCounts.entries
        .map((e) => DiseaseFrequencyEntry(diseaseName: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final recentDiagnoses = (results[3] as List)
        .map((r) => DiagnosisListItem.fromJoinedJson(r as Map<String, dynamic>))
        .toList();

    return ZoneDetailData(
      zone: zone,
      healthHistory: healthHistory,
      diseaseFrequency: diseaseFrequency,
      recentDiagnoses: recentDiagnoses,
    );
  }
}
