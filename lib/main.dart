import 'package:audiobooks_app/services/auth_service.dart';
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
import 'services/settings_service.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  await Hive.openBox<Book>(LocalStorageService.bookBoxName);
  await Hive.openBox<String>(LocalStorageService.categoryBoxName);
  await Hive.openBox<String>(LocalStorageService.pdfBoxName);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await AuthService.init();
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();
    runApp(
      ChangeNotifierProvider(
        create: (_) => settingsProvider,
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
    runApp(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Audio Books App',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('kk'),
      ],
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF191714)),
          bodyMedium: TextStyle(color: Color(0xFF191714)),
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
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
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/personalize': (context) => const PersonalizeScreen(),
        '/main': (context) => const MainScreen(),
        '/forget_password': (context) => const ForgetPasswordScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/details': (context) => DetailsScreen(
          book: ModalRoute.of(context)!.settings.arguments as Book,
        ),
      },
    );
  }
}