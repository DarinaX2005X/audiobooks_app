import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../models/book.dart';
import 'text_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Book book;

  const DetailsScreen({super.key, required this.book});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isPlaying = false;
  double _progressValue = 0.0;

  Widget _buildBookCover() {
    final theme = Theme.of(context);
    if (widget.book.coverUrl.isEmpty) {
      return Container(
        color: theme.colorScheme.surface,
        child: Icon(Icons.book, size: 50, color: theme.colorScheme.onSurface),
      );
    }

    try {
      if (widget.book.coverUrl.startsWith('http')) {
        // Network image
        return Image.network(
          widget.book.coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.colorScheme.surface,
              child: Icon(
                Icons.book,
                size: 50,
                color: theme.colorScheme.onSurface,
              ),
            );
          },
        );
      } else {
        // Asset image
        return Image.asset(
          widget.book.coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.colorScheme.surface,
              child: Icon(
                Icons.book,
                size: 50,
                color: theme.colorScheme.onSurface,
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: theme.colorScheme.surface,
        child: Icon(Icons.error, size: 50, color: theme.colorScheme.onSurface),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
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
                      onTap: () => Navigator.pop(context),
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
                      'Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppTextStyles.albraGroteskFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TextScreen(),
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
                          Icons.more_vert,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
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
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: theme.colorScheme.onBackground,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '4.5',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppTextStyles.albraFontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 17),
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 20,
                            color: theme.colorScheme.onBackground,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'English',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppTextStyles.albraFontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 17),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: theme.colorScheme.onBackground,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '2 hours',
                            style: theme.textTheme.bodyMedium?.copyWith(
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
                    style: theme.textTheme.titleMedium?.copyWith(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(
                            Duration(seconds: (_progressValue * 60).toInt()),
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.6,
                            ),
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.onBackground
                                  .withOpacity(0.2),
                              thumbColor: theme.colorScheme.primary,
                            ),
                            child: Slider(
                              value: _progressValue,
                              onChanged: (value) {
                                setState(() {
                                  _progressValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          '1:00:00',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 343,
                      height: 81,
                      padding: const EdgeInsets.all(13),
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.music_note,
                            color: theme.colorScheme.onSurface,
                          ),
                          Icon(
                            Icons.replay_10,
                            color: theme.colorScheme.onSurface,
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
                                  setState(() {
                                    _isPlaying = !_isPlaying;
                                    if (_isPlaying) {
                                      _startProgressSimulation();
                                    }
                                  });
                                },
                                child: Container(
                                  width: 53,
                                  height: 53,
                                  decoration: ShapeDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: const OvalBorder(),
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Icon(
                                Icons.skip_next,
                                color: theme.colorScheme.onSurface,
                              ),
                            ],
                          ),
                          Icon(
                            Icons.forward_10,
                            color: theme.colorScheme.onSurface,
                          ),
                          Icon(Icons.speed, color: theme.colorScheme.onSurface),
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _startProgressSimulation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isPlaying && mounted) {
        setState(() {
          _progressValue += 0.1;
          if (_progressValue >= 1.0) {
            _progressValue = 0.0;
            _isPlaying = false;
          }
        });
        if (_isPlaying) {
          _startProgressSimulation();
        }
      }
    });
  }
}
