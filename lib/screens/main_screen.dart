import 'package:flutter/material.dart';
import '../services/api_servive.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Book> books = [];
  final List<String> categories = ['All'];
  String selectedCategory = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedCategories = await ApiService.fetchCategories();
      final fetchedBooks = await ApiService.fetchBooks();

      setState(() {
        categories.clear();
        categories.add('All');
        categories.addAll(fetchedCategories.map((category) => category.name));

        books.clear();
        books.addAll(fetchedBooks);

        isLoading = false;
        print('isLoading state after data fetch: $isLoading');
      });

      print('Data loaded: ${categories.length} categories, ${books.length} books');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

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
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
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
                                          fontFamily: AppTextStyles.albraFontFamily,
                                          fontWeight: FontWeight.w500,
                                          height: 1.60,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'John!\n',
                                        style: TextStyle(
                                          color: AppColors.accentRed,
                                          fontSize: 24,
                                          fontFamily: AppTextStyles.albraFontFamily,
                                          fontWeight: FontWeight.w500,
                                          height: 1.60,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'What will you listen today?',
                                        style: TextStyle(
                                          color: Color(0xFF272A34),
                                          fontSize: 24,
                                          fontFamily: AppTextStyles.albraFontFamily,
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
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                          child: const Icon(Icons.notifications, color: Colors.white),
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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                decoration: ShapeDecoration(
                                  color: isSelected ? const Color(0xFF191714) : const Color(0xFFE6DFCA),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFFF1EEE3) : const Color(0xFF191714),
                                    fontSize: 14,
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
                    else if (books.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No books available'),
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

  Widget _buildBookCover(Book book) {
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
    print('Building book sections with ${books.length} books, selectedCategory: $selectedCategory');
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

    Map<String, List<Book>> booksByGenre = {};
    for (var book in books) {
      print('Processing book: ${book.title}, Genre: ${book.genre}');
      if (selectedCategory == 'All' || book.genre == selectedCategory) {
        final genre = book.genre.isNotEmpty ? book.genre : 'Uncategorized';
        booksByGenre.putIfAbsent(genre, () => []).add(book);
      }
      print('Number of genres after filtering: ${booksByGenre.length}');
      print('Total books after filtering: ${booksByGenre.values.expand((i) => i).length}');
    }

    print('Grouped books by genre: ${booksByGenre.keys.toList()}');
    if (booksByGenre.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('No books found in the "$selectedCategory" category'),
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
                children: genreBooks.map((book) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/details', arguments: book);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 160,
                            height: 235,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  style: const TextStyle(
                                    color: Color(0xFF191714),
                                    fontSize: 14,
                                    fontFamily: AppTextStyles.albraGroteskFontFamily,
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
    return _buildMainContent();
  }
}