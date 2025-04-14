import 'package:dio/dio.dart';
import 'auth_service.dart';

class UserService {
  static final Dio _dio = AuthService.dioInstance;

  // Fetch current user profile data
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      print('👤 Fetching user profile from /auth/me');

      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data.containsKey('user')) {
          return {
            'success': true,
            'user': data['user'],
            'message': data['message'] ?? 'Profile loaded successfully',
          };
        } else {
          print('❓ Unexpected response format: $data');
          return {
            'success': false,
            'message': 'Unexpected response format from server',
          };
        }
      } else {
        print('❌ Profile error response: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to load profile data',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final message = e.response?.data['message'] ?? 'Network error. Please check your connection.';
      print('⚠️ Dio error: $message');
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('⚠️ General error fetching profile: $e');
      return {
        'success': false,
        'message': 'An unknown error occurred',
      };
    }
  }
}
