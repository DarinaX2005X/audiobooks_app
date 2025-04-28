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
  final List<Book> searchResults = [];
  List<Book> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _filteredResults = searchResults;
    _searchController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBookCover(Book book) {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.book, size: 50),
      );
    }

    try {
      if (book.coverUrl!.startsWith('http')) {
        return Image.network(
          book.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 50),
            );
          },
        );
      } else {
        return Image.asset(
          book.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 50),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.error, size: 50),
      );
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredResults = searchResults;
      } else {
        _filteredResults =
            searchResults.where((book) {
              return book.title.toLowerCase().contains(query) ||
                  book.author.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
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
                          color: theme.colorScheme.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'Search',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: theme.textTheme.headlineSmall?.copyWith(
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
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.9),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search Books or Author...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isSearching) ...[
                      Text(
                        'Recommended genres',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGenreRow(['Fantasy', 'Drama']),
                      const SizedBox(height: 15),
                      _buildGenreRow(['Fiction', 'Detective']),
                      const SizedBox(height: 20),
                      Text(
                        'Latest search',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBookRow(
                        Book(
                          title: 'Moby Dick',
                          author: 'Herman Melville',
                          genre: 'Drama',
                          coverUrl: 'images/book1.png',
                          description: 'descr',
                          fileName: 'filename',
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Search results',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_filteredResults.isEmpty)
                        Center(
                          child: Text(
                            'No results found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontFamily: AppTextStyles.albraGroteskFontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else
                        ..._filteredResults
                            .map((book) => _buildBookRow(book))
                            .toList(),
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
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 7.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: Center(
              child: Text(
                genre,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppTextStyles.albraGroteskFontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookRow(Book book) {
    final theme = Theme.of(context);
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
              decoration: ShapeDecoration(
                color: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                shadows: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 22,
                    offset: const Offset(-12, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildBookCover(book),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  book.author,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
