import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthService {
  static const String baseUrl = 'http://37.151.246.104:3000/api';
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  static final CookieJar _cookieJar = CookieJar();
  static String? _token;
  static String? _userId;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  static String? get token => _token;
  static String? get userId => _userId;

  static Future<void> init() async {
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    // Load saved token and user ID
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);

    // If we have a token, try to validate it with the server
    if (_token != null) {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.none) {
          // Try to validate token with server
          final response = await _dio.get('/auth/me');
          if (response.statusCode != 200) {
            // Token is invalid, clear it
            await _clearStoredCredentials();
          }
        }
      } catch (e) {
        print('⚠️ Token validation error: $e');
        // Don't clear token on network error - we'll keep it for offline use
      }
    }
  }

  static Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      print('🔑 Attempting login with email: $email'); // Debug log
      
      final response = await _dio.post(
        '/auth/login',
        data: {
          'login': email,
          'password': password,
        },
      );

      print('🔑 Login response status: ${response.statusCode}'); // Debug log
      print('🔑 Login response data: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          // Get user data from the response
          final userData = data['rest'] as Map<String, dynamic>;
          final userId = userData['id'];
          final sessionId = data['sessionId'];
          
          if (userId == null || sessionId == null) {
            print('⚠️ Login error: Missing userId or sessionId');
            return false;
          }

          _userId = userId;
          _token = sessionId; // Use sessionId as token
          
          // Save credentials if remember me is enabled
          if (rememberMe) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_tokenKey, sessionId);
            await prefs.setString(_userIdKey, userId);
          }
          
          return true;
        } else {
          print('⚠️ Login error: Response data is not a Map');
          return false;
        }
      }
      
      print('⚠️ Login error: Status code ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('⚠️ Login error (DioException): ${e.message}');
      print('⚠️ Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('⚠️ Login error: $e');
      rethrow;
    }
  }

  static Future<bool> validateOfflineAccess() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    
    return _token != null && _userId != null;
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
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

  static Future<void> _clearStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _token = null;
    _userId = null;
  }

  static Future<bool> logout() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _dio.post('/auth/logout');
      }
      
      await _clearStoredCredentials();
      await _cookieJar.deleteAll();
      return true;
    } catch (e) {
      print('⚠️ Logout error: $e');
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    if (_token != null && _userId != null) {
      return true;
    }
    
    // Try to load from storage
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    
    return _token != null && _userId != null;
  }

  static Future<Response> fetchWithAuth(String endpoint) async {
    if (_token == null) {
      throw Exception('Not authenticated');
    }
    return await _dio.get(
      endpoint,
      options: Options(
        headers: {'Authorization': 'Bearer $_token'},
      ),
    );
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