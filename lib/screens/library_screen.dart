import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
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
    _filteredBooks = savedBooks;
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
        _filteredBooks = savedBooks.where((book) {
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Widget _buildBookCover(Book book) {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.book, size: 24),
      );
    }

    try {
      if (book.coverUrl!.startsWith('http')) {
        // Network image
        return Image.network(
          book.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 24),
            );
          },
        );
      } else {
        // Asset image
        return Image.asset(
          book.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 24),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.error, size: 24),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button, title, and filter icon
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: theme.colorScheme.onBackground,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        child: Icon(Icons.arrow_back, color: theme.colorScheme.background),
                      ),
                    ),
                    Text(
                      loc.favorites,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.onBackground,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: Icon(Icons.filter_list, color: theme.colorScheme.background),
                    ),
                  ],
                ),
              ),
              // Title and search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.savedBooks,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: loc.searchBooksOrAuthor,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  ],
                ),
              ),
              // List of filtered books
              _filteredBooks.isEmpty
                  ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: Text(
                    loc.noBooksFound,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
                  : SizedBox(
                height: MediaQuery.of(context).size.height * 0.5, // Constrain height
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(), // Prevent overscroll
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                  itemCount: _filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = _filteredBooks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: book,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: ShapeDecoration(
                            color: theme.colorScheme.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2, // Responsive width
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildBookCover(book),
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontFamily: AppTextStyles.albraFontFamily,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      book.author,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                                        fontWeight: FontWeight.w400,
                                        color: theme.colorScheme.onBackground.withOpacity(0.7),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Extra space for navbar
            ],
          ),
        ),
      ),
    );
  }
}