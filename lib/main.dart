import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/personalize_screen.dart';
import 'screens/main_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/details_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'constants/theme_constants.dart';
import 'models/book.dart';
import 'models/category.dart';
import 'services/settings_service.dart';
import 'services/local_storage_service.dart';
import 'package:audiobooks_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive first
    await Hive.initFlutter();
    Hive.registerAdapter(BookAdapter());
    await Hive.openBox(LocalStorageService.userBox);
    print('✅ Hive initialized successfully');

    // Initialize services in correct order
    await AuthService.init();
    print('✅ AuthService initialized successfully');

    await LocalStorageService.init();
    print('✅ LocalStorageService initialized successfully');

    // Initialize settings provider
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();
    print('✅ SettingsProvider initialized successfully');

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
          Provider.value(value: AuthService()),
          Provider.value(value: LocalStorageService()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('❌ Error during initialization: $e');
    // Show error screen or handle initialization failure
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize app: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  double _getFontSize(String size) {
    switch (size) {
      case 'small':
        return 14.0;
      case 'large':
        return 18.0;
      case 'medium':
      default:
        return 16.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final fontSize = _getFontSize(settings.fontSize);

    return MaterialApp(
      title: 'Audio Books App',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1EEE3),
        fontFamily: AppTextStyles.albraFontFamily,
        colorScheme: ColorScheme.light(
          primary: AppColors.accentRed,
          secondary: AppColors.accentRed,
          background: const Color(0xFFF1EEE3),
          surface: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 20,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          displayMedium: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 16,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          displaySmall: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 12,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          headlineLarge: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 10,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          headlineMedium: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 8,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          headlineSmall: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 6,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          titleLarge: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 4,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          titleMedium: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize + 2,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          titleSmall: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          bodyLarge: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          bodyMedium: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize - 2,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          bodySmall: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize - 4,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          labelLarge: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          labelMedium: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize - 2,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          labelSmall: TextStyle(
            color: const Color(0xFF191714),
            fontSize: fontSize - 4,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF191714)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF191714),
        fontFamily: AppTextStyles.albraFontFamily,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accentRed,
          secondary: AppColors.accentRed,
          background: const Color(0xFF191714),
          surface: const Color(0xFF292929),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 20,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 16,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          displaySmall: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 12,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 10,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 8,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 6,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 4,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 2,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          titleSmall: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: fontSize - 2,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          bodySmall: TextStyle(
            color: Colors.white,
            fontSize: fontSize - 4,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          labelLarge: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          labelMedium: TextStyle(
            color: Colors.white,
            fontSize: fontSize - 2,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
          labelSmall: TextStyle(
            color: Colors.white,
            fontSize: fontSize - 4,
            fontFamily: AppTextStyles.albraFontFamily,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final book = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (context) => DetailsScreen(book: book),
          );
        }
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/personalize': (context) => const PersonalizeScreen(),
        '/main': (context) => const MainScreen(),
        '/forget-password': (context) => const ForgetPasswordScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
