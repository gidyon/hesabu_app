import 'package:flutter/material.dart';

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
        return const Color(0xFF2bee6c);
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
        return const Color(0xFF102216);
      case AppAccentColor.brownish:
        return const Color(0xFF1e1208);
      case AppAccentColor.orangish:
        return const Color(0xFF1e1508);
      case AppAccentColor.reddish:
        return const Color(0xFF1e0808);
    }
  }

  /// Two-color swatch shown in the palette picker.
  List<Color> get swatchColors => [primary, darkBackground];
}

/// Controls the app's theme mode and accent color.
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppAccentColor _accentColor = AppAccentColor.emerald;

  ThemeMode get themeMode => _themeMode;
  AppAccentColor get accentColor => _accentColor;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setAccent(AppAccentColor accent) {
    if (_accentColor == accent) return;
    _accentColor = accent;
    notifyListeners();
  }
}
