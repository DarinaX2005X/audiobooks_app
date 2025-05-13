import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final String coverUrl;

  @HiveField(4)
  final String author;

  @HiveField(5)
  final String genre;

  @HiveField(6)
  final String pdfUrl;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  bool? isFavorite;

  Book({
    required this.title,
    required this.description,
    required this.author,
    required this.genre,
    required this.fileName,
    required this.coverUrl,
    required this.pdfUrl,
    this.isSynced = true,
    this.isFavorite = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    String authorName = '';
    if (json['author'] != null) {
      if (json['author'] is Map) {
        authorName = json['author']['name'] ?? '';
      } else if (json['author'] is String) {
        authorName = json['author'];
      }
    }

    String categoryName = '';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        categoryName = json['category']['name'] ?? '';
      } else if (json['category'] is String) {
        categoryName = json['category'];
      }
    }

    return Book(
      title: json['title'] ?? '',
      fileName: json['fileName'] ?? '',
      description: json['description'] ?? '',
      author: authorName,
      genre: categoryName,
      coverUrl: json['coverUrl'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      isSynced: json['isSynced'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'author': author,
    'genre': genre,
    'fileName': fileName,
    'coverUrl': coverUrl,
    'pdfUrl': pdfUrl,
    'isSynced': isSynced,
    'isFavorite': isFavorite,
  };
}