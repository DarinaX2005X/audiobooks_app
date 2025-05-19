import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String author;

  @HiveField(2)
  final String genre;

  @HiveField(3)
  final String? coverUrl;

  @HiveField(4)
  final String? pdfUrl;

  @HiveField(5)
  final bool isSynced;

  @HiveField(6)
  final String id;

  @HiveField(7)
  final bool? isFavorite;

  @HiveField(8)
  final int? progressPage;

  @HiveField(9)
  final String? description;

  @HiveField(10)
  final String? fileName;

  Book({
    required this.title,
    required this.author,
    required this.genre,
    this.coverUrl,
    this.pdfUrl,
    required this.isSynced,
    required this.id,
    this.isFavorite,
    this.progressPage,
    this.description,
    this.fileName,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title']?.toString() ?? '',
      author: json['author'] is Map<String, dynamic>
          ? json['author']['name']?.toString() ?? ''
          : json['author']?.toString() ?? '',
      genre: json['category'] is Map<String, dynamic>
          ? json['category']['name']?.toString() ?? ''
          : json['genre']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString(),
      pdfUrl: json['pdfUrl']?.toString(),
      isSynced: json['isSynced'] is bool
          ? json['isSynced']
          : json['isSynced'] == 'true',
      id: json['id']?.toString() ?? '',
      isFavorite: json['isFavorite'] is bool
          ? json['isFavorite']
          : json['isFavorite'] == 'true',
      progressPage: (json['progressPage'] as num?)?.toInt(),
      description: json['description']?.toString(),
      fileName: json['fileName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'coverUrl': coverUrl,
      'pdfUrl': pdfUrl,
      'isSynced': isSynced,
      'id': id,
      'isFavorite': isFavorite,
      'progressPage': progressPage,
      'description': description,
      'fileName': fileName,
    };
  }

  Book copyWith({
    String? title,
    String? author,
    String? genre,
    String? coverUrl,
    String? pdfUrl,
    bool? isSynced,
    String? id,
    bool? isFavorite,
    int? progressPage,
    String? description,
    String? fileName,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      coverUrl: coverUrl ?? this.coverUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isSynced: isSynced ?? this.isSynced,
      id: id ?? this.id,
      isFavorite: isFavorite ?? this.isFavorite,
      progressPage: progressPage ?? this.progressPage,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
    );
  }
}