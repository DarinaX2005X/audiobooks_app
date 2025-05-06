import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  bool _notificationsEnabled = true;
  String _fontSize = 'medium';
  bool _dataSyncEnabled = true;

  SettingsProvider();

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  String get fontSize => _fontSize;
  bool get dataSyncEnabled => _dataSyncEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 1]; // 1 = light
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _fontSize = prefs.getString('fontSize') ?? 'medium';
    _dataSyncEnabled = prefs.getBool('dataSyncEnabled') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    final newLocale = Locale(languageCode);
    if (_locale != newLocale) {
      _locale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', enabled);
      notifyListeners();
    }
  }

  Future<void> setFontSize(String size) async {
    if (_fontSize != size) {
      _fontSize = size;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fontSize', size);
      notifyListeners();
    }
  }

  Future<void> setDataSyncEnabled(bool enabled) async {
    if (_dataSyncEnabled != enabled) {
      _dataSyncEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dataSyncEnabled', enabled);
      notifyListeners();
    }
  }
}