import 'package:dio/dio.dart';
import '../models/book.dart';
import '../models/category.dart';
import 'auth_service.dart';

class ApiService {
  static final Dio _dio = AuthService.dioInstance;

  static Future<List<Book>> fetchBooks() async {
    try {
      print('📚 Fetching books from /books');
      final response = await _dio.get('/books');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Debug the raw data
        print(
          '📖 Raw book data (first item): ${data.isNotEmpty ? data[0] : "No data"}',
        );

        final books = data.map((json) => Book.fromJson(json)).toList();
        print('✅ Parsed ${books.length} books');

        // Debug the parsed books
        if (books.isNotEmpty) {
          final Book firstBook = books[0];
          print('📗 First book details:');
          print(' - Title: ${firstBook.title}');
          print(' - Author: ${firstBook.author}');
          print(' - Genre: ${firstBook.genre}');
          print(' - CoverUrl: ${firstBook.coverUrl}');
        }

        return books;
      } else {
        print('❌ Error response: ${response.statusCode}');
        throw Exception('Failed to load books');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      }
      print('⚠️ Dio error: $e');
      throw Exception('Failed to load books');
    }
  }

  static Future<List<Category>> fetchCategories() async {
    try {
      print('📂 Fetching categories from /categories');

      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final categories = data.map((json) => Category.fromJson(json)).toList();
        print('✅ Parsed ${categories.length} categories');
        return categories;
      } else {
        print('❌ Error response: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      }
      print('⚠️ Dio error: $e');
      throw Exception('Failed to load categories');
    }
  }

  static Future<void> syncBooks(List<Book> books) async {
    try {
      print('🔄 Syncing ${books.length} books to /books/sync');
      final unsyncedBooks = books.where((book) => !book.isSynced).toList();
      if (unsyncedBooks.isEmpty) {
        print('✅ No unsynced books to sync');
        return;
      }

      final response = await _dio.post(
        '/books/sync',
        data: unsyncedBooks.map((book) => book.toJson()).toList(),
      );

      if (response.statusCode == 200) {
        print('✅ Successfully synced ${unsyncedBooks.length} books');
      } else {
        print('❌ Sync error response: ${response.statusCode}');
        throw Exception('Failed to sync books');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      }
      print('⚠️ Sync Dio error: $e');
      throw Exception('Failed to sync books');
    }
  }
}