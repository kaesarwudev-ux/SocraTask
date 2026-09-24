import 'package:flutter/material.dart';

/// SocraTask visual identity: creamy surfaces, muted eco-green accent.
/// See `design.md` §1–§2.
abstract final class SocraTheme {
  /// Muted eco green.
  static const ecoGreen = Color(0xFF55825C);

  /// Creamy white (light background, never pure white).
  static const cream = Color(0xFFFAF6ED);

  /// Whisper-green row tint for selected / hovered sidebar rows.
  static Color get rowTint => ecoGreen.withValues(alpha: 0.12);
  static Color get rowHover => ecoGreen.withValues(alpha: 0.08);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ecoGreen,
      brightness: Brightness.light,
    ).copyWith(
      surface: cream,
      surfaceContainerLowest: cream,
      // Pin the exact muted eco-green accent instead of the seed-derived tone.
      primary: ecoGreen,
    );
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ecoGreen,
      brightness: Brightness.dark,
    );
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }
}
