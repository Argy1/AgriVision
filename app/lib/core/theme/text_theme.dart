import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_tokens.dart';

/// Fraunces untuk display/heading (600), IBM Plex Sans untuk body/UI
/// (400/500/600) -- sama persis dengan web (`globals.css` @theme block).
abstract final class AppTextTheme {
  static TextStyle fraunces({
    required double fontSize,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
  }) => GoogleFonts.fraunces(
    fontSize: fontSize,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle plexSans({
    required double fontSize,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
  }) => GoogleFonts.ibmPlexSans(
    fontSize: fontSize,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextTheme build() {
    final base = GoogleFonts.ibmPlexSansTextTheme();
    return base
        .copyWith(
          displaySmall: fraunces(fontSize: 27, color: AppColors.panelHeadline),
          headlineMedium: fraunces(fontSize: 22),
          headlineSmall: fraunces(fontSize: 20),
          titleLarge: fraunces(fontSize: 19),
          titleMedium: plexSans(fontSize: 15.5, weight: FontWeight.w600),
          titleSmall: plexSans(fontSize: 13.5, weight: FontWeight.w600),
          bodyLarge: plexSans(fontSize: 14),
          bodyMedium: plexSans(fontSize: 13),
          bodySmall: plexSans(fontSize: 12.5, color: AppColors.sage),
          labelLarge: plexSans(fontSize: 14.5, weight: FontWeight.w600),
          labelMedium: plexSans(fontSize: 12.5, weight: FontWeight.w500),
          labelSmall: plexSans(fontSize: 10.5, color: AppColors.navInactive),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
  }
}
