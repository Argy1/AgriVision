import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';

class AvatarInitialsChip extends StatelessWidget {
  const AvatarInitialsChip({super.key, required this.initials, this.size = 34});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.moss, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
