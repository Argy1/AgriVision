import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../shared/widgets/icons.dart';

/// Panel hero Moss 306px dengan watermark daun (opacity 0.14) -- persis
/// `5-app-login.html`.
class MossHeroPanel extends StatelessWidget {
  const MossHeroPanel({super.key, required this.headline});
  final String headline;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 306,
      width: double.infinity,
      color: AppColors.moss,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.14,
              child: Icon(AppIcons.leaf, size: 200, color: AppColors.panelHeadline),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.panelHeadline,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(AppIcons.leaf, size: 16, color: AppColors.ink),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AgriVision',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.panelHeadline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  headline,
                  style: GoogleFonts.fraunces(
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: AppColors.panelHeadline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
