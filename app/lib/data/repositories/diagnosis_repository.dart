import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagnosis.dart';
import '../models/diagnosis_detail.dart';
import '../models/diagnosis_list_item.dart';
import '../models/diagnosis_result.dart';
import '../models/recommendation.dart';
import '../models/vegetation_index_reading.dart';
import '../models/zone.dart';
import '../sources/ml_service_client.dart';

/// Bagian paling rawan gagal di seluruh app -- cermin
/// `web/components/upload/Dropzone.tsx`. `upload_id` UNIQUE-constrained di
/// `diagnoses`, jadi idempotency check WAJIB dijalankan sebelum retry
/// manapun ke ml-service, kalau tidak akan memicu 500 duplikat.
class DiagnosisRepository {
  DiagnosisRepository(this._client, this._mlService);

  final SupabaseClient _client;
  final MlServiceClient _mlService;

  Future<String?> findExistingDiagnosisId(String uploadId) async {
    final row = await _client
        .from('diagnoses')
        .select('id')
        .eq('upload_id', uploadId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  Future<DiagnosisResultData> requestDiagnosis({
    required String uploadId,
    required String imagePath,
    required String cropType,
  }) => _mlService.diagnose(uploadId: uploadId, imagePath: imagePath, cropType: cropType);

  Future<DiagnosisDetail> getDiagnosisDetail(String diagnosisId) async {
    final diagnosisRow = await _client
        .from('diagnoses')
        .select('*, uploads!inner(id, zone_id, zones!inner(id, name, crop_type, owner_id, location_note, created_at))')
        .eq('id', diagnosisId)
        .single();

    final diagnosis = Diagnosis.fromJson(diagnosisRow);
    final uploadJson = diagnosisRow['uploads'] as Map<String, dynamic>;
    final zoneJson = uploadJson['zones'] as Map<String, dynamic>;
    final zone = Zone.fromJson(zoneJson);

    final results = await Future.wait([
      _client.from('recommendations').select('*').eq('diagnosis_id', diagnosisId).maybeSingle(),
      _client
          .from('vegetation_index_readings')
          .select('*')
          .eq('upload_id', diagnosis.uploadId)
          .maybeSingle(),
      _client
          .from('diagnoses')
          .select('id, disease_label, disease_name, severity, confidence, created_at, uploads!inner(zones!inner(id, name, crop_type))')
          .eq('uploads.zone_id', zone.id)
          .order('created_at', ascending: false)
          .limit(5),
      _client
          .from('diagnoses')
          .select('created_at, uploads!inner(zone_id)')
          .eq('disease_label', diagnosis.diseaseLabel)
          .eq('uploads.zone_id', zone.id)
          .order('created_at', ascending: true)
          .limit(1),
    ]);

    final recommendationRow = results[0] as Map<String, dynamic>?;
    final vegIndexRow = results[1] as Map<String, dynamic>?;
    final recentRows = results[2] as List;
    final firstOccurrenceRows = results[3] as List;

    final recommendation = recommendationRow != null
        ? Recommendation.fromJson(recommendationRow)
        : const Recommendation(id: '', diagnosisId: '', recommendationText: '');

    final vegetationIndex =
        vegIndexRow != null ? VegetationIndexReading.fromJson(vegIndexRow) : null;

    final recentHistory = recentRows
        .map((r) => DiagnosisListItem.fromJoinedJson(r as Map<String, dynamic>))
        .toList();

    int? daysSinceFirst;
    if (firstOccurrenceRows.isNotEmpty) {
      final firstDate = DateTime.parse(
        (firstOccurrenceRows.first as Map<String, dynamic>)['created_at'] as String,
      );
      daysSinceFirst = DateTime.now().toUtc().difference(firstDate).inDays;
    }

    return DiagnosisDetail(
      diagnosis: diagnosis,
      recommendation: recommendation,
      vegetationIndex: vegetationIndex,
      zone: zone,
      daysSinceFirstOccurrence: daysSinceFirst,
      recentHistory: recentHistory,
    );
  }
}
