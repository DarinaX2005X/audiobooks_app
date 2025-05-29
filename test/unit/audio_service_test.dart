import 'package:flutter_test/flutter_test.dart';
import 'package:audiobooks_app/services/audio_service.dart';

void main() {
  group('AudioService Tests', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
    });

    test('should initialize with correct default values', () {
      expect(audioService.isPlaying, false);
      expect(audioService.currentPosition, Duration.zero);
    });

    test('should update position correctly', () {
      final newPosition = Duration(seconds: 30);
      audioService.updatePosition(newPosition);
      expect(audioService.currentPosition, newPosition);
    });
  });
} 