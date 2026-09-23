import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagnosis_list_item.dart';
import '../models/history_filter.dart';

class HistoryPage {
  const HistoryPage({required this.items, required this.hasMore});
  final List<DiagnosisListItem> items;
  final bool hasMore;
}

class HistoryRepository {
  HistoryRepository(this._client);

  final SupabaseClient _client;

  static const int pageSize = 20;

  static const _joinSelect =
      'id, disease_label, disease_name, severity, confidence, created_at, '
      'uploads!inner(zone_id, zones!inner(id, name, crop_type))';

  /// Pagination "ambil pageSize+1, potong" -- menghindari kebutuhan header
  /// `Prefer: count=exact` PostgREST (tidak diekspos lewat API count/select
  /// gabungan di postgrest-dart v2 versi ini), cukup untuk UI infinite-scroll.
  Future<HistoryPage> getDiagnoses({
    required HistoryFilter filter,
    required int page,
  }) async {
    var query = _client.from('diagnoses').select(_joinSelect);

    if (filter.zoneId != null) {
      query = query.eq('uploads.zone_id', filter.zoneId as Object);
    }
    if (filter.cropType != null) {
      query = query.eq('uploads.zones.crop_type', filter.cropType!.toJson());
    }
    if (filter.severity != null) {
      query = query.eq('severity', filter.severity!.toJson());
    }
    if (filter.dateFrom != null) {
      query = query.gte('created_at', filter.dateFrom!.toUtc().toIso8601String());
    }
    if (filter.dateTo != null) {
      query = query.lte('created_at', filter.dateTo!.toUtc().toIso8601String());
    }

    final from = page * pageSize;
    final to = from + pageSize; // +1 ekstra untuk deteksi hasMore

    final rows = await query.order('created_at', ascending: false).range(from, to);
    final hasMore = (rows as List).length > pageSize;
    final trimmed = hasMore ? rows.sublist(0, pageSize) : rows;

    final items = trimmed.map(DiagnosisListItem.fromJoinedJson).toList();

    return HistoryPage(items: items, hasMore: hasMore);
  }

  Future<List<DiagnosisListItem>> getRecentForZone(String zoneId, {int limit = 20}) async {
    final rows = await _client
        .from('diagnoses')
        .select(_joinSelect)
        .eq('uploads.zone_id', zoneId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => DiagnosisListItem.fromJoinedJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiagnosisListItem>> getRecentActivity({int limit = 5}) async {
    final rows = await _client
        .from('diagnoses')
        .select(_joinSelect)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => DiagnosisListItem.fromJoinedJson(r as Map<String, dynamic>))
        .toList();
  }
}
