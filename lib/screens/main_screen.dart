import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_servive.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import '../models/category.dart'; // Добавляем импорт
import '../services/auth_service.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'details_screen.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/local_storage_service.dart';
import 'dart:async';
import '../services/user_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Book> books = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];
  List<Category> categories = [];
  Category? selectedCategory;
  bool isGuest = false;
  bool isOffline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadCategories();
    _loadUserData();
    _checkGuestMode();
    _searchController.addListener(_filterBooks);
    _setupConnectivityListener();
    // Временный код для отладки Hive
    LocalStorageService.getBooks().then((books) {
      print('📦 Hive booksBox contains ${books.length} books:');
      for (var book in books) {
        print(' - ${book.title}, isFavorite: ${book.isFavorite}, progress: ${book.progressPage}');
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupConnectivityListener() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) async {
      final wasOffline = isOffline;
      setState(() {
        isOffline = result == ConnectivityResult.none;
      });
      if (wasOffline && !isOffline) {
        await _syncData();
        await _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      
      // First load from local storage
      final localBooks = await LocalStorageService.getBooks();
      setState(() {
        books.clear();
        books.addAll(localBooks);
      });

      // Then try to load from server if online
      if (!isOffline) {
        try {
          final loadedCategories = await ApiService.getCategories();
          final serverBooks = await ApiService.getBooks();
          setState(() {
            categories
              ..clear()
              ..addAll([Category(name: 'All'), ...loadedCategories]);
            books
              ..clear()
              ..addAll(serverBooks);
            selectedCategory = loadedCategories.isNotEmpty ? loadedCategories.first : null;
          });
        } catch (e) {
          print('⚠️ Error loading from server: $e');
          // If server load fails, keep local books
          if (books.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).offlineMode)),
            );
          }
        }
      } else {
        // If offline, try to load categories from local storage
        final localGenres = books.map((book) => book.genre).toSet().toList();
        final localCategories = localGenres.map((g) => Category(name: g)).toList();
        setState(() {
          categories
            ..clear()
            ..addAll([Category(name: 'All'), ...localCategories]);
          selectedCategory = localCategories.isNotEmpty ? localCategories.first : null;
        });
      }
    } catch (e) {
      print('⚠️ Error in _loadData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _syncData() async {
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).offlineCannotSync)),
      );
      return;
    }

    try {
      final unsyncedBooks = await LocalStorageService.getUnsyncedBooks();
      if (unsyncedBooks.isNotEmpty) {
        await ApiService.syncBooks(unsyncedBooks);
        await LocalStorageService.markBooksAsSynced(unsyncedBooks);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).syncSuccessful)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).syncFailed(e.toString()))),
      );
    }
  }

  Widget _buildBookCover(Book book) {
    final coverUrl = book.coverUrl ?? '';
    if (coverUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.book, size: 50),
      );
    }

    try {
      if (coverUrl.startsWith('http')) {
        return Image.network(
          coverUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, size: 50),
            );
          },
        );
      }
      return Image.asset(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.book, size: 50),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.error, size: 50),
      );
    }
  }

  List<Widget> _buildBookSections() {
    final theme = Theme.of(context);
    if (books.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(AppLocalizations.of(context).noBooksAvailable, style: theme.textTheme.bodyLarge),
          ),
        ),
      ];
    }

    Map<String, List<Book>> booksByGenre = {};
    for (var book in books) {
      if (selectedCategory?.name == 'All' || book.genre == selectedCategory!.name) {
        final genre = book.genre.isNotEmpty ? book.genre : 'Uncategorized';
        booksByGenre.putIfAbsent(genre, () => []).add(book);
      }
    }

    if (booksByGenre.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              selectedCategory?.name == 'All' 
                  ? AppLocalizations.of(context).noBooksAvailable
                  : AppLocalizations.of(context).noBooksInCategory(selectedCategory?.name ?? ''),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ];
    }

    List<Widget> sections = [];
    booksByGenre.forEach((genre, genreBooks) {
      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  genre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).seeAll,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: genreBooks.map((book) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(book: book),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 160,
                            height: 235,
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
                          const SizedBox(height: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 160,
                                child: Text(
                                  book.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: AppTextStyles.albraFontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 160,
                                child: Text(
                                  book.author,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                                    fontWeight: FontWeight.w400,
                                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
    return sections;
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 60),
                  decoration: BoxDecoration(color: theme.colorScheme.background),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const ShapeDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("images/user.png"),
                                        fit: BoxFit.fill,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      loc.heyUser('John'),
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontFamily: AppTextStyles.albraFontFamily,
                                        fontWeight: FontWeight.w500,
                                        height: 1.60,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _syncData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Text(loc.sync),
                                ),
                                const SizedBox(width: 8),
                                Container(
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
                                    Icons.notifications,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((category) {
                              bool isSelected = selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    decoration: ShapeDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.surface
                                          : theme.colorScheme.surface.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                    child: Text(
                                      category.name,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isSelected
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurface.withOpacity(0.7),
                                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          ..._buildBookSections(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: theme.colorScheme.error.withOpacity(0.9),
                padding: const EdgeInsets.all(8),
                child: Text(
                  loc.offlineMode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _checkGuestMode() async {
    return await AuthService.isGuestMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FutureBuilder<bool>(
          future: _checkGuestMode(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final isGuest = snapshot.data!;
            Widget currentScreen;

            switch (_selectedIndex) {
              case 0:
                currentScreen = _buildMainContent();
                break;
              case 1:
                currentScreen = SearchScreen(
                  onBack: () => setState(() => _selectedIndex = 0),
                );
                break;
              case 2:
                if (isGuest) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).guestAccessRestricted),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context).login,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  });
                  currentScreen = _buildMainContent();
                  _selectedIndex = 0;
                } else {
                  currentScreen = LibraryScreen(
                    onBack: () => setState(() => _selectedIndex = 0),
                  );
                }
                break;
              case 3:
                if (isGuest) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).guestAccessRestricted),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context).login,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  });
                  currentScreen = _buildMainContent();
                  _selectedIndex = 0;
                } else {
                  currentScreen = ProfileScreen(
                    onBack: () => setState(() => _selectedIndex = 0),
                  );
                }
                break;
              default:
                currentScreen = _buildMainContent();
            }

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: currentScreen,
              bottomNavigationBar: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(13),
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 0),
                    _buildNavItem(Icons.search, 1),
                    _buildNavItem(Icons.favorite, 2),
                    _buildNavItem(Icons.person, 3),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final theme = Theme.of(context);
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // First try to load from local storage
      final localBooks = await LocalStorageService.getBooks();
      if (localBooks.isNotEmpty) {
        setState(() {
          books = localBooks;
          _filteredBooks = localBooks;
          isLoading = false;
        });
      }

      // Then try to sync with server
      final serverBooks = await ApiService.getBooks();
      
      if (serverBooks != null && serverBooks.isNotEmpty) {
        // Merge server books with local books, preserving local favorites
        final mergedBooks = serverBooks.map((serverBook) {
          final localBook = localBooks.firstWhere(
            (local) => local.id == serverBook.id,
            orElse: () => serverBook,
          );
          return serverBook.copyWith(
            isFavorite: localBook.isFavorite,
          );
        }).toList();

        await LocalStorageService.saveBooks(mergedBooks);
        
        if (mounted) {
          setState(() {
            books = mergedBooks;
            _filteredBooks = mergedBooks;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading books: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await ApiService.getCategories();
      if (loadedCategories.isNotEmpty && mounted) {
        setState(() {
          categories = [Category(name: 'All'), ...loadedCategories];
          selectedCategory = categories.firstWhere((cat) => cat.name == 'All');
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Set default category to 'All' even if loading fails
      if (mounted) {
        setState(() {
          categories = [Category(name: 'All')];
          selectedCategory = categories.first;
        });
      }
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = books.where((book) {
        final matchesCategory = selectedCategory?.name == 'All' ||
            book.genre == selectedCategory!.name;
        return matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final result = await UserService.fetchUserProfile();
      if (result['success'] && mounted) {
        setState(() {
          _userName = result['user']['name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Widget _buildHomeTab() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.heyUser(_userName),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      bool isSelected = selectedCategory?.name == category.name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                            _filterBooks();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: ShapeDecoration(
                              color: isSelected
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surface.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                                fontFamily: AppTextStyles.albraGroteskFontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  ..._buildBookSections(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    return const LibraryScreen();
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
  }
}