import 'package:flutter/material.dart';
import '../services/api_servive.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'details_screen.dart';
import '../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Book> books = [];
  final List<String> categories = [];
  String selectedCategory = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (categories.isEmpty) {
      setState(() {
        categories.add('All'); // Hardcoded "All" instead of localized
        selectedCategory = 'All';
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedCategories = await ApiService.fetchCategories();
      final fetchedBooks = await ApiService.fetchBooks();

      setState(() {
        categories
          ..clear()
          ..add('All') // Hardcoded "All"
          ..addAll(fetchedCategories.map((category) => category.name));
        books
          ..clear()
          ..addAll(fetchedBooks);
        selectedCategory = 'All';
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).errorOccurred}: $e')),
        );
      }
    }
  }

  Widget _buildBookCover(Book book) {
    final coverUrl = book.coverUrl;
    if (coverUrl == null || coverUrl.isEmpty) {
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
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
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
      if (selectedCategory == 'All' || book.genre == selectedCategory) { // Hardcoded "All"
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
              AppLocalizations.of(context).noBooksInCategory(selectedCategory),
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
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
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
                                  AppLocalizations.of(context).heyUser('John'),
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
                                  category,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        currentScreen = LibraryScreen(
          onBack: () => setState(() => _selectedIndex = 0),
        );
        break;
      case 3:
        currentScreen = ProfileScreen(
          onBack: () => setState(() => _selectedIndex = 0),
        );
        break;
      default:
        currentScreen = _buildMainContent();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: currentScreen,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(13),
        decoration: ShapeDecoration(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          shadows: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
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
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}