import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://37.151.246.104:3000/api';
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  static final CookieJar _cookieJar = CookieJar();

  static Future<void> init() async {
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: jsonEncode({'login': email, 'password': password}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print(
        '🍪 Cookies after login: ${await _cookieJar.loadForRequest(Uri.parse(baseUrl))}',
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false); // Reset guest mode on login
        return true;
      }
      return false;
    } catch (e) {
      print('⚠️ Login error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> register(
      String username,
      String email,
      String password,
      ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': response.data['message'] ?? 'Registration complete',
      };
    } catch (e) {
      print('⚠️ Registration error: $e');
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  static Future<bool> logout() async {
    try {
      final response = await _dio.post('/auth/logout');

      await _cookieJar.deleteAll(); // Clear cookies on logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGuest', false); // Reset guest mode on logout
      print('Logout status: ${response.statusCode}');
      return true;
    } catch (e) {
      print('⚠️ Logout error: $e');
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    final cookies = await _cookieJar.loadForRequest(Uri.parse(baseUrl));
    return cookies.any((cookie) => cookie.name == 'session');
  }

  static Future<Response> fetchWithAuth(String endpoint) async {
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