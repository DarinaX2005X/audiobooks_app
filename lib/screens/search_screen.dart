import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SearchScreen({super.key, this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Book> searchResults = [
    Book(title: 'Sorcerer’s Stone', author: 'J.K Rowling', genre: 'Fantasy', coverUrl: 'images/book1.png'),
    Book(title: 'Chamber of Secrets', author: 'J.K Rowling', genre: 'Fantasy', coverUrl: 'images/book2.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EEE3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.pop(context), // Use onBack if provided, else pop
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF191714),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Text(
                      'Search',
                      style: TextStyle(
                        color: Color(0xFF191714),
                        fontSize: 16,
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF191714),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore',
                      style: TextStyle(
                        color: Color(0xFF010103),
                        fontSize: 24,
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 335,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const ShapeDecoration(
                        color: Color(0xFFF5F5FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search Books or Author...',
                          hintStyle: TextStyle(
                            color: Color(0xFFB8B8C7),
                            fontSize: 14,
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isSearching = value.isNotEmpty;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isSearching) ...[
                      const Text(
                        'Recommended genres',
                        style: TextStyle(
                          color: Color(0xFF010103),
                          fontSize: 16,
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGenreRow(['Fantasy', 'Drama']),
                      const SizedBox(height: 15),
                      _buildGenreRow(['Fiction', 'Detective']),
                      const SizedBox(height: 20),
                      const Text(
                        'Latest search',
                        style: TextStyle(
                          color: Color(0xFF010103),
                          fontSize: 16,
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBookRow(Book(title: 'Moby Dick', author: 'Herman Melville', genre: 'Drama', coverUrl: 'images/book1.png')),
                    ] else ...[
                      const Text(
                        'Search results',
                        style: TextStyle(
                          color: Color(0xFF010103),
                          fontSize: 16,
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...searchResults.map((book) => _buildBookRow(book)).toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreRow(List<String> genres) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: genres.map((genre) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 7.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const ShapeDecoration(
              color: Color(0xFFE7E0CB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: Center(
              child: Text(
                genre,
                style: const TextStyle(
                  color: Color(0xFF191815),
                  fontSize: 16,
                  fontFamily: AppTextStyles.albraGroteskFontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookRow(Book book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailsScreen(book: book)),
          );
        },
        child: Row(
          children: [
            Container(
              width: 160,
              height: 235,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 22,
                    offset: Offset(-12, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Image.asset(
                book.coverUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: Color(0xFF191714),
                    fontSize: 16,
                    fontFamily: AppTextStyles.albraFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  book.author,
                  style: const TextStyle(
                    color: Color(0xFF191714),
                    fontSize: 14,
                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}