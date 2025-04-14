import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'details_screen.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LibraryScreen({super.key, this.onBack});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // List of saved books
  final List<Book> savedBooks = [
    // Book(title: 'The Black Witch', author: 'Laurie Forest', genre: 'Fantasy', coverUrl: 'images/book1.png'),
    // Book(title: 'A Promised Land', author: 'Barrack Obama', genre: 'Non-Fiction', coverUrl: 'images/book2.png'),
    // Book(title: 'Harry Potter and the Prisoner of Azkaban', author: 'J.K. Rowling', genre: 'Fantasy', coverUrl: 'images/book3.png'),
    // Book(title: 'The Kidnapper’s Accomplice', author: 'C. J. Archer', genre: 'Mystery', coverUrl: 'images/book4.png'),
    // Book(title: 'Light Mage', author: 'Author Name', genre: 'Fantasy', coverUrl: 'images/book5.png'),
  ];

  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _filteredBooks = savedBooks; // Initially show all books
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filters books based on the search query
  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = savedBooks;
      } else {
        _filteredBooks =
            savedBooks.where((book) {
              return book.title.toLowerCase().contains(query) ||
                  book.author.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button, title, and filter icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.pop(context),
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
                    'Favorites',
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
            // Title and search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved books',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
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
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Scrollable list of filtered books using ListView.builder for efficiency
            Expanded(
              child:
                  _filteredBooks.isEmpty
                      ? const Center(
                        child: Text(
                          'No books found',
                          style: TextStyle(
                            color: Color(0xFF191714),
                            fontSize: 16,
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DetailsScreen(book: book),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(book.coverUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: const TextStyle(
                                              color: Color(0xFF010103),
                                              fontSize: 16,
                                              fontFamily:
                                                  AppTextStyles.albraFontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            book.author,
                                            style: const TextStyle(
                                              color: Color(0xFF191815),
                                              fontSize: 14,
                                              fontFamily:
                                                  AppTextStyles
                                                      .albraGroteskFontFamily,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

