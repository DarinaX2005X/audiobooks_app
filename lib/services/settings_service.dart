import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  bool _notificationsEnabled = true;
  String _fontSize = 'medium';
  bool _dataSyncEnabled = true;
  bool _isInitialized = false;

  SettingsProvider();

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  String get fontSize => _fontSize;
  bool get dataSyncEnabled => _dataSyncEnabled;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeModeIndex = prefs.getInt('themeMode');
      if (themeModeIndex != null && themeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }

      // Load locale
      final languageCode = prefs.getString('languageCode');
      if (languageCode != null) {
        _locale = Locale(languageCode);
      }

      // Load other settings
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _fontSize = prefs.getString('fontSize') ?? 'medium';
      _dataSyncEnabled = prefs.getBool('dataSyncEnabled') ?? true;

      _isInitialized = true;
      notifyListeners();
      print('✅ Settings initialized successfully');
    } catch (e) {
      print('❌ Error initializing settings: $e');
      // Use default values if initialization fails
      _themeMode = ThemeMode.light;
      _locale = const Locale('en');
      _notificationsEnabled = true;
      _fontSize = 'medium';
      _dataSyncEnabled = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('themeMode', mode.index);
        notifyListeners();
      } catch (e) {
        print('❌ Error saving theme mode: $e');
      }
    }
  }

  Future<void> setLocale(String languageCode) async {
    final newLocale = Locale(languageCode);
    if (_locale != newLocale) {
      _locale = newLocale;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('languageCode', languageCode);
        notifyListeners();
      } catch (e) {
        print('❌ Error saving locale: $e');
      }
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notificationsEnabled', enabled);
        notifyListeners();
      } catch (e) {
        print('❌ Error saving notifications setting: $e');
      }
    }
  }

  Future<void> setFontSize(String size) async {
    if (_fontSize != size) {
      _fontSize = size;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fontSize', size);
        notifyListeners();
      } catch (e) {
        print('❌ Error saving font size: $e');
      }
    }
  }

  Future<void> setDataSyncEnabled(bool enabled) async {
    if (_dataSyncEnabled != enabled) {
      _dataSyncEnabled = enabled;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dataSyncEnabled', enabled);
        notifyListeners();
      } catch (e) {
        print('❌ Error saving data sync setting: $e');
      }
    }
  }
}