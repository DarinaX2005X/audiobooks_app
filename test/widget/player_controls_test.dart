import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/widgets/player_controls.dart';

void main() {
  testWidgets('PlayerControls widget test', (WidgetTester tester) async {
    bool isPlaying = false;
    
    // Build our widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerControls(
            isPlaying: isPlaying,
            onPlayPause: () {
              isPlaying = !isPlaying;
            },
            onNext: () {},
            onPrevious: () {},
          ),
        ),
      ),
    );

    // Verify that play button is present
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    
    // Tap the play button
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // Rebuild widget with new state
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerControls(
            isPlaying: true,
            onPlayPause: () {},
            onNext: () {},
            onPrevious: () {},
          ),
        ),
      ),
    );

    // Verify that pause button appears after tapping play
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });
} 