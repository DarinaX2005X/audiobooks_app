import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTimeAndAuth();
  }

  // Check if it's the first time and authentication status
  Future<void> _checkFirstTimeAndAuth() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = !(prefs.getBool('seen_onboarding') ?? false);

    // Check authentication status
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (isFirstTime) {
      // First time user - show onboarding
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (isLoggedIn) {
      // Returning authenticated user - go to main screen
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      // Returning unauthenticated user - go to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Icon(Icons.headphones, size: 80, color: AppColors.accentRed),
            const SizedBox(height: 20),
            Text(
              'Audiobooks App',
              style: AppTextStyles.titleStyle.copyWith(
                color: const Color(0xFF191714),
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            CircularProgressIndicator(color: AppColors.accentRed),
          ],
        ),
      ),
    );
  }
}
