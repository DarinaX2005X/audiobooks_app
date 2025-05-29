import 'package:flutter/foundation.dart';

class AudioService {
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;

  void updatePosition(Duration position) {
    _currentPosition = position;
  }

  void play() {
    _isPlaying = true;
  }

  void pause() {
    _isPlaying = false;
  }
} 