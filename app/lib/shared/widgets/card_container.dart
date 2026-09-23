import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/color_tokens.dart';

/// Menegakkan aturan radius bertahap 8-16px + border 1px + padding mobile
/// yang lebih rapat (12-16px) -- satu tempat, bukan radius ad hoc tersebar
/// per layar.
class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    required this.child,
    this.radius = CardRadius.medium,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.paper,
    this.borderColor = AppColors.borderAlt,
  });

  final Widget child;
  final CardRadius radius;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius.px),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}
