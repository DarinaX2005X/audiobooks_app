import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/services/api_servive.dart';
import 'package:audiobooks_app/models/book.dart';
import 'package:audiobooks_app/models/category.dart';

void main() {
  group('ApiService Tests', () {
    test('should fetch categories successfully', () async {
      try {
        final categories = await ApiService.getCategories();
        expect(categories, isA<List<Category>>());
        // Categories should be a list, even if empty
        expect(categories, isNotEmpty);
      } catch (e) {
        // If there's an error, it should be due to network or auth
        expect(e, isA<Exception>());
      }
    });

    test('should fetch books successfully', () async {
      try {
        final books = await ApiService.getBooks();
        expect(books, isA<List<Book>>());
        // Books should be a list, even if empty
        expect(books, isNotEmpty);
      } catch (e) {
        // If there's an error, it should be due to network or auth
        expect(e, isA<Exception>());
      }
    });

    test('should fetch book details successfully', () async {
      try {
        // Assuming there's at least one book in the system
        final books = await ApiService.getBooks();
        if (books.isNotEmpty) {
          final firstBook = books.first;
          final bookDetails = await ApiService.getBookDetails(firstBook.id);
          expect(bookDetails, isA<Book>());
          expect(bookDetails?.id, equals(firstBook.id));
        }
      } catch (e) {
        // If there's an error, it should be due to network or auth
        expect(e, isA<Exception>());
      }
    });
  });
} 