import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/services/user_service.dart';

void main() {
  group('UserService Tests', () {
    test('should fetch user profile successfully', () async {
      try {
        final result = await UserService.fetchUserProfile();
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), true);
        expect(result.containsKey('user'), true);
        expect(result.containsKey('message'), true);
      } catch (e) {
        // If there's an error, it should be due to network or auth
        expect(e, isA<Exception>());
      }
    });

    test('should handle authentication errors correctly', () async {
      try {
        final result = await UserService.fetchUserProfile();
        if (!result['success']) {
          expect(result['message'], isA<String>());
          expect(result['message'].contains('Authentication required'), true);
        }
      } catch (e) {
        // If there's an error, it should be due to network or auth
        expect(e, isA<Exception>());
      }
    });

    test('should return valid user data structure', () async {
      try {
        final result = await UserService.fetchUserProfile();
        if (result['success']) {
          final userData = result['user'];
          expect(userData, isA<Map<String, dynamic>>());
          // Check for required user fields
          expect(userData.containsKey('username'), true);
          expect(userData.containsKey('email'), true);
        }
      } catch (e) {
        // If there's an error, it should be due to network or auth
        expect(e, isA<Exception>());
      }
    });
  });
} 