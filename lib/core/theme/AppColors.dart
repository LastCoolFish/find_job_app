import 'package:flutter/material.dart';

/// App palette, based on https://colorhunt.co/palette/65928788bda4b1d3b9e6f2dd
class AppColors {
  AppColors._();

  // Palette
  static const sage = Color(0xFF659287);
  static const mint = Color(0xFF88BDA4);
  static const pale = Color(0xFFB1D3B9);
  static const cream = Color(0xFFE6F2DD);

  // Derived shades for text and accents that need more contrast
  // than the palette itself provides on light backgrounds.
  static const ink = Color(0xFF1E3A32);
  static const muted = Color(0xFF5F7A71);
  static const salary = Color(0xFF3E7A63);
  static const card = Colors.white;
}
