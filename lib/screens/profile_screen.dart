import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EEE3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
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
                      'My Profile',
                      style: TextStyle(
                        color: Color(0xFF191714),
                        fontSize: 16,
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 39,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF191714),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 162,
                    height: 162,
                    decoration: ShapeDecoration(
                      image: const DecorationImage(
                        image: AssetImage("images/user.png"),
                        fit: BoxFit.fill,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 5,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF191714),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildProfileRow('Display Name', 'John Doe'),
                    _buildProfileRow('Username', 'johndoe'),
                    _buildProfileRow('Email', 'john@mail.com'),
                    _buildProfileRow('Phone', '+1234567890'),
                    _buildProfileRow('Date Birth', '01 January 2001'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelStyle,
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              value,
              style: AppTextStyles.valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}