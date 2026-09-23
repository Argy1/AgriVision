import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'text_theme.dart';

/// Radius kartu bertahap 8-16px sesuai elemen -- SENGAJA tidak disatukan jadi
/// satu radius global (lihat design-system.md).
enum CardRadius { small, medium, large }

extension CardRadiusValue on CardRadius {
  double get px => switch (this) {
    CardRadius.small => 9,
    CardRadius.medium => 12,
    CardRadius.large => 16,
  };
}

abstract final class AppTheme {
  static ThemeData build() {
    final textTheme = AppTextTheme.build();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.parchment,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.moss,
        primary: AppColors.moss,
        surface: AppColors.paper,
        error: AppColors.rust,
      ),
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.paper,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CardRadius.medium.px),
          side: const BorderSide(color: AppColors.borderAlt, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        hintStyle: AppTextTheme.plexSans(
          fontSize: 14,
          color: AppColors.inputPlaceholder,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.moss, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.rust),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.moss,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.moss.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextTheme.plexSans(
            fontSize: 14.5,
            weight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.moss,
          side: const BorderSide(color: AppColors.moss),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextTheme.plexSans(
            fontSize: 14,
            weight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.moss,
          textStyle: AppTextTheme.plexSans(
            fontSize: 12.5,
            weight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderAlt,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.paper,
        selectedItemColor: AppColors.moss,
        unselectedItemColor: AppColors.navInactive,
        selectedLabelStyle: AppTextTheme.plexSans(
          fontSize: 10.5,
          weight: FontWeight.w600,
          color: AppColors.moss,
        ),
        unselectedLabelStyle: AppTextTheme.plexSans(
          fontSize: 10.5,
          color: AppColors.navInactive,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
