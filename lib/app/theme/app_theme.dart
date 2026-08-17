import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Builds the light and dark [ThemeData] from the shared token set.
///
/// Type scale uses three families deliberately:
///  * Space Grotesk for display/headline — an engineer's grotesque: quirky
///    ink-trap details at size, unmistakably technical, never generic.
///  * Manrope for body and UI — warm geometric sans that stays crisp at
///    paragraph sizes and pairs naturally with a grotesque display face.
///  * JetBrains Mono for eyebrows, stats and code — the site belongs to
///    someone who ships backends; the type should say so.
/// All are variable-weight and served from the same Google Fonts origin that
/// `web/index.html` preconnects to.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final c = AppColors.forBrightness(brightness);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: brightness == Brightness.dark
          ? const Color(0xFF06070A)
          : Colors.white,
      secondary: c.accentAlt,
      onSecondary: brightness == Brightness.dark
          ? const Color(0xFF06070A)
          : Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceElevated,
      onSurfaceVariant: c.textSecondary,
      outline: c.hairline,
      error: const Color(0xFFE5484D),
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.canvas,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );

    // `height` is set per-role rather than globally: display text wants a
    // tight leading, body text wants a generous one. Space Grotesk carries
    // its own character at size, so tracking is gentler than Sora needed.
    final display = GoogleFonts.spaceGroteskTextTheme(base.textTheme);
    final body = GoogleFonts.manropeTextTheme(base.textTheme);
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);

    final text = base.textTheme.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 68,
        fontWeight: FontWeight.w700,
        height: 1.04,
        letterSpacing: -1.8,
        color: c.textPrimary,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.06,
        letterSpacing: -1.2,
        color: c.textPrimary,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.8,
        color: c.textPrimary,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.8,
        color: c.textPrimary,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
        color: c.textPrimary,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.3,
        color: c.textPrimary,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.2,
        color: c.textPrimary,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: c.textPrimary,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: c.textSecondary,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        fontSize: 17,
        height: 1.65,
        letterSpacing: -0.1,
        color: c.textSecondary,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 15,
        height: 1.65,
        color: c.textSecondary,
      ),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.55,
        color: c.textTertiary,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: c.textPrimary,
      ),
      // Eyebrows, stat captions and keyboard hints render in mono: uppercase
      // JetBrains Mono at a wide track is the strongest "backend engineer"
      // signal on the page, and it costs nothing in readability at this size.
      labelMedium: mono.labelMedium?.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: c.textTertiary,
      ),
      labelSmall: mono.labelSmall?.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: c.textTertiary,
      ),
    );

    return base.copyWith(
      extensions: [c],
      textTheme: text,
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: c.textSecondary, size: 20),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor:
            WidgetStatePropertyAll(c.textTertiary.withValues(alpha: 0.4)),
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(Radii.pill),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: c.hairline),
        ),
        textStyle: text.bodySmall?.copyWith(color: c.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        hintStyle: text.bodyMedium?.copyWith(color: c.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: Space.md, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: c.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: c.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: c.accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      // Fade-through on route changes; no horizontal slide, which reads as
      // mobile-app chrome on a desktop site.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
