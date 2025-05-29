import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService PIN Tests', () {
    setUp(() async {
      // Set mock values for SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('should set and verify PIN code correctly', () async {
      // Login first
      final loginResult = await AuthService.login('test2', '12345678');
      expect(loginResult, true);

      const testPin = '1234';
      
      // Test setting PIN
      final setResult = await AuthService.setPinCode(testPin);
      expect(setResult, true);
      
      // Test verifying correct PIN
      final verifyResult = await AuthService.verifyPinCode(testPin);
      expect(verifyResult, true);
      
      // Test verifying incorrect PIN
      final wrongPinResult = await AuthService.verifyPinCode('5678');
      expect(wrongPinResult, false);
    });

    test('should check if PIN is set correctly', () async {
      // Login first
      final loginResult = await AuthService.login('test2', '12345678');
      expect(loginResult, true);

      // Initially no PIN should be set
      final initialHasPin = await AuthService.hasPinSet();
      expect(initialHasPin, false);
      
      // Set PIN
      await AuthService.setPinCode('1234');
      
      // Now PIN should be set
      final hasPin = await AuthService.hasPinSet();
      expect(hasPin, true);
    });

    test('should remove PIN code correctly', () async {
      // Login first
      final loginResult = await AuthService.login('test2', '12345678');
      expect(loginResult, true);

      // Set PIN first
      await AuthService.setPinCode('1234');
      
      // Verify PIN is set
      final hasPinBefore = await AuthService.hasPinSet();
      expect(hasPinBefore, true);
      
      // Remove PIN
      await AuthService.removePinCode();
      
      // Verify PIN is removed
      final hasPinAfter = await AuthService.hasPinSet();
      expect(hasPinAfter, false);
    });
  });
} 