import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/theme/AppPalette.dart';

class AppTheme {
  AppTheme._();

  /// Theme built from the active palette ([AppColors.palette]).
  static ThemeData get light => fromPalette(AppColors.palette);

  static ThemeData fromPalette(AppPalette p) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: p.brightness,
        ).copyWith(
          primary: p.primary,
          onPrimary: p.onPrimary,
          secondary: p.secondary,
          secondaryContainer: p.secondary,
          onSecondaryContainer: p.primary,
          onSecondary: p.ink,
          tertiary: p.tertiary,
          onTertiary: p.ink,
          surface: p.background,
          onSurface: p.ink,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      splashFactory: InkRipple.splashFactory,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      dividerColor: AppColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F6F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: p.secondary,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.ink : p.primary,
            size: 23,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? p.ink : p.muted,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
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
