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

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _progressValue = 0.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), 
        TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0)),
      ],
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              child: const Icon(Icons.error, size: 50),
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF191714),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Text(
                      'Details',
                      style: TextStyle(
                        color: Color(0xFF191714),
                        fontSize: 16,
                        fontFamily: 'AlbraGrotesk',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TextScreen()),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF191714),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                          ),
                        ),
                        child: const Icon(Icons.more_vert, color: Colors.white),
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
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 22,
                          offset: Offset(-12, 10),
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
                              fontFamily: 'Albra',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 17),
                      Row(
                        children: const [
                          Icon(Icons.language, size: 20),
                          SizedBox(width: 5),
                          Text(
                            'English',
                            style: TextStyle(
                              color: Color(0xFF191714),
                              fontSize: 14,
                              fontFamily: 'Albra',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 17),
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 20),
                          SizedBox(width: 5),
                          Text(
                            '2 hours',
                            style: TextStyle(
                              color: Color(0xFF191714),
                              fontSize: 14,
                              fontFamily: 'Albra',
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
                    style: const TextStyle(
                      color: Color(0xFF191714),
                      fontSize: 24,
                      fontFamily: 'Albra',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.book.author,
                    style: const TextStyle(
                      color: Color(0xFF191714),
                      fontSize: 16,
                      fontFamily: 'AlbraGrotesk',
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
                          _formatDuration(Duration(seconds: (_progressValue * 60).toInt())),
                          style: const TextStyle(
                            color: Color(0xFFA4A196),
                            fontSize: 12,
                            fontFamily: 'AlbraGrotesk',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _progressValue,
                            onChanged: (value) {
                              setState(() {
                                _progressValue = value;
                              });
                            },
                            activeColor: AppColors.accentRed,
                            inactiveColor: Colors.black,
                          ),
                        ),
                        const Text(
                          '1:00:00',
                          style: TextStyle(
                            color: Color(0xFF191714),
                            fontSize: 12,
                            fontFamily: 'AlbraGrotesk',
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
                      decoration: const ShapeDecoration(
                        color: Color(0xFF191714),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(Icons.music_note, color: Colors.white),
                          const Icon(Icons.replay_10, color: Colors.white),
                          Row(
                            children: [
                              const Icon(Icons.skip_previous, color: Colors.white),
                              const SizedBox(width: 18),
                              GestureDetector(
                                onTapDown: (_) => _animationController.forward(),
                                onTapUp: (_) {
                                  _animationController.reverse();
                                  setState(() {
                                    _isPlaying = !_isPlaying;
                                    if (_isPlaying) {
                                      _startProgressSimulation();
                                    }
                                  });
                                },
                                onTapCancel: () => _animationController.reverse(),
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _isPlaying
                                          ? _pulseAnimation.value
                                          : _scaleAnimation.value,
                                      child: Container(
                                        width: 53,
                                        height: 53,
                                        decoration: const ShapeDecoration(
                                          color: AppColors.buttonRed,
                                          shape: OvalBorder(),
                                          shadows: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Icon(Icons.skip_next, color: Colors.white),
                            ],
                          ),
                          const Icon(Icons.forward_10, color: Colors.white),
                          const Icon(Icons.speed, color: Colors.white),
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
