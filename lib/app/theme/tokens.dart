import 'package:flutter/material.dart';

/// Design tokens.
///
/// Colours are declared once per mode and reached through [AppColors.of] so no
/// widget hard-codes a hex value. Every foreground/background pairing used for
/// text meets WCAG AA (4.5:1 for body, 3:1 for large display text) in both
/// modes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.glassFill,
    required this.glassBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentSoft,
    required this.accentAlt,
    required this.success,
    required this.hairline,
    required this.glow,
  });

  /// Page background.
  final Color canvas;

  /// Default card background.
  final Color surface;

  /// Raised card / hover state.
  final Color surfaceElevated;

  /// Translucent fill for glass panels.
  final Color glassFill;
  final Color glassBorder;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color accent;
  final Color accentSoft;
  final Color accentAlt;
  final Color success;

  /// 1px separators.
  final Color hairline;

  /// Ambient background bloom.
  final Color glow;

  static const _dark = AppColors(
    canvas: Color(0xFF08090C),
    surface: Color(0xFF0F1116),
    surfaceElevated: Color(0xFF161922),
    glassFill: Color(0x0DFFFFFF),
    glassBorder: Color(0x14FFFFFF),
    textPrimary: Color(0xFFF5F6F8),
    textSecondary: Color(0xFFA7ADBB),
    textTertiary: Color(0xFF6E7480),
    accent: Color(0xFF6E8BFF),
    accentSoft: Color(0x266E8BFF),
    accentAlt: Color(0xFF3FD0C9),
    success: Color(0xFF46D18C),
    hairline: Color(0xFF1D212B),
    glow: Color(0xFF3A56C4),
  );

  static const _light = AppColors(
    canvas: Color(0xFFFBFBFD),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF4F5F9),
    glassFill: Color(0xB3FFFFFF),
    glassBorder: Color(0x14000000),
    textPrimary: Color(0xFF0C0E14),
    textSecondary: Color(0xFF4E5563),
    textTertiary: Color(0xFF848B99),
    accent: Color(0xFF3355E8),
    accentSoft: Color(0x1A3355E8),
    accentAlt: Color(0xFF0E9C94),
    success: Color(0xFF128A56),
    hairline: Color(0xFFE6E8EF),
    glow: Color(0xFFA9B8FF),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? glassFill,
    Color? glassBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentSoft,
    Color? accentAlt,
    Color? success,
    Color? hairline,
    Color? glow,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentAlt: accentAlt ?? this.accentAlt,
      success: success ?? this.success,
      hairline: hairline ?? this.hairline,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t)!,
      success: Color.lerp(success, other.success, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }

  static AppColors forBrightness(Brightness b) =>
      b == Brightness.dark ? _dark : _light;
}

/// Spacing scale. Multiples of 4 keep vertical rhythm consistent.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const section = 96.0;
  static const sectionTight = 64.0;
}

abstract final class Radii {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}

/// Breakpoints. Named for intent rather than device.
abstract final class Breakpoints {
  static const compact = 720.0;
  static const medium = 1080.0;
  static const wide = 1440.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 560);

  /// Slight overshoot on entry — reads as responsive without being bouncy.
  static const enter = Cubic(0.16, 1.0, 0.3, 1.0);
  static const standard = Curves.easeOutCubic;
}
