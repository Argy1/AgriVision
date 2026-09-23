import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/disease_reference.dart';

/// Browse seluruh knowledge base `disease_reference` -- fitur baru yang
/// memaksimalkan data yang sudah lengkap tapi belum pernah bisa di-browse di
/// platform manapun (web maupun app). Hanya 16 baris, jadi diambil sekaligus
/// dan difilter per-crop di client (tidak perlu re-query per tab).
class DiseaseReferenceRepository {
  DiseaseReferenceRepository(this._client);

  final SupabaseClient _client;

  Future<List<DiseaseReference>> getAll() async {
    final rows = await _client.from('disease_reference').select('*').order('disease_name');
    return (rows as List)
        .map((r) => DiseaseReference.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
