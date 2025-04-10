import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRemembered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title for the login screen
              Text(
                'Login',
                style: AppTextStyles.titleStyle.copyWith(color: const Color(0xFF191714)),
              ),
              const SizedBox(height: 20),
              // Email input field
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Email',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB8B8C7),
                    fontSize: 14,
                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Password input field
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB8B8C7),
                    fontSize: 14,
                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              // Remember me checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isRemembered,
                    onChanged: (value) {
                      setState(() {
                        _isRemembered = value ?? false;
                      });
                    },
                    activeColor: AppColors.accentRed,
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(
                      color: Color(0xFF191714),
                      fontSize: 14,
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Login button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Login',
                  style: AppTextStyles.buttonTextStyle,
                ),
              ),
              const SizedBox(height: 10),
              // Register link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: Text(
                  'Don\'t have an account? Register',
                  style: AppTextStyles.buttonTextStyle.copyWith(
                    color: AppColors.accentRed,
                  ),
                ),
              ),
              // Forget password link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                  );
                },
                child: Text(
                  'Forget Password?',
                  style: AppTextStyles.buttonTextStyle.copyWith(
                    color: AppColors.accentRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}