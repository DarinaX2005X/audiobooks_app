import 'dart:io';
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../services/api_servive.dart';

class LocalStorageService {
  static Map<String, int> _cachedProgress = {};
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      
      // Register adapters if needed
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BookAdapter());
      }

      final box = await Hive.openBox(userBox);
      _cachedProgress = box.get('progress')?.cast<String, int>() ?? {};
      
      print('📦 Local storage initialized with ${_cachedProgress.length} progress entries');
      _isInitialized = true;
    } catch (e) {
      print('⚠️ Error initializing local storage: $e');
      _cachedProgress = {};
      _isInitialized = false;
      rethrow;
    }
  }

  static Map<String, int> getProgressSync() => _cachedProgress;

  static const String booksBox = 'books';
  static const String categoriesBox = 'categories';
  static const String pdfsBox = 'pdfs';
  static const String userBox = 'user';
  static const String recentBooksBox = 'recent_books';

  static Future<Box<Book>> _getBooksBox() async {
    return await Hive.openBox<Book>(booksBox);
  }

  static Future<Box> _getUserBox() async {
    return await Hive.openBox(userBox);
  }

  static Future<Box<String>> _getRecentBooksBox() async {
    return await Hive.openBox<String>(recentBooksBox);
  }

  static Future<void> addRecentBook(String bookId) async {
    try {
      final box = await _getRecentBooksBox();
      final recentBooks = box.values.toList();
      
      // Remove if already exists to avoid duplicates
      recentBooks.remove(bookId);
      
      // Add to the beginning of the list
      recentBooks.insert(0, bookId);
      
      // Keep only the last 10 books
      if (recentBooks.length > 10) {
        recentBooks.removeLast();
      }
      
      // Save the updated list
      await box.clear();
      await box.addAll(recentBooks);
    } catch (e) {
      print('Error adding recent book: $e');
    }
  }

  static Future<List<Book>> getRecentBooks() async {
    try {
      final recentBooksBox = await _getRecentBooksBox();
      final bookIds = recentBooksBox.values.toList();
      
      if (bookIds.isEmpty) return [];
      
      final booksBox = await _getBooksBox();
      final books = booksBox.values.toList();
      
      // Filter books that exist in our database
      return bookIds
          .map((id) => books.firstWhereOrNull((book) => book.id == id))
          .where((book) => book != null)
          .cast<Book>()
          .toList();
    } catch (e) {
      print('Error getting recent books: $e');
      return [];
    }
  }

  static Future<void> saveBooks(List<Book> books) async {
    try {
      final booksBox = await _getBooksBox();
      await booksBox.clear();
      await booksBox.addAll(books);
    } catch (e) {
      print('Error saving books: $e');
      rethrow;
    }
  }

  static Future<List<Book>> getBooks() async {
    final box = await Hive.openBox<Book>(booksBox);
    return box.values.toList();
  }

  static Future<Book?> getBook(String id) async {
    final box = await Hive.openBox<Book>(booksBox);
    return box.values.firstWhereOrNull((book) => book.id == id);
  }

  static Future<void> updateBook(Book book) async {
    final box = await Hive.openBox<Book>(booksBox);
    final existingBook = box.values.firstWhereOrNull((b) => b.id == book.id);
    if (existingBook != null) {
      final index = box.values.toList().indexOf(existingBook);
      await box.putAt(index, book);
    } else {
      await box.add(book);
    }
  }

  static Future<void> saveCategories(List<String> categories) async {
    final box = await Hive.openBox<String>(categoriesBox);
    await box.clear();
    await box.addAll(categories);
  }

  static Future<List<String>> getCategories() async {
    final box = await Hive.openBox<String>(categoriesBox);
    return box.values.toList();
  }

  static Future<String?> cachePdf(String pdfUrl, String bookTitle) async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/pdfs/$bookTitle.pdf');
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        final box = await Hive.openBox<String>(pdfsBox);
        await box.put(bookTitle, file.path);
        return file.path;
      }
    } catch (e) {
      print('⚠️ Error caching PDF: $e');
    }
    return null;
  }

  static Future<String?> getCachedPdfPath(String bookTitle) async {
    final box = await Hive.openBox<String>(pdfsBox);
    return box.get(bookTitle);
  }

  static Future<List<Book>> getUnsyncedBooks() async {
    final box = await Hive.openBox<Book>(booksBox);
    return box.values.where((book) => !book.isSynced).toList();
  }

  static Future<void> markBooksAsSynced(List<Book> books) async {
    final box = await Hive.openBox<Book>(booksBox);
    for (var book in books) {
      final index = box.values.toList().indexWhere((b) => b.id == book.id);
      if (index != -1) {
        await box.putAt(index, book.copyWith(isSynced: true));
      }
    }
  }

  static Future<void> saveProgress(Map<String, int> progress) async {
    try {
      _cachedProgress = progress;
      final box = await Hive.openBox(userBox);
      await box.put('progress', progress);
      print('💾 Saved ${progress.length} progress entries to local storage');
    } catch (e) {
      print('⚠️ Error saving progress: $e');
    }
  }

  static Future<Map<String, int>> getProgress() async {
    final box = await Hive.openBox(userBox);
    return box.get('progress')?.cast<String, int>() ?? {};
  }

  static Future<void> updateBookProgress(String bookId, int positionSec) async {
    try {
      // Save to server
      final success = await ApiService.updateProgress(bookId, positionSec);
      if (!success) {
        throw Exception('Failed to update progress on server');
      }
      
      // Update local cache
      _cachedProgress[bookId] = positionSec;
      final userBox = await _getUserBox();
      await userBox.put('progress', _cachedProgress);
    } catch (e) {
      print('Error saving progress: $e');
      rethrow;
    }
  }

  static Future<void> syncProgress() async {
    try {
      // Get progress from server
      final userProfile = await ApiService.getUserProfile();
      if (userProfile != null && userProfile['progress'] != null) {
        final serverProgress = Map<String, int>.from(
          (userProfile['progress'] as List).fold<Map<String, int>>(
            {},
            (map, item) {
              map[item['audiobookId']] = item['positionSec'];
              return map;
            },
          ),
        );
        
        // Update local storage
        _cachedProgress = serverProgress;
        final userBox = await _getUserBox();
        await userBox.put('progress', serverProgress);
      }
    } catch (e) {
      print('Error syncing progress: $e');
      rethrow;
    }
  }
}