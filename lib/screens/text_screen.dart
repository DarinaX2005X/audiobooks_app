import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class TextScreen extends StatelessWidget {
  const TextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        // Use SingleChildScrollView to allow scrolling through the text content
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button, title, and more options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  const Text(
                    'Text',
                    style: TextStyle(
                      color: Color(0xFF191714),
                      fontSize: 16,
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF191714),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Chapter title
              const Text(
                'Chapter 1: The Beginning',
                style: TextStyle(
                  color: Color(0xFF191714),
                  fontSize: 24,
                  fontFamily: AppTextStyles.albraFontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              // Chapter content
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
                    'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.\n\n'
                    'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?',
                style: TextStyle(
                  color: Color(0xFF191714),
                  fontSize: 16,
                  fontFamily: AppTextStyles.albraGroteskFontFamily,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}