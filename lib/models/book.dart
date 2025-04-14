class Book {
  final String title;
  final String description;
  final String fileName;
  final String coverUrl;
  final String author;
  final String genre;
  Book({
    required this.title,
    required this.description,
    required this.author,
    required this.genre,
    required this.fileName,
    required this.coverUrl,
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
    );
  }
}
