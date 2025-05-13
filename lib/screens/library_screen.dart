import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'details_screen.dart';
import 'login_screen.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LibraryScreen({super.key, this.onBack});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> savedBooks = [];
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];
  bool isLoading = true;
  bool? isGuest;

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _initialize() async {
    setState(() {
      isLoading = true;
    });
    final guest = await AuthService.isGuestMode();
    final books = await LocalStorageService.getBooks();
    if (mounted) {
      setState(() {
        isGuest = guest;
        savedBooks = books.where((book) => book.isFavorite ?? false).toList();
        _filteredBooks = savedBooks;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    if (isGuest == null || isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isGuest!) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            loc.favorites,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppTextStyles.albraGroteskFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: theme.colorScheme.background,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: widget.onBack ?? () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.guestAccessRestricted,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: Text(
                      loc.login,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      width: MediaQuery.of(context).size.width * 0.9,
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
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
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
                              builder: (context) => DetailsScreen(book: book),
                            ),
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
                                width: MediaQuery.of(context).size.width * 0.2,
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}