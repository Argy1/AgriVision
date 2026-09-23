import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/errors/app_exception.dart';
import '../models/diagnosis_result.dart';

/// Klien HTTP untuk ml-service (FastAPI di Railway). Interceptor memasang
/// `Authorization: Bearer <access_token>` dari sesi Supabase yang SEDANG aktif
/// setiap kali dipanggil -- bukan token yang di-cache dari awal alur upload,
/// supaya tetap valid walau sesi sempat refresh di tengah proses.
class MlServiceClient {
  MlServiceClient(this._supabase) : _dio = Dio(BaseOptions(
    baseUrl: Env.mlApiUrl,
    connectTimeout: const Duration(seconds: 20),
    // Inferensi model bisa perlu waktu lebih lama dari request biasa.
    receiveTimeout: const Duration(seconds: 60),
  )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _supabase.auth.currentSession?.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final SupabaseClient _supabase;
  final Dio _dio;

  Future<DiagnosisResultData> diagnose({
    required String uploadId,
    required String imagePath,
    required String cropType,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/diagnose',
        data: {
          'upload_id': uploadId,
          'image_path': imagePath,
          'crop_type': cropType,
        },
      );
      return DiagnosisResultData.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final status = e.response?.statusCode;
    if (status == null) {
      return const NetworkException();
    }
    final detail = (e.response?.data is Map)
        ? (e.response!.data['detail'] as String? ?? 'Terjadi kesalahan pada server.')
        : 'Terjadi kesalahan pada server.';
    return ApiException(status, detail);
  }
}
