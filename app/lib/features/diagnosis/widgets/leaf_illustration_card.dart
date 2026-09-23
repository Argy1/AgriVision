import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/card_container.dart';

/// scale = sqrt(max(pct, 0.1) / 35), clamp [0.4, 1.6] -- persis
/// `LeafIllustration.tsx`, dikalibrasi dari satu-satunya titik data di
/// mockup (35% -> skala 1.0). Diekstrak sebagai fungsi murni supaya bisa
/// diuji unit test tanpa merender widget.
double leafBlobScale(double affectedAreaPct) {
  final raw = math.sqrt(math.max(affectedAreaPct, 0.1) / 35);
  return raw.clamp(0.4, 1.6);
}

/// Port CustomPainter PERSIS dari `web/components/leaf-illustration/LeafIllustration.tsx`.
/// Path daun & blob, formula skala, dan anchor disalin literal -- lihat
/// komentar di sumber aslinya untuk penjelasan judgment call (blob fill
/// SELALU rust, outline blob ikut severity, anchor di pusat massa blob).
class LeafIllustrationCard extends StatelessWidget {
  const LeafIllustrationCard({
    super.key,
    required this.severity,
    required this.affectedAreaPct,
  });

  final SeverityLevel severity;
  final double affectedAreaPct;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      radius: CardRadius.large,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 168,
        height: 168,
        child: Center(
          child: SizedBox(
            width: 140,
            height: 154,
            child: CustomPaint(
              painter: _LeafPainter(severity: severity, affectedAreaPct: affectedAreaPct),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  _LeafPainter({required this.severity, required this.affectedAreaPct});

  final SeverityLevel severity;
  final double affectedAreaPct;

  // viewBox asli 200x220 -- semua koordinat path di bawah dalam ruang ini.
  static const _viewBoxSize = Size(200, 220);
  static const _blobAnchor = Offset(121, 140);

  Color get _outlineColor => switch (severity) {
    SeverityLevel.ringan => AppColors.moss,
    SeverityLevel.sedang => AppColors.ochre,
    SeverityLevel.parah => AppColors.rust,
  };

  Path _leafPath() {
    // M100 8 C46 26 14 84 14 146 C14 188 52 214 100 214 C148 214 186 188 186 146 C186 84 154 26 100 8 Z
    return Path()
      ..moveTo(100, 8)
      ..cubicTo(46, 26, 14, 84, 14, 146)
      ..cubicTo(14, 188, 52, 214, 100, 214)
      ..cubicTo(148, 214, 186, 188, 186, 146)
      ..cubicTo(186, 84, 154, 26, 100, 8)
      ..close();
  }

  Path _blobPath() {
    // M118 108 C142 100 158 120 150 146 C143 170 112 180 96 164 C84 152 88 126 106 114 C110 111 114 109 118 108 Z
    return Path()
      ..moveTo(118, 108)
      ..cubicTo(142, 100, 158, 120, 150, 146)
      ..cubicTo(143, 170, 112, 180, 96, 164)
      ..cubicTo(84, 152, 88, 126, 106, 114)
      ..cubicTo(110, 111, 114, 109, 118, 108)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _viewBoxSize.width;
    final scaleY = size.height / _viewBoxSize.height;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Daun.
    final leafFillPaint = Paint()
      ..color = AppColors.leafFill
      ..style = PaintingStyle.fill;
    final leafStrokePaint = Paint()
      ..color = AppColors.leafStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final leafPath = _leafPath();
    canvas.drawPath(leafPath, leafFillPaint);
    canvas.drawPath(leafPath, leafStrokePaint);

    // Urat tengah.
    final veinPaint = Paint()
      ..color = AppColors.leafStroke.withValues(alpha: 0.5)
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(100, 20), const Offset(100, 206), veinPaint);

    // Urat cabang.
    final sideVeinPaint = Paint()
      ..color = AppColors.leafStroke.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    for (final pair in const [
      [Offset(100, 60), Offset(60, 90)],
      [Offset(100, 60), Offset(140, 90)],
      [Offset(100, 100), Offset(54, 128)],
      [Offset(100, 100), Offset(146, 128)],
      [Offset(100, 145), Offset(62, 170)],
      [Offset(100, 145), Offset(138, 170)],
    ]) {
      canvas.drawLine(pair[0], pair[1], sideVeinPaint);
    }

    // Blob lesi -- scale = sqrt(max(pct, 0.1) / 35), clamp [0.4, 1.6].
    // Hanya render jika affectedAreaPct > 0.5.
    if (affectedAreaPct > 0.5) {
      final scale = leafBlobScale(affectedAreaPct);
      canvas.save();
      canvas.translate(_blobAnchor.dx, _blobAnchor.dy);
      canvas.scale(scale);
      canvas.translate(-_blobAnchor.dx, -_blobAnchor.dy);

      final blobPath = _blobPath();
      final blobFillPaint = Paint()
        ..color = AppColors.rust.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      final blobOutlinePaint = Paint()
        ..color = _outlineColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawPath(blobPath, blobFillPaint);
      canvas.drawPath(blobPath, blobOutlinePaint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.severity != severity || oldDelegate.affectedAreaPct != affectedAreaPct;
}
