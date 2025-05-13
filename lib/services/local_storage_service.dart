import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class LocalStorageService {
  static const String bookBoxName = 'books';
  static const String categoryBoxName = 'categories';
  static const String pdfBoxName = 'pdfs';

  // Save books to Hive
  static Future<void> saveBooks(List<Book> books) async {
    final box = await Hive.openBox<Book>(bookBoxName);
    await box.clear();
    await box.addAll(books);
  }

  // Retrieve books from Hive
  static Future<List<Book>> getBooks() async {
    final box = await Hive.openBox<Book>(bookBoxName);
    return box.values.toList();
  }

  // Save categories to Hive
  static Future<void> saveCategories(List<String> categories) async {
    final box = await Hive.openBox<String>(categoryBoxName);
    await box.clear();
    await box.addAll(categories);
  }

  // Retrieve categories from Hive
  static Future<List<String>> getCategories() async {
    final box = await Hive.openBox<String>(categoryBoxName);
    return box.values.toList();
  }

  // Download and cache PDF locally
  static Future<String?> cachePdf(String pdfUrl, String bookTitle) async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200) {
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final pdfPath = '${dir.path}/pdfs/$bookTitle.pdf';
      final file = File(pdfPath);
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);

      final box = await Hive.openBox<String>(pdfBoxName);
      await box.put(bookTitle, pdfPath);
      return pdfPath;
    } catch (e) {
      print('Error caching PDF: $e');
      return null;
    }
  }

  // Retrieve cached PDF path
  static Future<String?> getCachedPdfPath(String bookTitle) async {
    final box = await Hive.openBox<String>(pdfBoxName);
    return box.get(bookTitle);
  }

  // Get unsynced books
  static Future<List<Book>> getUnsyncedBooks() async {
    final box = await Hive.openBox<Book>(bookBoxName);
    return box.values.where((book) => !book.isSynced).toList();
  }

  // Mark books as synced
  static Future<void> markBooksAsSynced(List<Book> books) async {
    final box = await Hive.openBox<Book>(bookBoxName);
    for (var book in books) {
      final index = box.values.toList().indexWhere((b) => b.title == book.title);
      if (index != -1) {
        book.isSynced = true;
        await box.putAt(index, book);
      }
    }
  }
}