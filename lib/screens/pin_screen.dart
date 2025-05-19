import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../constants/theme_constants.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onSuccess;

  const PinScreen({
    Key? key,
    this.isSetup = false,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  final List<String> _pin = [];
  String _message = '';
  bool _isError = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(value);
        _message = '';
        _isError = false;
      });

      if (_pin.length == 4) {
        _processPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _message = '';
        _isError = false;
      });
    }
  }

  Future<void> _processPin() async {
    final pin = _pin.join();
    
    if (widget.isSetup) {
      final success = await AuthService.setPinCode(pin);
      if (success) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
      } else {
        setState(() {
          _message = AppLocalizations.of(context).pinErrorSetup;
          _isError = true;
          _pin.clear();
        });
        _controller.forward().then((_) => _controller.reverse());
      }
    } else {
      final success = await AuthService.verifyPinCode(pin);
      if (success) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
      } else {
        setState(() {
          _message = AppLocalizations.of(context).pinErrorInvalid;
          _isError = true;
          _pin.clear();
        });
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.isSetup ? loc.pinSetupTitle : loc.pinEnterTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: AppTextStyles.albraFontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSetup ? loc.pinSetupMessage : loc.pinEnterMessage,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: AppTextStyles.albraFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            margin: const EdgeInsets.all(8),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < _pin.length
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _message,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _isError ? theme.colorScheme.error : theme.colorScheme.primary,
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 1; i <= 3; i++)
                        _buildKey(i.toString(), theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 4; i <= 6; i++)
                        _buildKey(i.toString(), theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 7; i <= 9; i++)
                        _buildKey(i.toString(), theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey('', theme),
                      _buildKey('0', theme),
                      _buildKey('⌫', theme, isDelete: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String value, ThemeData theme, {bool isDelete = false}) {
    return SizedBox(
      width: 75,
      height: 75,
      child: value.isEmpty
          ? const SizedBox()
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDelete ? _onDelete : () => _onKeyPressed(value),
                borderRadius: BorderRadius.circular(37.5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isDelete ? '⌫' : value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: AppTextStyles.albraFontFamily,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
} 