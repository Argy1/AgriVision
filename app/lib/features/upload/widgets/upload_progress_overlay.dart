import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../providers/upload_flow_controller.dart';
import '../../../shared/widgets/icons.dart';

/// Menampilkan pesan SESUAI step yang gagal + tombol "Coba Lagi" yang selalu
/// retry-from-failed-step (bukan restart-from-scratch) -- lihat
/// `providers/upload_flow_controller.dart`.
class UploadProgressOverlay extends StatelessWidget {
  const UploadProgressOverlay({super.key, required this.state, required this.onRetry, required this.onCancel});

  final UploadFlowState state;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    switch (state) {
      case UploadFlowInProgress(:final step, :final checkingIdempotency):
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.moss),
            ),
            const SizedBox(height: 16),
            Text(
              checkingIdempotency ? 'Memeriksa status sebelumnya…' : step.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ],
        );
      case UploadFlowWaitingForConnection():
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.wifiOff, size: 32, color: AppColors.ochre),
            const SizedBox(height: 16),
            const Text(
              'Menunggu koneksi…',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Akan dilanjutkan otomatis saat koneksi kembali.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.sage),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onCancel, child: const Text('Batalkan')),
          ],
        );
      case UploadFlowFailed(:final step, :final error):
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.errorIcon, size: 32, color: AppColors.rust),
            const SizedBox(height: 16),
            Text(
              step.failureMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.sage),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: onCancel, child: const Text('Batalkan')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
              ],
            ),
          ],
        );
      case UploadFlowIdle():
      case UploadFlowSuccess():
        return const SizedBox.shrink();
    }
  }
}
