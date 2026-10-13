import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.sage).copyWith(
      primary: AppColors.sage,
      onPrimary: Colors.white,
      secondary: AppColors.mint,
      onSecondary: AppColors.ink,
      tertiary: AppColors.pale,
      onTertiary: AppColors.ink,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pale,
        foregroundColor: AppColors.ink,
        // Keep the same colour when content scrolls under the bar,
        // only add a soft shadow.
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 3,
        shadowColor: Colors.black26,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: Colors.white,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sage,
      ),
    );
  }
}
