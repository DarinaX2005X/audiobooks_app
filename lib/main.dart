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
      initialRoute: '/splash', // Changed initial route to splash screen
      routes: {
        '/splash':
            (context) => const SplashScreen(), // Added splash screen route
        '/onboarding':
            (context) =>
                const OnboardingScreen(), // Changed from '/' to '/onboarding'
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/personalize': (context) => const PersonalizeScreen(),
        '/main': (context) => const MainScreen(),
        '/forget_password': (context) => const ForgetPasswordScreen(),
        '/details':
            (context) => DetailsScreen(
              book: ModalRoute.of(context)!.settings.arguments as Book,
            ),
        '/text': (context) => const TextScreen(),
      },
    );
  }
}
