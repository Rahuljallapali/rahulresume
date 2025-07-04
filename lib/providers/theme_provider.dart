import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // Default to dark mode

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    try {
      return _isDarkMode ? _darkTheme : _lightTheme;
    } catch (e) {
      // Fallback to default dark theme if there's an error
      return _darkTheme;
    }
  }

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6366F1), // Indigo
      secondary: const Color(0xFF14B8A6), // Teal
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1F2937),
      onBackground: const Color(0xFF1F2937),
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        height: 1.1,
        letterSpacing: -1.5,
      ),
      displayMedium: const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        height: 1.1,
        letterSpacing: -1,
      ),
      displaySmall: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        height: 1.1,
        letterSpacing: -0.5,
      ),
      headlineLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        height: 1.2,
      ),
      headlineMedium: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        height: 1.2,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        height: 1.2,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1F2937).withOpacity(0.9),
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1F2937).withOpacity(0.9),
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: const Color(0xFF1F2937).withOpacity(0.8),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: const Color(0xFF1F2937).withOpacity(0.7),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: const Color(0xFF1F2937).withOpacity(0.7),
        height: 1.5,
      ),
      labelLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
        height: 1.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF1F2937),
      size: 24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF818CF8), // Lighter Indigo
      secondary: const Color(0xFF2DD4BF), // Lighter Teal
      surface: const Color(0xFF1F2937),
      background: const Color(0xFF111827),
      error: const Color(0xFFFCA5A5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: const Color(0xFF1F2937),
      brightness: Brightness.dark,
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -1.5,
      ),
      displayMedium: const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -1,
      ),
      displaySmall: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      headlineLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      headlineMedium: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.9),
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.9),
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.8),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.7),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.7),
        height: 1.5,
      ),
      labelLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF818CF8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF374151),
      thickness: 1,
    ),
  );
} 