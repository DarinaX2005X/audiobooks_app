import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme_constants.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.only(top: 73, bottom: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Onboarding title with highlighted "Genre"
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.titleStyle,
                      children: [
                        const TextSpan(text: 'Choose Your\n'),
                        const TextSpan(text: 'Favourite '),
                        TextSpan(
                          text: 'Genre ',
                          style: AppTextStyles.titleStyle.copyWith(
                            color: AppColors.accentRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Onboarding image
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 75),
                      child: AspectRatio(
                        aspectRatio: 0.82,
                        child: Image.asset(
                          'images/onboarding.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Next button to proceed to registration
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 343),
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 29,
                            vertical: 20,
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: AppTextStyles.buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}