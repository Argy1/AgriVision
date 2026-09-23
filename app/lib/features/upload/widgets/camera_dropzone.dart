import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../shared/widgets/icons.dart';

/// Dropzone kamera 300px dengan border dashed + 4 bracket viewfinder --
/// persis `6-app-upload-foto.html`. Bracket sengaja dekoratif (bukan live
/// preview kamera kustom, cukup `image_picker`).
class CameraDropzone extends StatelessWidget {
  const CameraDropzone({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.dropzoneBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _DashedBorderPainter()),
            ),
            const _CornerBracket(alignment: Alignment.topLeft),
            const _CornerBracket(alignment: Alignment.topRight),
            const _CornerBracket(alignment: Alignment.bottomLeft),
            const _CornerBracket(alignment: Alignment.bottomRight),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(color: AppColors.mossTint, shape: BoxShape.circle),
                    child: const Icon(AppIcons.camera, size: 26, color: AppColors.moss),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Ketuk untuk ambil foto',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CustomPaint(
            painter: _BracketPainter(isTop: isTop, isLeft: isLeft),
          ),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({required this.isTop, required this.isLeft});
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.viewfinderBracket
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final vX = isLeft ? 0.0 : size.width;
    final hY = isTop ? 0.0 : size.height;
    path.moveTo(vX, isTop ? size.height : 0);
    path.lineTo(vX, hY);
    path.lineTo(isLeft ? size.width : 0, hY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.dropzoneBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
