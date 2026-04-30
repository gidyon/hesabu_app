import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accent color options available to the user.
enum AppAccentColor {
  emerald, // default green
  brownish,
  orangish,
  reddish,
}

extension AppAccentColorX on AppAccentColor {
  String get label {
    switch (this) {
      case AppAccentColor.emerald:
        return 'Emerald Green';
      case AppAccentColor.brownish:
        return 'Warm Clay';
      case AppAccentColor.orangish:
        return 'Amber Orange';
      case AppAccentColor.reddish:
        return 'Rose Red';
    }
  }

  Color get primary {
    switch (this) {
      case AppAccentColor.emerald:
        return const Color(0xFF4ade80);
      case AppAccentColor.brownish:
        return const Color(0xFFc47c3c);
      case AppAccentColor.orangish:
        return const Color(0xFFf59e0b);
      case AppAccentColor.reddish:
        return const Color(0xFFef4444);
    }
  }

  Color get darkBackground {
    switch (this) {
      case AppAccentColor.emerald:
        return const Color(0xFF365C44); // Substantially lighter
      case AppAccentColor.brownish:
        return const Color(0xFF5C3C28); // Substantially lighter
      case AppAccentColor.orangish:
        return const Color(0xFF5C4728); // Substantially lighter
      case AppAccentColor.reddish:
        return const Color(0xFF5C2828); // Substantially lighter
    }
  }

  /// Two-color swatch shown in the palette picker.
  List<Color> get swatchColors => [primary, darkBackground];
}

/// Controls the app's theme mode and accent color.
class ThemeController extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.dark;
  AppAccentColor _accentColor = AppAccentColor.emerald;

  ThemeController(this._prefs) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final modeIndex = _prefs.getInt(_themeModeKey);
    if (modeIndex != null) {
      _themeMode = ThemeMode.values[modeIndex];
    }

    final accentIndex = _prefs.getInt(_accentColorKey);
    if (accentIndex != null) {
      _accentColor = AppAccentColor.values[accentIndex];
    }
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  AppAccentColor get accentColor => _accentColor;

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setInt(_themeModeKey, _themeMode.index);
    notifyListeners();
  }

  Future<void> setAccent(AppAccentColor accent) async {
    if (_accentColor == accent) return;
    _accentColor = accent;
    await _prefs.setInt(_accentColorKey, _accentColor.index);
    notifyListeners();
  }
}
