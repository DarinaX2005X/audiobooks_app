import 'package:flutter/material.dart';
import '../services/api_servive.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Book> books = [];
  final List<String> categories = ['All']; // Initialize with "All"
  String selectedCategory = 'All';
  bool isLoading = true;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load both books and categories
    _screens = [
      _buildMainContent(),
      SearchScreen(onBack: () => setState(() => _selectedIndex = 0)),
      LibraryScreen(onBack: () => setState(() => _selectedIndex = 0)),
      ProfileScreen(onBack: () => setState(() => _selectedIndex = 0)),
    ];
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // First load categories
      final fetchedCategories = await ApiService.fetchCategories();

      // Then load books
      final fetchedBooks = await ApiService.fetchBooks();

      setState(() {
        // Update categories
        categories.clear();
        categories.add('All'); // Always include "All" category
        categories.addAll(fetchedCategories.map((category) => category.name));

        // Update books
        books.clear();
        books.addAll(fetchedBooks);

        // Set loading to false
        isLoading = false;
        print('isLoading state after data fetch: $isLoading');
      });

      print(
        'Data loaded: ${categories.length} categories, ${books.length} books',
      );
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

 // Fix for the _buildMainContent method
Widget _buildMainContent() {
  return RefreshIndicator(
    onRefresh: _loadData,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(color: Color(0xFFF1EEE3)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User header section
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
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Hey, ',
                                      style: TextStyle(
                                        color: Color(0xFF272A34),
                                        fontSize: 24,
                                        fontFamily:
                                            AppTextStyles.albraFontFamily,
                                        fontWeight: FontWeight.w500,
                                        height: 1.60,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'John!\n',
                                      style: TextStyle(
                                        color: AppColors.accentRed,
                                        fontSize: 24,
                                        fontFamily:
                                            AppTextStyles.albraFontFamily,
                                        fontWeight: FontWeight.w500,
                                        height: 1.60,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'What will you listen today?',
                                      style: TextStyle(
                                        color: Color(0xFF272A34),
                                        fontSize: 24,
                                        fontFamily:
                                            AppTextStyles.albraFontFamily,
                                        fontWeight: FontWeight.w500,
                                        height: 1.60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF191714),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Categories section
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
                                    ? const Color(0xFF191714)
                                    : const Color(0xFFE6DFCA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    100,
                                  ),
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFFF1EEE3)
                                      : const Color(0xFF191714),
                                  fontSize: 14,
                                  fontFamily:
                                      AppTextStyles.albraGroteskFontFamily,
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

                  // Display loading indicator or content based on state
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (books.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No books available'),
                      ),
                    )
                  else
                    ..._buildBookSections(),  // Spread operator for list of widgets
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildBookCover(Book book) {
    // Safely handle the coverUrl
    final String coverUrl = book.coverUrl ?? '';

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
          // Show a placeholder while loading
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
          // Handle error gracefully
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, size: 50),
            );
          },
        );
      } else {
        return Image.asset(
          coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image: $error');
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 50),
            );
          },
        );
      }
    } catch (e) {
      print('Exception rendering cover: $e');
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.error, size: 50),
      );
    }
  }

  List<Widget> _buildBookSections() {
    print(
      'Building book sections with ${books.length} books, selectedCategory: $selectedCategory',
    );

    // If we have no books, show a message
    if (books.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No books available'),
          ),
        ),
      ];
    }

    // Group books by genre
    Map<String, List<Book>> booksByGenre = {};

    for (var book in books) {
      // Debug each book
      print('Processing book: ${book.title}, Genre: ${book.genre}');

      // Only filter books if 'All' is not selected
      if (selectedCategory == 'All' || book.genre == selectedCategory) {
        // Handle null or empty genre
        final genre = book.genre.isNotEmpty ? book.genre : 'Uncategorized';

        // Use putIfAbsent to create a new list if genre key doesn't exist
        booksByGenre.putIfAbsent(genre, () => []).add(book);
      }
print('Number of genres after filtering: ${booksByGenre.length}');
print('Total books after filtering: ${booksByGenre.values.expand((i) => i).length}');
    }

    print('Grouped books by genre: ${booksByGenre.keys.toList()}');

    // If no books match the category filter, show a message
    if (booksByGenre.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('No books found in the "${selectedCategory}" category'),
          ),
        ),
      ];
    }

    // Build UI sections for each genre
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
                  style: const TextStyle(
                    color: Color(0xFF191714),
                    fontSize: 18,
                    fontFamily: AppTextStyles.albraFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFFE36166),
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
                children:
                    genreBooks.map((book) {
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
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 22,
                                      offset: Offset(-12, 10),
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
                                      style: const TextStyle(
                                        color: Color(0xFF191714),
                                        fontSize: 16,
                                        fontFamily:
                                            AppTextStyles.albraFontFamily,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      book.author,
                                      style: const TextStyle(
                                        color: Color(0xFF191714),
                                        fontSize: 14,
                                        fontFamily:
                                            AppTextStyles
                                                .albraGroteskFontFamily,
                                        fontWeight: FontWeight.w400,
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

  @override
  Widget build(BuildContext context) {
    // Dynamically build the screen based on selected index
    Widget currentScreen;
    
    switch (_selectedIndex) {
      case 0:
        currentScreen = _buildMainContent();
        break;
      case 1:
        currentScreen = SearchScreen(onBack: () => setState(() => _selectedIndex = 0));
        break;
      case 2:
        currentScreen = LibraryScreen(onBack: () => setState(() => _selectedIndex = 0));
        break;
      case 3:
        currentScreen = ProfileScreen(onBack: () => setState(() => _selectedIndex = 0));
        break;
      default:
        currentScreen = _buildMainContent();
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(13),
        decoration: const ShapeDecoration(
          color: Color(0xFF191714),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
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
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Icon(
          icon,
          color: isSelected ? AppColors.accentRed : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
