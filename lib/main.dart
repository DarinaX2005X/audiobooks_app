import 'package:audiobooks_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/personalize_screen.dart';
import 'screens/main_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/details_screen.dart';
import 'screens/text_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'constants/theme_constants.dart';
import 'models/book.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Books App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.darkBackground,
        fontFamily: AppTextStyles.albraFontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentRed,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/main', //splash
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/personalize': (context) => const PersonalizeScreen(),
        '/main': (context) => const AppNavigator(initialIndex: 0),
        '/search': (context) => const AppNavigator(initialIndex: 1),
        '/library': (context) => const AppNavigator(initialIndex: 2),
        '/profile': (context) => const AppNavigator(initialIndex: 3),
        '/forget_password': (context) => const ForgetPasswordScreen(),
        '/details': (context) => DetailsScreen(
          book: ModalRoute.of(context)!.settings.arguments as Book,
        ),
        '/text': (context) => const TextScreen(),
      },
    );
  }
}

class AppNavigator extends StatefulWidget {
  final int initialIndex;

  const AppNavigator({super.key, required this.initialIndex});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    MainScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    final routes = ['/main', '/search', '/library', '/profile'];
    Navigator.pushNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(13),
        decoration: const ShapeDecoration(
          color: Color(0xFF191714),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.accentRed,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 24),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 24),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}