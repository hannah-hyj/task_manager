import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    ThemeMode initialMode = ThemeMode.system,
    AppColorSeed initialColorSeed = AppColorSeed.indigo,
  }) : _themeMode = initialMode,
       _colorSeed = initialColorSeed;

  ThemeMode _themeMode;
  AppColorSeed _colorSeed;

  ThemeMode get themeMode => _themeMode;
  AppColorSeed get colorSeed => _colorSeed;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setColorSeed(AppColorSeed seed) {
    if (_colorSeed != seed) {
      _colorSeed = seed;
      notifyListeners();
    }
  }
}
