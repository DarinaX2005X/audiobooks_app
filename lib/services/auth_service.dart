import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://37.151.246.104:3000/api';
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    validateStatus: (status) => status! < 500,
  ));
  static final CookieJar _cookieJar = CookieJar();
  static const String _loginKey = 'saved_login';
  static const String _passwordKey = 'saved_password';
  static const String _pinKey = 'secure_pin';
  static const String _hasPinKey = 'has_pin_set';
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<void> init() async {
    debugPrint('🔄 AuthService: Initializing...');
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    // Проверяем сохраненные учетные данные
    final credentials = await getSavedCredentials();
    if (credentials['login'] != null && credentials['password'] != null) {
      debugPrint('🔄 AuthService: Found saved credentials, attempting auto-login');
      await autoLogin();
    } else {
      debugPrint('🔄 AuthService: No saved credentials found');
    }
  }

  static Future<bool> saveCredentials(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginKey, login);
    await prefs.setString(_passwordKey, password);
    debugPrint('🔑 Credentials saved for auto-login');
    return true;
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'login': prefs.getString(_loginKey),
      'password': prefs.getString(_passwordKey),
    };
  }

  static Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_passwordKey);
    debugPrint('🔑 Saved credentials cleared');
  }

  static Future<bool> autoLogin() async {
    debugPrint('🔄 Attempting auto-login...');
    final credentials = await getSavedCredentials();
    final login = credentials['login'];
    final password = credentials['password'];

    if (login != null && password != null) {
      debugPrint('🔄 Found saved credentials, attempting login...');
      return await AuthService.login(login, password);
    }
    
    debugPrint('🔄 No saved credentials found');
    return false;
  }

  static Future<bool> setPinCode(String pin) async {
    if (_currentUser == null) {
      debugPrint('❌ Cannot set PIN: User not authenticated');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // В реальном приложении здесь нужно использовать шифрование
      await prefs.setString(_pinKey, pin);
      await prefs.setBool(_hasPinKey, true);
      debugPrint('🔐 PIN code set successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error setting PIN code: $e');
      return false;
    }
  }

  static Future<bool> verifyPinCode(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString(_pinKey);
      
      if (savedPin == null) {
        debugPrint('❌ No PIN code found');
        return false;
      }

      final isValid = savedPin == pin;
      if (isValid) {
        debugPrint('🔐 PIN verification successful');
        // Восстанавливаем последнего пользователя для офлайн режима
        final lastUserData = prefs.getString('last_user_data');
        if (lastUserData != null) {
          _currentUser = User.fromJson(json.decode(lastUserData));
        }
      } else {
        debugPrint('❌ Invalid PIN code');
      }
      return isValid;
    } catch (e) {
      debugPrint('❌ Error verifying PIN code: $e');
      return false;
    }
  }

  static Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPinKey) ?? false;
  }

  static Future<void> removePinCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      await prefs.remove(_hasPinKey);
      debugPrint('🔐 PIN code removed');
    } catch (e) {
      debugPrint('❌ Error removing PIN code: $e');
    }
  }

  static Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      debugPrint('🔑 Attempting login with email: $email');
      final response = await _dio.post(
        '/auth/login',
        data: {
          'login': email,
          'password': password,
        },
      );

      debugPrint('🔑 Login response status: ${response.statusCode}');
      debugPrint('🔑 Login response data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          _currentUser = User.fromJson(data['rest']);
          
          // Сохраняем данные пользователя для офлайн режима
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_user_data', json.encode(data['rest']));
          
          // Если rememberMe включен, сохраняем учетные данные
          if (rememberMe) {
            await saveCredentials(email, password);
          }

          debugPrint('🔑 Login successful');
          return true;
        } catch (e) {
          debugPrint('❌ Error processing login response: $e');
          return false;
        }
      }
      debugPrint('❌ Login failed with status code: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('❌ Error during login: $e');
      return false;
    }
  }

  static Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data['rest']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error during registration: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    debugPrint('🔑 Logging out...');
    _currentUser = null;
    await clearSavedCredentials();
    await removePinCode(); // Удаляем PIN при выходе
    debugPrint('🔑 Logout completed, all credentials cleared');
  }

  static Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  static Future<Response> fetchWithAuth(String endpoint) async {
    if (_currentUser == null) {
      throw Exception('Not authenticated');
    }
    return await _dio.get(endpoint);
  }

  static Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', isGuest);
  }

  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGuest') ?? false;
  }

  static Dio get dioInstance => _dio;
}