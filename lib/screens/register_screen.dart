import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import 'login_screen.dart';
import 'personalize_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EEE3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register',
                style: AppTextStyles.titleStyle.copyWith(color: const Color(0xFF191714)),
              ),
              const SizedBox(height: 20),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isAccepted,
                    onChanged: (value) {
                      setState(() {
                        _isAccepted = value ?? false;
                      });
                    },
                    activeColor: AppColors.accentRed,
                  ),
                  Flexible(
                    child: Text(
                      'By signing up, you agree to the Terms, Data Policy and Cookies Policy.',
                      style: const TextStyle(
                        color: Color(0xFF191714),
                        fontSize: 12,
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isAccepted
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalizeScreen()),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonRed,
                  disabledBackgroundColor: Colors.grey[400], // Grey when disabled
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: Text(
                  'Register',
                  style: AppTextStyles.buttonTextStyle.copyWith(
                    color: _isAccepted ? Colors.white : Colors.grey[700], // Grey text when disabled
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Login',
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