import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import 'main_screen.dart';

class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  final List<String> genres = [
    'Detective',
    'Drama',
    'Historical',
    'Fantasy',
    'Fiction',
    'Romance',
    'Science Fiction',
    'Mystery',
    'Horror',
    'Action',
    'Thriller',
  ];
  final List<String> selectedGenres = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF191714),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              // Title and description
              Text(
                'Personalize Suggestion',
                style: AppTextStyles.titleStyle.copyWith(color: const Color(0xFF191714)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose min. 3 genres, we will give you more that relate to it.',
                style: TextStyle(
                  color: Color(0xFF191714),
                  fontSize: 16,
                  fontFamily: AppTextStyles.albraGroteskFontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              // Genre selection using Wrap
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: genres.map((genre) {
                  bool isSelected = selectedGenres.contains(genre);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedGenres.remove(genre);
                        } else {
                          selectedGenres.add(genre);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: ShapeDecoration(
                        color: isSelected ? AppColors.accentRed : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Skip and Continue buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: AppTextStyles.buttonTextStyle.copyWith(
                        color: AppColors.accentRed,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedGenres.length >= 3
                        ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTextStyles.buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}