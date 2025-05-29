import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:audiobooks_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Complete app flow test', (WidgetTester tester) async {
      // Запускаем приложение
      app.main();
      
      // Ждем полной инициализации приложения
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Проверяем, что приложение запустилось
      expect(find.byType(MaterialApp), findsOneWidget);

      // Проверяем, находимся ли мы на экране логина
      final isLoginScreen = find.byType(TextField).evaluate().isNotEmpty;
      
      if (isLoginScreen) {
        // Если мы на экране логина, вводим данные
        expect(find.byType(TextField), findsNWidgets(2)); // Email и пароль
        expect(find.byType(ElevatedButton), findsOneWidget); // Кнопка входа

        // Вводим тестовые данные
        await tester.enterText(find.byType(TextField).first, 'test2');
        await tester.enterText(find.byType(TextField).last, '12345678');
        await tester.pump();

        // Нажимаем кнопку входа
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
      }

      // Проверяем появление диалога настройки PIN-кода
      expect(find.text('Set up PIN code?'), findsOneWidget);
      expect(find.text('Would you like to set up a PIN code for offline access? This will allow you to log in without internet.'), findsOneWidget);
      
      // Нажимаем кнопку "Later" для пропуска настройки PIN-кода
      await tester.tap(find.text('Later'));
      
      // Ждем загрузки главного экрана и книг с сервера
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Проверяем наличие основных элементов интерфейса
      expect(find.byType(Container), findsWidgets); // Проверяем наличие контейнера навигации
      expect(find.byIcon(Icons.home), findsOneWidget); // Проверяем иконку Home
      expect(find.byIcon(Icons.search), findsOneWidget); // Проверяем иконку Search
      expect(find.byIcon(Icons.favorite), findsOneWidget); // Проверяем иконку Library
      expect(find.byIcon(Icons.person), findsOneWidget); // Проверяем иконку Profile

      // Проверяем загрузку книг
      final hasBooks = find.byType(GestureDetector).evaluate().isNotEmpty;
      if (!hasBooks) {
        // Если книг нет, проверяем сообщение об отсутствии книг
        expect(find.text('No books available'), findsOneWidget);
      }

      // Переходим на вкладку Library
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // Переходим на вкладку Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Возвращаемся на главный экран
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
    });
  });
} 