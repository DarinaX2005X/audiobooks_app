import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/api_servive.dart';
import '../services/local_storage_service.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SearchScreen({super.key, this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isSearching = false;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = [];
  List<Book> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterResults);
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // First try to load from local storage
      final localBooks = await LocalStorageService.getBooks();
      if (localBooks.isNotEmpty) {
        setState(() {
          _allBooks = localBooks;
          _filteredResults = localBooks;
        });
      }

      // Then try to sync with server
      final serverBooks = await ApiService.getBooks();

      if (serverBooks.isNotEmpty && mounted) {
        // Create a map of local books by ID for faster lookup
        final localBooksMap = {for (var book in localBooks) book.id: book};

        // Merge server books with local books, preserving local favorites
        final mergedBooks =
            serverBooks.map((serverBook) {
              final localBook = localBooksMap[serverBook.id];
              return localBook != null
                  ? serverBook.copyWith(isFavorite: localBook.isFavorite)
                  : serverBook;
            }).toList();

        setState(() {
          _allBooks = mergedBooks;
          _filterResults(); // Apply any existing search filter
        });
      }
    } catch (e) {
      debugPrint('Error loading books: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load books. Please check your connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredResults = _allBooks;
      } else {
        _filteredResults =
            _allBooks.where((book) {
              return book.title.toLowerCase().contains(query) ||
                  book.author.toLowerCase().contains(query) ||
                  book.genre.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _filterByGenre(String genre) {
    setState(() {
      _filteredResults =
          _allBooks
              .where((book) => book.genre.toLowerCase() == genre.toLowerCase())
              .toList();
      isSearching = true;
    });
  }

  Widget _buildBookCover(Book book) {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(child: Icon(Icons.book, size: 40)),
      );
    }

    try {
      if (book.coverUrl!.startsWith('http')) {
        return Image.network(
          book.coverUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 40),
              ),
            );
          },
        );
      }
      return Image.asset(
        book.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: Icon(Icons.book, size: 40)),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(child: Icon(Icons.error, size: 40)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
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
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    loc.search,
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

            // Search input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: loc.searchBooksOrAuthor,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20), // Search results or initial content
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: _loadBooks,
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_errorMessage != null)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      _errorMessage!,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontFamily:
                                                AppTextStyles
                                                    .albraGroteskFontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: theme.colorScheme.error,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else if (!isSearching) ...[
                                Text(
                                  loc.recommendedGenres,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily:
                                        AppTextStyles.albraGroteskFontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildGenreRow([
                                  loc.genreFantasy,
                                  loc.genreDrama,
                                ]),
                                const SizedBox(height: 15),
                                _buildGenreRow([
                                  loc.genreFiction,
                                  loc.genreDetective,
                                ]),
                              ] else ...[
                                Text(
                                  loc.searchResults,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily:
                                        AppTextStyles.albraGroteskFontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_filteredResults.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        loc.noResultsFound,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontFamily:
                                                  AppTextStyles
                                                      .albraGroteskFontFamily,
                                              fontWeight: FontWeight.w400,
                                            ),
                                        textAlign: TextAlign.center,
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
                      ),
            ),
          ],
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
          return GestureDetector(
            onTap: () => _filterByGenre(genre),
            child: Container(
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
              width: 100,
              height: 148,
              decoration: ShapeDecoration(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.genre,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
