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

  // Add book to favorites
  Future<bool> addToFavorites(String bookId) async {
    try {
      print('❤️ Adding book $bookId to favorites');
      final response = await _dio.patch('/profile/favorites/$bookId');
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Error adding to favorites: $e');
      return false;
    }
  }

  // Remove book from favorites
  Future<bool> removeFromFavorites(String bookId) async {
    try {
      print('💔 Removing book $bookId from favorites');
      final response = await _dio.delete('/profile/favorites/$bookId');
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Error removing from favorites: $e');
      return false;
    }
  }

  // Update reading progress
  Future<bool> updateProgress(String bookId, int pageNumber) async {
    try {
      print('📖 Updating progress for book $bookId to page $pageNumber');
      final response = await _dio.post('/profile/progress', data: {
        'audiobookId': bookId,
        'positionSec': pageNumber,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Error updating progress: $e');
      return false;
    }
  }

  // Get reading progress
  Future<int?> getProgress(String bookId) async {
    try {
      print('📖 Getting progress for book $bookId');
      final response = await _dio.get('/profile/progress/$bookId');
      if (response.statusCode == 200) {
        return response.data['positionSec'] as int?;
      }
      return null;
    } catch (e) {
      print('⚠️ Error getting progress: $e');
      return null;
    }
  }
}
