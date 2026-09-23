import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../models/upload_record.dart';

class UploadsRepository {
  UploadsRepository(this._client);

  final SupabaseClient _client;

  /// Path Storage: `{user_id}/{zone_id}/{timestamp}.{ext}` -- persis pola
  /// yang sudah dipakai web, generate SEKALI per aksi (dipertahankan di
  /// state upload flow, tidak dibuat ulang tiap retry -- lihat
  /// `providers/upload_flow_controller.dart`).
  String buildImagePath({
    required String userId,
    required String zoneId,
    required String ext,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$userId/$zoneId/$timestamp.$ext';
  }

  Future<void> uploadPhoto({
    required String imagePath,
    required Uint8List bytes,
    required String contentType,
  }) async {
    await _client.storage.from(Env.storageBucket).uploadBinary(
      imagePath,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );
  }

  /// Cek objek Storage sudah ada -- dipakai saat retry step upload supaya
  /// tidak mengunggah ulang foto yang sebenarnya sudah berhasil sebelum
  /// koneksi putus.
  Future<bool> photoExists(String imagePath) async {
    final slashIndex = imagePath.lastIndexOf('/');
    final folder = imagePath.substring(0, slashIndex);
    final filename = imagePath.substring(slashIndex + 1);
    final list = await _client.storage.from(Env.storageBucket).list(path: folder);
    return list.any((f) => f.name == filename);
  }

  Future<UploadRecord> insertUploadRow({
    required String zoneId,
    required String uploadedBy,
    required String imagePath,
  }) async {
    final row = await _client
        .from('uploads')
        .insert({
          'zone_id': zoneId,
          'uploaded_by': uploadedBy,
          'image_path': imagePath,
        })
        .select()
        .single();
    return UploadRecord.fromJson(row);
  }

  /// Cari row `uploads` yang sudah pernah dibuat untuk path ini -- dipakai
  /// saat retry step insert supaya tidak insert dobel kalau row sebenarnya
  /// sudah berhasil dibuat sebelum koneksi putus.
  Future<UploadRecord?> findExistingUpload(String imagePath) async {
    final row = await _client
        .from('uploads')
        .select('*')
        .eq('image_path', imagePath)
        .maybeSingle();
    return row == null ? null : UploadRecord.fromJson(row);
  }
}
