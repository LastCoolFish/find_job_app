import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppPalette.dart';

/// Colours of the active palette. Widgets use these instead of raw hex codes.
class AppColors {
  AppColors._();

  /// Active palette. Change this line to switch the whole app's colours
  /// (see [AppPalettes] for the available ones).
  static const AppPalette palette = AppPalettes.sage;

  static Color get primary => palette.primary;
  static Color get secondary => palette.secondary;
  static Color get tertiary => palette.tertiary;
  static Color get background => palette.background;
  static Color get onPrimary => palette.onPrimary;
  static Color get accent => palette.accent;
  static Color get ink => palette.ink;
  static Color get muted => palette.muted;
  static Color get salary => palette.salary;
  static Color get card => palette.card;
}
