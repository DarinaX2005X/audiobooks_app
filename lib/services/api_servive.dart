import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/user_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static final Dio _dio = AuthService.dioInstance;
  static const int maxRetries = 3;

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchBooks() async {
    try {
      final response = await _dio.get('/books');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> fetchBookDetails(String bookId) async {
    try {
      final response = await _dio.get('/books/$bookId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      rethrow;
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load categories: ${e.message}');
    }
  }

  static Future<List<Book>> getBooks() async {
    try {
      final response = await _dio.get('/books');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Failed to load books: ${e.message}');
    }
  }

  static Future<Book?> getBookDetails(String bookId) async {
    try {
      final response = await _dio.get('/books/$bookId');
      if (response.statusCode == 200) {
        return Book.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load book details: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('👤 Fetching user profile from /auth/me');
      final response = await _dio.get('/auth/me');
      print('📖 User profile response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['user'] is Map) {
          final user = data['user'] as Map<String, dynamic>;
          final favorites = user['favorites'] is List
              ? List<Map<String, dynamic>>.from(user['favorites'])
              : <Map<String, dynamic>>[];
          final progress = user['progress'] is List
              ? Map<String, int>.fromEntries(
                  (user['progress'] as List).map((e) => MapEntry(
                    e['audiobookId'].toString(),
                    (e['positionSec'] as num).toInt(),
                  )),
                )
              : <String, int>{};
          
          return {
            'favorites': favorites,
            'progress': progress,
          };
        } else {
          print('❌ User data is not a Map, got ${data['user'].runtimeType}');
          throw Exception('Invalid user data format: Expected Map');
        }
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('⚠️ Dio error: $e');
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
      }
      throw Exception('Failed to load user profile: ${e.message}');
    } catch (e) {
      print('⚠️ Unexpected error in getUserProfile: $e');
      rethrow;
    }
  }

  static Future<bool> addToFavorites(String bookId) async {
    try {
      print('❤️ Adding book $bookId to favorites');
      final response = await _dio.patch('/profile/favorites/$bookId');
      if (response.statusCode == 200) {
        print('✅ Book $bookId added to favorites');
        return true;
      }
      print('❌ Failed to add to favorites: Status ${response.statusCode}');
      return false;
    } catch (e) {
      print('⚠️ Unexpected error in addToFavorites: $e');
      rethrow;
    }
  }

  static Future<bool> removeFromFavorites(String bookId) async {
    try {
      print('🗑️ Removing book $bookId from favorites');
      final response = await _dio.patch('/profile/favorites/$bookId');
      if (response.statusCode == 200) {
        print('✅ Book $bookId removed from favorites');
        return true;
      }
      print('❌ Failed to remove from favorites: Status ${response.statusCode}');
      return false;
    } catch (e) {
      print('⚠️ Unexpected error in removeFromFavorites: $e');
      rethrow;
    }
  }

  static Future<bool> updateProgress(String bookId, int positionSec) async {
    try {
      print('📄 Updating progress for book $bookId to position $positionSec');
      final isOffline = await Connectivity().checkConnectivity() == ConnectivityResult.none;
      final currentProgress = await LocalStorageService.getProgress();
      
      // Save to local storage first
      currentProgress[bookId] = positionSec;
      await LocalStorageService.saveProgress(currentProgress);
      
      if (!isOffline) {
        int retryCount = 0;
        bool success = false;
        
        while (retryCount < maxRetries && !success) {
          try {
            final response = await _dio.post(
              '/profile/progress',
              data: {
                'audiobookId': bookId,
                'positionSec': positionSec,
              },
            );
            
            if (response.statusCode == 200) {
              print('✅ Progress updated for book $bookId');
              success = true;
            } else {
              print('❌ Failed to update progress: Status ${response.statusCode}');
              throw Exception('Failed to update progress: ${response.statusCode}');
            }
          } on DioException catch (e) {
            retryCount++;
            if (e.response?.statusCode == 401) {
              if (retryCount == maxRetries) {
                print('⚠️ Max retries reached for updating progress');
                throw Exception('Failed to update progress after $maxRetries attempts');
              }
              continue;
            }
            if (retryCount == maxRetries) {
              print('⚠️ Max retries reached for updating progress');
              throw Exception('Failed to update progress after $maxRetries attempts');
            }
            await Future.delayed(Duration(seconds: retryCount));
          }
        }
      } else {
        print('✅ Progress updated locally for book $bookId');
      }
      return true;
    } catch (e) {
      print('⚠️ Unexpected error in updateProgress: $e');
      rethrow;
    }
  }

  static Future<int?> getProgress(String bookId) async {
    try {
      print('📊 Getting progress for book $bookId');
      final response = await _dio.get('/profile/progress/$bookId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('positionSec')) {
          return (data['positionSec'] as num).toInt();
        }
      }
      return null;
    } catch (e) {
      print('⚠️ Error getting progress: $e');
      return null;
    }
  }

  static Future<bool> syncBooks(List<Book> books) async {
    try {
      print('🔄 Syncing ${books.length} books');
      final isOffline = await Connectivity().checkConnectivity() == ConnectivityResult.none;
      if (isOffline) {
        print('📴 Offline, cannot sync books');
        return false;
      }

      // First get current server state
      final userProfile = await getUserProfile();
      final serverFavorites = List<String>.from(userProfile['favorites'] ?? []);
      final serverProgress = Map<String, int>.from(userProfile['progress'] ?? {});

      // Merge local and server data
      final mergedFavorites = Set<String>.from(serverFavorites);
      final mergedProgress = Map<String, int>.from(serverProgress);

      for (var book in books) {
        if (book.isFavorite == true) {
          mergedFavorites.add(book.id);
        } else if (book.isFavorite == false) {
          mergedFavorites.remove(book.id);
        }
        if (book.progressPage != null && book.progressPage! > 0) {
          mergedProgress[book.id] = book.progressPage!;
        }
      }

      // Update server with merged data
      try {
        // Update favorites
        for (var bookId in mergedFavorites) {
          await _dio.patch('/profile/favorites/$bookId');
        }
        
        // Update progress
        for (var entry in mergedProgress.entries) {
          await _dio.post(
            '/profile/progress',
            data: {
              'audiobookId': entry.key,
              'positionSec': entry.value,
            },
          );
        }
        
        // Update local storage with merged data
        await LocalStorageService.saveProgress(mergedProgress);
        
        // Update books with synced status
        final syncedBooks = books.map((book) => book.copyWith(
          isSynced: true,
          isFavorite: mergedFavorites.contains(book.id),
          progressPage: mergedProgress[book.id],
        )).toList();
        
        await LocalStorageService.saveBooks(syncedBooks);
        print('✅ Synced ${books.length} books successfully');
        return true;
      } catch (e) {
        print('⚠️ Error updating server data: $e');
        // Even if server update fails, save locally
        await LocalStorageService.saveProgress(mergedProgress);
        throw Exception('Failed to sync with server: $e');
      }
    } catch (e) {
      print('⚠️ Unexpected error in syncBooks: $e');
      rethrow;
    }
  }

  static Future<void> handleAuthError() async {
    await AuthService.logout();
  }
}