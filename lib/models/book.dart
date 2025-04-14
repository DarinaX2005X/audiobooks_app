class Book {
  final String title;
  final String description;
  final String author;
  final String genre;
  final String fileName;
  final String coverUrl;

  Book({
    required this.title,
    required this.description,
    required this.author,
    required this.genre,
    required this.fileName,
    required this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      fileName: json['fileName'],
      description: json['description'],
      author: json['author']['name'], // nested "author.name"
      genre: json['category']['name'], // nested "category.name"
      coverUrl: json['coverUrl'] ?? '',
    );
  }
}
