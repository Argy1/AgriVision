import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import 'card_container.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.alert = false,
  });

  final String value;
  final String label;
  final IconData? icon;

  /// Varian rust-tinted untuk tile "perlu perhatian" -- sesuai mockup
  /// dashboard (satu-satunya tile 2x2 yang beda warna dari 3 lainnya).
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      color: alert ? AppColors.rustTintSoft : AppColors.paper,
      borderColor: alert ? AppColors.rustDivider : AppColors.borderAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: alert ? AppColors.rust : AppColors.moss),
          if (icon != null) const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: alert ? AppColors.rustText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.sage),
          ),
        ],
      ),
    );
  }
}

class StatTileGrid extends StatelessWidget {
  const StatTileGrid({super.key, required this.tiles});
  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: tiles,
    );
  }
}
