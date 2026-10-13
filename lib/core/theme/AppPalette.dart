import 'package:flutter/material.dart';

/// One colour set for the app. Field names describe the role, not the hue,
/// so every palette can be swapped in without touching the widgets.
class AppPalette {
  final String name;
  final Brightness brightness;

  // Colours taken straight from the palette
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;

  // Derived shades that need more contrast than the palette provides
  final Color onPrimary; // text/icons on top of [primary]
  final Color accent; // strong version of [primary] for icons and initials
  final Color ink; // main text
  final Color muted; // secondary text
  final Color salary;
  final Color card;

  const AppPalette({
    required this.name,
    this.brightness = Brightness.light,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.onPrimary,
    required this.accent,
    required this.ink,
    required this.muted,
    required this.salary,
    this.card = Colors.white,
  });
}

/// All palettes the app has had. Add new ones here; pick the active one
/// in [AppColors.palette].
class AppPalettes {
  AppPalettes._();

  /// https://colorhunt.co/palette/65928788bda4b1d3b9e6f2dd
  static const sage = AppPalette(
    name: 'Sage',
    primary: Color(0xFF659287),
    secondary: Color(0xFF88BDA4),
    tertiary: Color(0xFFB1D3B9),
    background: Color(0xFFE6F2DD),
    onPrimary: Colors.white,
    accent: Color(0xFF659287),
    ink: Color(0xFF1E3A32),
    muted: Color(0xFF5F7A71),
    salary: Color(0xFF3E7A63),
  );

  /// https://colorhunt.co/palette/fef3e2f3c623ffb22cfa812f
  static const sunset = AppPalette(
    name: 'Sunset',
    primary: Color(0xFFFA812F),
    secondary: Color(0xFFFFB22C),
    tertiary: Color(0xFFF3C623),
    background: Color(0xFFFEF3E2),
    // White on this orange is only ~2.6:1, dark text reads better.
    onPrimary: Color(0xFF3B2A1A),
    accent: Color(0xFFD9661A),
    ink: Color(0xFF3B2A1A),
    muted: Color(0xFF8A6F57),
    salary: Color(0xFFC2560F),
  );

  /// https://colorhunt.co/palette/fbfbfbe8f9ffc4d9ffc5baff
  static const sky = AppPalette(
    name: 'Sky',
    primary: Color(0xFFC5BAFF),
    secondary: Color(0xFFE8F9FF),
    tertiary: Color(0xFFC4D9FF),
    background: Color(0xFFE8F9FF),
    card: Color(0xFFFBFBFB),
    onPrimary: Color(0xFF1E2440),
    accent: Color(0xFF6B5BD6),
    ink: Color(0xFF1E2440),
    muted: Color(0xFF5D6785),
    salary: Color(0xFF3F51B5),
  );

  /// https://colorhunt.co/palette/fff8f0c085528c5a3c4b2e2b
  static const coffee = AppPalette(
    name: 'Coffee',
    primary: Color(0xFF8C5A3C),
    secondary: Color(0xFFC08552),
    tertiary: Color(0xFFC08552),
    background: Color(0xFFFFF8F0),
    onPrimary: Colors.white,
    accent: Color(0xFF8C5A3C),
    ink: Color(0xFF4B2E2B),
    muted: Color(0xFF8C6E5E),
    salary: Color(0xFFA0522D),
  );

  /// https://colorhunt.co/palette/fff5f5f7d6d0e2b4bd4a4a4a
  static const blush = AppPalette(
    name: 'Blush',
    primary: Color(0xFFE2B4BD),
    secondary: Color(0xFFF7D6D0),
    tertiary: Color(0xFFF7D6D0),
    background: Color(0xFFFFF5F5),
    // Palette grey #4A4A4A looked washed out on pink, so text shades are darker.
    onPrimary: Color(0xFF2A2426),
    accent: Color(0xFF9C5568),
    ink: Color(0xFF2A2426),
    muted: Color(0xFF6B5C5F),
    salary: Color(0xFF8E3B57),
  );

  static const all = [sage, sunset, sky, coffee, blush];
}
