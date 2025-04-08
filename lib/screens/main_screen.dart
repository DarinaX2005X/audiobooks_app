import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Book> books = [
    Book(title: 'Moby Dick', author: 'Herman Melville', genre: 'Drama', coverUrl: 'images/book1.png'),
    Book(title: 'Annihilation', author: 'Jeff VanderMeer', genre: 'Drama', coverUrl: 'images/book2.png'),
    Book(title: 'The Hound of the Baskervilles', author: 'Arthur Conan Doyle', genre: 'Detective', coverUrl: 'images/book3.png'),
    Book(title: 'The Big Sleep', author: 'Raymond Chandler', genre: 'Detective', coverUrl: 'images/book4.png'),
    Book(title: 'Pride and Prejudice', author: 'Jane Austen', genre: 'Drama', coverUrl: 'images/book5.png'),
    Book(title: 'The Name of the Rose', author: 'Umberto Eco', genre: 'Detective', coverUrl: 'images/book6.png'),
    Book(title: 'To Kill a Mockingbird', author: 'Harper Lee', genre: 'Drama', coverUrl: 'images/book7.png'),
    Book(title: 'The Maltese Falcon', author: 'Dashiell Hammett', genre: 'Detective', coverUrl: 'images/book8.png'),
    Book(title: 'Gone with the Wind', author: 'Margaret Mitchell', genre: 'Drama', coverUrl: 'images/book9.png'),
    Book(title: 'And Then There Were None', author: 'Agatha Christie', genre: 'Detective', coverUrl: 'images/book10.png'),
  ];

  final List<String> categories = ['All', 'Detective', 'Drama', 'Historical'];
  String selectedCategory = 'All';

  final List<Widget> _screens = [
    Container(), // Placeholder for Main content
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _screens[0] = _buildMainContent();
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 375,
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
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
                  ..._buildBookSections(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookSections() {
    Map<String, List<Book>> booksByGenre = {};
    for (var book in books) {
      if (selectedCategory == 'All' || book.genre == selectedCategory) {
        booksByGenre.putIfAbsent(book.genre, () => []).add(book);
      }
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
                            child: Image.asset(
                              book.coverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  color: Color(0xFF191714),
                                  fontSize: 16,
                                  fontFamily: AppTextStyles.albraFontFamily,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                book.author,
                                style: const TextStyle(
                                  color: Color(0xFF191714),
                                  fontSize: 14,
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
    return Scaffold(
      body: _screens[_selectedIndex],
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