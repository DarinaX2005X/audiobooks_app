import 'package:flutter/material.dart';

// Defines the color constants used throughout the app
class AppColors {
  static const Color darkBackground = Color(0xFF191714);
  static const Color accentRed = Color(0xFFE36166);
  static const Color buttonRed = Color(0xFFE36166);
  static const Color lightBackground = Color(0xFFF1EEE3);
}

// Defines the text styles used throughout the app
class AppTextStyles {
  static const String albraFontFamily = 'Bitter Regular';
  static const String albraGroteskFontFamily = 'Bitter Medium';

  static const TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 40,
    fontFamily: albraFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: albraGroteskFontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    color: Color(0xFF191714),
    fontSize: 16,
    fontFamily: albraGroteskFontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: Color(0xFF191714),
    fontSize: 24,
    fontFamily: albraFontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelStyle = TextStyle(
    color: Color(0xFF2E2E5D),
    fontSize: 14,
    fontFamily: albraGroteskFontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle valueStyle = TextStyle(
    color: Color(0xFF2E2E5D),
    fontSize: 14,
    fontFamily: albraGroteskFontFamily,
    fontWeight: FontWeight.w400,
  );
}