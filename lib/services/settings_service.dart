import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static const String _localeKey = 'locale';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load saved theme mode
    final savedThemeMode = _prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedThemeMode,
        orElse: () => ThemeMode.light,
      );
    }

    // Load saved locale
    final savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _prefs.setString(_themeModeKey, mode.toString());
      notifyListeners();
    }
  }

  void setLocale(String languageCode) {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      _prefs.setString(_localeKey, languageCode);
      notifyListeners();
    }
  }
}
