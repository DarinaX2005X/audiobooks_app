import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/screens/profile_screen.dart';
import 'package:audiobooks_app/services/auth_service.dart';
import 'package:audiobooks_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:audiobooks_app/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audiobooks_app/models/book.dart';
import 'package:audiobooks_app/services/local_storage_service.dart';
import 'package:audiobooks_app/services/user_service.dart';
import 'package:audiobooks_app/services/api_servive.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Set mock values for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Mock path provider
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    Hive.registerAdapter(BookAdapter());
    await Hive.openBox(LocalStorageService.userBox);

    // Initialize AuthService
    await AuthService.init();
  });

  testWidgets('Profile screen UI elements test', (WidgetTester tester) async {
    // Login first
    final loginResult = await AuthService.login('test2', '12345678');
    expect(loginResult, true);

    // Build our widget with necessary providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AuthService>.value(value: AuthService()),
          Provider<UserService>.value(value: UserService()),
          Provider<ApiService>.value(value: ApiService()),
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
          home: ProfileScreen(),
        ),
      ),
    );

    // Wait for localization to load and data to be fetched
    await tester.pumpAndSettle();

    // Verify that all required UI elements are present
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('Profile screen error handling test', (WidgetTester tester) async {
    // Build our widget with necessary providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<AuthService>.value(value: AuthService()),
          Provider<UserService>.value(value: UserService()),
          Provider<ApiService>.value(value: ApiService()),
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
          home: ProfileScreen(),
        ),
      ),
    );

    // Wait for localization to load
    await tester.pumpAndSettle();

    // Verify error view is displayed
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
  });
}

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return '/mock/documents/path';
  }
} 