import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/screens/login_screen.dart';
import 'package:audiobooks_app/services/auth_service.dart';
import 'package:audiobooks_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:audiobooks_app/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:audiobooks_app/models/book.dart';
import 'package:audiobooks_app/services/local_storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Set mock values for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Mock connectivity
    ConnectivityPlatform.instance = MockConnectivityPlatform();

    // Mock path provider
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    Hive.registerAdapter(BookAdapter());
    await Hive.openBox(LocalStorageService.userBox);
  });

  testWidgets('Login screen UI elements test', (WidgetTester tester) async {
    // Build our widget with necessary providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AuthService>.value(value: AuthService()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          home: LoginScreen(),
        ),
      ),
    );

    // Wait for localization to load
    await tester.pumpAndSettle();

    // Verify that all required UI elements are present
    expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    expect(find.byType(Checkbox), findsOneWidget); // Remember me checkbox
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Build our widget with necessary providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AuthService>.value(value: AuthService()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          home: LoginScreen(),
        ),
      ),
    );

    // Wait for localization to load
    await tester.pumpAndSettle();

    // Enter valid credentials
    await tester.enterText(find.byType(TextField).first, 'test2');
    await tester.enterText(find.byType(TextField).last, '12345678');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Handle PIN setup dialog
    expect(find.text('Set up PIN code?'), findsOneWidget);
    expect(find.text('Would you like to set up a PIN code for offline access? This will allow you to log in without internet.'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
  });
}

class MockConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return ConnectivityResult.wifi;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    return Stream.value(ConnectivityResult.wifi);
  }
}

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return '/mock/documents/path';
  }
} 