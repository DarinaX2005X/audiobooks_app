import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/api_servive.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'text_screen.dart';

import 'package:just_audio/just_audio.dart';

class DetailsScreen extends StatefulWidget {
  final Book book;

  const DetailsScreen({super.key, required this.book});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _audioPlayer = AudioPlayer();
  final List<double> _speedOptions = [0.5, 1.0, 1.25, 1.5, 2.0];
  double _currentSpeed = 1.0;
  double _progressValue = 0.0;
  Duration _totalDuration = Duration.zero;
  bool isOffline = false;
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _isSeeking = false;
  Book? _book;

  @override
  void dispose() {
    _audioPlayer.stop(); // or _audioPlayer.pause();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadUserProfile();
    _loadBookDetails();

    // Listen to duration and position streams together, update only when both available
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (!_isSeeking) {
        // only update if user not dragging
        final totalDuration = _audioPlayer.duration;
        if (totalDuration != null && totalDuration.inMilliseconds > 0) {
          final clampedPosition =
              position > totalDuration ? totalDuration : position;
          final newProgressValue =
              clampedPosition.inMilliseconds / totalDuration.inMilliseconds;

          if ((_progressValue - newProgressValue).abs() > 0.001) {
            setState(() {
              _progressValue = newProgressValue.clamp(0.0, 1.0);
            });
          }
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivity == ConnectivityResult.none;
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await ApiService.getUserProfile();
      if (userProfile != null) {
        final favorites = userProfile['favorites'] as List;
        setState(() {
          _isFavorite = favorites.any(
            (fav) => fav['audiobookId'] == widget.book.id,
          );
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadBookDetails() async {
    try {
      setState(() => _isLoading = true);
      final book = await ApiService.getBookDetails(widget.book.id);
      await _audioPlayer.setUrl(
        AuthService.baseUrl + '/stream/' + book!.fileName!,
      );
      if (book != null) {
        setState(() {
          _book = book;
          _isLoading = false;
        });
      } else {
        throw Exception('Book not found');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).offlineCannotAddToFavorites,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await ApiService.removeFromFavorites(widget.book.id);
      } else {
        await ApiService.addToFavorites(widget.book.id);
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorOccurred)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkGuestMode() async {
    return await AuthService.isGuestMode();
  }

  Widget _buildBookCover() {
    if (widget.book.coverUrl == null || widget.book.coverUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.book, size: 50),
      );
    }

    try {
      if (widget.book.coverUrl!.startsWith('http')) {
        return Image.network(
          widget.book.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 50),
            );
          },
        );
      } else {
        return Image.asset(
          widget.book.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.book, size: 50),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.error, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
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
                            decoration: ShapeDecoration(
                              color: theme.colorScheme.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          loc.details,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: ShapeDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(),
                                        )
                                        : Icon(
                                          _isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              _isFavorite
                                                  ? AppColors.accentRed
                                                  : theme.colorScheme.onSurface,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            TextScreen(book: widget.book),
                                  ),
                                );
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: ShapeDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.book_fill,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 175.90,
                        height: 258.49,
                        decoration: ShapeDecoration(
                          color: theme.colorScheme.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          shadows: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.1),
                              blurRadius: 22,
                              offset: const Offset(-12, 10),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildBookCover(),
                        ),
                      ),
                      const SizedBox(height: 55),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star, size: 20),
                              SizedBox(width: 5),
                              Text(
                                '4.5',
                                style: TextStyle(
                                  color: Color(0xFF191714),
                                  fontSize: 14,
                                  fontFamily: AppTextStyles.albraFontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 17),
                          Row(
                            children: [
                              const Icon(Icons.language, size: 20),
                              const SizedBox(width: 5),
                              Text(
                                loc.bookLanguageEnglish,
                                style: const TextStyle(
                                  color: Color(0xFF191714),
                                  fontSize: 14,
                                  fontFamily: AppTextStyles.albraFontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 17),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 5),
                              Text(
                                (_formatDuration(_totalDuration)),
                                style: const TextStyle(
                                  color: Color(0xFF191714),
                                  fontSize: 14,
                                  fontFamily: AppTextStyles.albraFontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.book.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppTextStyles.albraFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.book.author,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 343,
                          height: 81,
                          padding: const EdgeInsets.all(13),
                          decoration: ShapeDecoration(
                            color: theme.colorScheme.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.music_note,
                                color: theme.colorScheme.onSurface,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final currentPosition =
                                      await _audioPlayer.position;
                                  final newPosition =
                                      currentPosition -
                                      const Duration(seconds: 10);
                                  await _audioPlayer.seek(
                                    newPosition > Duration.zero
                                        ? newPosition
                                        : Duration.zero,
                                  );
                                },
                                child: Icon(
                                  Icons.replay_10,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.skip_previous,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 18),
                                  GestureDetector(
                                    onTap: () {
                                      if (isOffline) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              loc.offlineCannotPlay,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      // to do
                                    },

                                    child: StreamBuilder<PlayerState>(
                                      stream: _audioPlayer.playerStateStream,
                                      builder: (context, snapshot) {
                                        final playerState = snapshot.data;
                                        final isPlaying =
                                            playerState?.playing ?? false;
                                        final processingState =
                                            playerState?.processingState;

                                        final showPause =
                                            isPlaying &&
                                            processingState !=
                                                ProcessingState.completed &&
                                            processingState !=
                                                ProcessingState.idle;

                                        return Container(
                                          width: 53,
                                          height: 53,
                                          decoration: const ShapeDecoration(
                                            color: AppColors.buttonRed,
                                            shape: OvalBorder(),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              showPause
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              if (showPause) {
                                                await _audioPlayer.pause();
                                              } else {
                                                await _audioPlayer.play();
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Icon(
                                    Icons.skip_next,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final currentPosition =
                                      await _audioPlayer.position;
                                  final totalDuration =
                                      _audioPlayer.duration ?? Duration.zero;
                                  final newPosition =
                                      currentPosition +
                                      const Duration(seconds: 10);
                                  await _audioPlayer.seek(
                                    newPosition < totalDuration
                                        ? newPosition
                                        : totalDuration,
                                  );
                                },
                                child: Icon(
                                  Icons.forward_10,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              PopupMenuButton<double>(
                                child: Row(
                                  children: [
                                    const Icon(Icons.speed),
                                    Text('${_currentSpeed}x'),
                                  ],
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    _currentSpeed = value;
                                  });
                                  _audioPlayer.setSpeed(value);
                                },
                                itemBuilder: (context) {
                                  return _speedOptions.map((speed) {
                                    return PopupMenuItem(
                                      value: speed,
                                      child: Text('${speed}x'),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: theme.colorScheme.error.withOpacity(0.9),
                padding: const EdgeInsets.all(8),
                child: Text(
                  loc.offlineMode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: AppTextStyles.albraGroteskFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
