import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/theme/AppPalette.dart';

class AppTheme {
  AppTheme._();

  /// Theme built from the active palette ([AppColors.palette]).
  static ThemeData get light => fromPalette(AppColors.palette);

  static ThemeData fromPalette(AppPalette p) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: p.brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.secondary,
      onSecondary: p.ink,
      tertiary: p.tertiary,
      onTertiary: p.ink,
      surface: p.background,
      onSurface: p.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.tertiary,
        foregroundColor: p.ink,
        // Keep the same colour when content scrolls under the bar,
        // only add a soft shadow.
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 3,
        shadowColor: Colors.black26,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: p.muted,
        // Material 3 caps bottom sheets at 640px wide; stretch to full width.
        constraints: const BoxConstraints(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
