import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/errors/app_exception.dart';
import 'connectivity_provider.dart';
import 'repository_providers.dart';

/// Urutan alur upload -- cermin `web/components/upload/Dropzone.tsx` PERSIS.
/// `requestingDiagnosis` SELALU didahului pengecekan idempotensi
/// (`diagnoses.upload_id` unique-constrained, re-POST ke ml-service yang
/// sudah pernah sukses akan 500) -- baik ini percobaan pertama maupun retry.
enum UploadStep { validatingFile, uploadingToStorage, insertingUploadRow, requestingDiagnosis }

sealed class UploadFlowState {
  const UploadFlowState();
}

class UploadFlowIdle extends UploadFlowState {
  const UploadFlowIdle();
}

class UploadFlowInProgress extends UploadFlowState {
  const UploadFlowInProgress(this.step, {this.checkingIdempotency = false});
  final UploadStep step;
  final bool checkingIdempotency;
}

class UploadFlowWaitingForConnection extends UploadFlowState {
  const UploadFlowWaitingForConnection(this.step);
  final UploadStep step;
}

class UploadFlowFailed extends UploadFlowState {
  const UploadFlowFailed(this.step, this.error);
  final UploadStep step;
  final AppException error;
}

class UploadFlowSuccess extends UploadFlowState {
  const UploadFlowSuccess(this.diagnosisId);
  final String diagnosisId;
}

class UploadFlowController extends Notifier<UploadFlowState> {
  @override
  UploadFlowState build() {
    // Auto-retry saat koneksi kembali -- satu-satunya "kepintaran" retry yang
    // dibangun untuk MVP (bukan offline queue penuh, lihat catatan Phase 2
    // di rencana implementasi).
    ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityProvider, (previous, next) {
      final current = state;
      final results = next.value;
      if (current is UploadFlowWaitingForConnection && results != null && isOnline(results)) {
        _runFrom(current.step);
      }
    });
    return const UploadFlowIdle();
  }

  Uint8List? _bytes;
  String? _contentType;
  String? _ext;
  String? _zoneId;
  String? _cropType;
  String? _imagePath;
  String? _uploadId;

  void reset() {
    _bytes = null;
    _imagePath = null;
    _uploadId = null;
    state = const UploadFlowIdle();
  }

  Future<void> startUpload({
    required Uint8List bytes,
    required String contentType,
    required String ext,
    required String zoneId,
    required String cropType,
  }) async {
    _bytes = bytes;
    _contentType = contentType;
    _ext = ext;
    _zoneId = zoneId;
    _cropType = cropType;
    _imagePath = null;
    _uploadId = null;
    await _runFrom(UploadStep.validatingFile);
  }

  /// Retry SELALU dari step yang gagal, TIDAK PERNAH restart-from-scratch --
  /// menghindari upload ulang foto yang sebenarnya sudah berhasil, dan
  /// menghindari 500 duplikat `upload_id`.
  Future<void> retry() async {
    final current = state;
    if (current is UploadFlowFailed) {
      await _runFrom(current.step);
    } else if (current is UploadFlowWaitingForConnection) {
      await _runFrom(current.step);
    }
  }

  void _validateFile() {
    if (_bytes == null) {
      throw const ValidationException('Tidak ada foto yang dipilih.');
    }
    if (_bytes!.lengthInBytes > 10 * 1024 * 1024) {
      throw const ValidationException('Ukuran foto maksimum 10MB.');
    }
    const allowed = {'jpg', 'jpeg', 'png'};
    if (!allowed.contains(_ext?.toLowerCase())) {
      throw const ValidationException('Format foto harus JPG atau PNG.');
    }
  }

  Future<void> _runFrom(UploadStep resumeFrom) async {
    var currentStep = resumeFrom;
    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      final uploadsRepo = ref.read(uploadsRepositoryProvider);
      final diagnosisRepo = ref.read(diagnosisRepositoryProvider);

      if (resumeFrom.index <= UploadStep.validatingFile.index) {
        currentStep = UploadStep.validatingFile;
        state = UploadFlowInProgress(currentStep);
        _validateFile();
      }

      if (resumeFrom.index <= UploadStep.uploadingToStorage.index) {
        currentStep = UploadStep.uploadingToStorage;
        state = UploadFlowInProgress(currentStep);
        _imagePath ??= uploadsRepo.buildImagePath(
          userId: userId,
          zoneId: _zoneId!,
          ext: _ext!,
        );
        final alreadyThere = await uploadsRepo.photoExists(_imagePath!);
        if (!alreadyThere) {
          await uploadsRepo.uploadPhoto(
            imagePath: _imagePath!,
            bytes: _bytes!,
            contentType: _contentType!,
          );
        }
      }

      if (resumeFrom.index <= UploadStep.insertingUploadRow.index) {
        currentStep = UploadStep.insertingUploadRow;
        state = UploadFlowInProgress(currentStep);
        if (_uploadId == null) {
          final existing = await uploadsRepo.findExistingUpload(_imagePath!);
          _uploadId = existing?.id ??
              (await uploadsRepo.insertUploadRow(
                zoneId: _zoneId!,
                uploadedBy: userId,
                imagePath: _imagePath!,
              ))
                  .id;
        }
      }

      // requestingDiagnosis: SELALU didahului cek idempotensi, apa pun titik
      // resume-nya (lihat dokumentasi enum di atas).
      currentStep = UploadStep.requestingDiagnosis;
      state = const UploadFlowInProgress(UploadStep.requestingDiagnosis, checkingIdempotency: true);
      var diagnosisId = await diagnosisRepo.findExistingDiagnosisId(_uploadId!);

      if (diagnosisId == null) {
        state = const UploadFlowInProgress(UploadStep.requestingDiagnosis);
        final result = await diagnosisRepo.requestDiagnosis(
          uploadId: _uploadId!,
          imagePath: _imagePath!,
          cropType: _cropType!,
        );
        diagnosisId = result.diagnosisId;
      }

      state = UploadFlowSuccess(diagnosisId);
    } on NetworkException {
      state = UploadFlowWaitingForConnection(currentStep);
    } on AppException catch (e) {
      state = UploadFlowFailed(currentStep, e);
    } catch (e) {
      state = UploadFlowFailed(currentStep, UnknownException(e.toString()));
    }
  }
}

final uploadFlowControllerProvider =
    NotifierProvider<UploadFlowController, UploadFlowState>(UploadFlowController.new);

extension UploadStepMessage on UploadStep {
  String get label => switch (this) {
    UploadStep.validatingFile => 'Memeriksa foto…',
    UploadStep.uploadingToStorage => 'Mengunggah foto…',
    UploadStep.insertingUploadRow => 'Menyimpan data unggahan…',
    UploadStep.requestingDiagnosis => 'Menjalankan diagnosis…',
  };

  String get failureMessage => switch (this) {
    UploadStep.validatingFile => 'Foto tidak valid.',
    UploadStep.uploadingToStorage => 'Gagal mengunggah foto -- periksa koneksi Anda.',
    UploadStep.insertingUploadRow => 'Gagal menyimpan data unggahan -- periksa koneksi Anda.',
    UploadStep.requestingDiagnosis => 'Gagal menjalankan diagnosis -- server mungkin sedang sibuk.',
  };
}
