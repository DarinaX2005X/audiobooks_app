import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'pin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('🔄 SplashScreen: Starting initialization...');
    try {
      // Инициализируем AuthService
      await AuthService.init();
      debugPrint('🔄 SplashScreen: AuthService initialized');

      // Проверяем подключение к интернету
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      debugPrint('🌐 SplashScreen: Internet connection status: ${isOnline ? "Online" : "Offline"}');

      if (!isOnline) {
        debugPrint('🌐 SplashScreen: No internet connection, checking for PIN code...');
        final hasPin = await AuthService.hasPinSet();
        
        if (hasPin) {
          debugPrint('🔐 SplashScreen: PIN code found, showing PIN screen');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PinScreen(
                  onSuccess: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                ),
              ),
            );
            return;
          }
        } else {
          debugPrint('❌ SplashScreen: No PIN code found for offline access');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
          return;
        }
      }

      // Проверяем статус авторизации
      final isLoggedIn = await AuthService.isLoggedIn();
      debugPrint('🔑 SplashScreen: Login status: ${isLoggedIn ? "Logged in" : "Not logged in"}');

      if (mounted) {
        if (isLoggedIn) {
          debugPrint('🔑 SplashScreen: User is logged in, navigating to main screen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          debugPrint('🔑 SplashScreen: User is not logged in, navigating to login screen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ SplashScreen: Error during initialization: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.appTitle,
              style: theme.textTheme.displaySmall?.copyWith(
                fontFamily: AppTextStyles.albraFontFamily,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}