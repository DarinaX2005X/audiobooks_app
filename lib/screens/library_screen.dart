import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/api_servive.dart';
import 'details_screen.dart';
import 'login_screen.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LibraryScreen({super.key, this.onBack});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> _books = [];
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];
  bool _isLoading = true;
  bool _isGuest = false;
  String? _error;
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _initialize() async {
    try {
      print('📚 LibraryScreen: Initializing...');
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final isGuest = await AuthService.isGuestMode();
      print('📚 LibraryScreen: Is guest mode: $isGuest');
      
      List<Book> books = [];
      if (!isGuest) {
        try {
          print('📚 LibraryScreen: Fetching user profile...');
          final profile = await ApiService.getUserProfile();
          print('📚 LibraryScreen: Got user profile: $profile');
          
          if (mounted) {
            final favorites = (profile['favorites'] as List?) ?? [];
            print('📚 LibraryScreen: Favorites from server: $favorites');
            
            final favoriteIds = favorites.map((fav) {
              if (fav is Map) {
                final audiobookId = fav['audiobookId'] as String;
                print('📚 LibraryScreen: Found favorite ID: $audiobookId');
                return audiobookId;
              }
              return '';
            }).where((id) => id.isNotEmpty).toList();
            print('📚 LibraryScreen: Favorite IDs: $favoriteIds');
            
            setState(() {
              _favoriteIds = favoriteIds;
            });
          }
        } catch (e) {
          print('⚠️ LibraryScreen: Error fetching user profile: $e');
          if (mounted) {
            setState(() {
              _error = e.toString();
            });
          }
        }
      }

      print('📚 LibraryScreen: Fetching books...');
      books = await ApiService.getBooks();
      print('📚 LibraryScreen: Got ${books.length} books');
      
      if (mounted) {
        final filteredBooks = books.where((book) => _favoriteIds.contains(book.id)).toList();
        print('📚 LibraryScreen: Filtered books count: ${filteredBooks.length}');
        setState(() {
          _books = filteredBooks;
          _filteredBooks = filteredBooks;
          _isGuest = isGuest;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('⚠️ LibraryScreen: Error initializing: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _refreshBooks() async {
    try {
      print('📚 LibraryScreen: Refreshing books...');
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Book> books = [];
      if (!_isGuest) {
        try {
          print('📚 LibraryScreen: Fetching user profile...');
          final profile = await ApiService.getUserProfile();
          print('📚 LibraryScreen: Got user profile: $profile');
          
          if (mounted) {
            final favorites = (profile['favorites'] as List?) ?? [];
            print('📚 LibraryScreen: Favorites from server: $favorites');
            
            final favoriteIds = favorites.map((fav) {
              if (fav is Map) {
                final audiobookId = fav['audiobookId'] as String;
                print('📚 LibraryScreen: Found favorite ID: $audiobookId');
                return audiobookId;
              }
              return '';
            }).where((id) => id.isNotEmpty).toList();
            print('📚 LibraryScreen: Favorite IDs: $favoriteIds');
            
            setState(() {
              _favoriteIds = favoriteIds;
            });
          }
        } catch (e) {
          print('⚠️ LibraryScreen: Error fetching user profile: $e');
          if (mounted) {
            setState(() {
              _error = e.toString();
            });
          }
        }
      }

      print('📚 LibraryScreen: Fetching books...');
      books = await ApiService.getBooks();
      print('📚 LibraryScreen: Got ${books.length} books');
      
      if (mounted) {
        final filteredBooks = books.where((book) => _favoriteIds.contains(book.id)).toList();
        print('📚 LibraryScreen: Filtered books count: ${filteredBooks.length}');
        setState(() {
          _books = filteredBooks;
          _filteredBooks = filteredBooks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('⚠️ LibraryScreen: Error refreshing books: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
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
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books.where((book) {
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

    return FutureBuilder<bool>(
      future: AuthService.isGuestMode(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final isGuest = snapshot.data!;

        if (isGuest) {
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
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(loc.login),
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
            child: RefreshIndicator(
              onRefresh: _refreshBooks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                color: theme.colorScheme.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                ),
                              ),
                              child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
                              color: theme.colorScheme.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                            child: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
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
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (_filteredBooks.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 48,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      loc.noSavedBooks,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = _filteredBooks[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsScreen(book: book),
                                      ),
                                    ).then((_) => _refreshBooks());
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.shadowColor.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: _buildBookCover(book),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        book.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontFamily: AppTextStyles.albraFontFamily,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        book.author,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}