import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import 'icons.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = AppIcons.emptyBox,
  });
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // SizedBox(width: infinity): tanpa ini Column mengecil sebesar teksnya lalu
    // menempel ke kiri induknya, sehingga ikon/teks tampak tidak di tengah.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.sage),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.sage),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // SizedBox(width: infinity): tanpa ini Column mengecil sebesar teksnya lalu
    // menempel ke kiri induknya, sehingga ikon/teks tampak tidak di tengah.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Icon(AppIcons.errorIcon, size: 32, color: AppColors.rust),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.rustText),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.moss,
          ),
        ),
      ),
    );
  }
}
