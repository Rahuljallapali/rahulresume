import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns theme mode and persists it (localStorage on web).
///
/// Starts in [ThemeMode.system] so a first-time visitor sees the mode their OS
/// already asked for, and only pins to an explicit mode once they choose one.
class ThemeController extends ChangeNotifier {
  ThemeController() {
    _restore();
  }

  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// True once persisted preference has been read. The app paints immediately
  /// either way — this only exists so tests can await settlement.
  bool _restored = false;
  bool get isRestored => _restored;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      if (stored != null) {
        _mode = ThemeMode.values.firstWhere(
          (m) => m.name == stored,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      // Storage can be unavailable (private browsing, blocked cookies).
      // Falling back to the system preference is a fine outcome, so this is
      // not worth surfacing to the user.
    } finally {
      _restored = true;
      notifyListeners();
    }
  }

  /// Resolves [ThemeMode.system] against the current platform brightness so
  /// the toggle always flips to the opposite of what is actually on screen.
  bool isDark(BuildContext context) => switch (_mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      };

  void toggle(BuildContext context) =>
      setMode(isDark(context) ? ThemeMode.light : ThemeMode.dark);

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // Preference is still applied for this session; persistence is a bonus.
    }
  }
}
