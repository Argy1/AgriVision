import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import '../../data/models/enums.dart';

/// Bar 3-segmen (Ringan/Sedang/Parah) -- terisi sampai level severity saat
/// ini, sisanya abu-abu inaktif. Persis pola mockup 7.
class SeverityMeterBar extends StatelessWidget {
  const SeverityMeterBar({super.key, required this.severity});
  final SeverityLevel severity;

  int get _filledSegments => switch (severity) {
    SeverityLevel.ringan => 1,
    SeverityLevel.sedang => 2,
    SeverityLevel.parah => 3,
  };

  Color get _fillColor => switch (severity) {
    SeverityLevel.ringan => AppColors.moss,
    SeverityLevel.sedang => AppColors.ochre,
    SeverityLevel.parah => AppColors.rust,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ringan', style: TextStyle(fontSize: 11, color: AppColors.sage)),
            Text('Sedang', style: TextStyle(fontSize: 11, color: AppColors.sage)),
            Text('Parah', style: TextStyle(fontSize: 11, color: AppColors.sage)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(3, (i) {
            final filled = i < _filledSegments;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                height: 7,
                decoration: BoxDecoration(
                  color: filled ? _fillColor : AppColors.severityMeterInactive,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
