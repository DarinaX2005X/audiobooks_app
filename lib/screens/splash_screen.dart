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

  Future<void> _checkFirstTimeAndAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = !(prefs.getBool('seen_onboarding') ?? false);
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.headphones, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Audiobooks App',
              style: theme.textTheme.displaySmall?.copyWith(
                fontFamily: AppTextStyles.albraFontFamily,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
