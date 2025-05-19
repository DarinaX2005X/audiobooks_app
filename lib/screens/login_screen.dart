import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/theme_constants.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'forget_password_screen.dart';
import 'package:dio/dio.dart';
import 'pin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRemembered = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivity == ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔑 LoginScreen: Attempting login with remember me: $_isRemembered');
      final success = await AuthService.login(
        _emailController.text,
        _passwordController.text,
        rememberMe: _isRemembered,
      );

      if (!mounted) return;

      if (success) {
        debugPrint('🔑 LoginScreen: Login successful, navigating to main screen');
        _handleLoginSuccess();
      } else {
        debugPrint('🔑 LoginScreen: Login failed');
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      debugPrint('🔑 LoginScreen: Error during login: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    if (!mounted) return;
    await AuthService.setGuestMode(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _handleLoginSuccess() async {
    if (mounted) {
      // Проверяем, установлен ли уже PIN-код
      final hasPin = await AuthService.hasPinSet();
      
      if (!hasPin) {
        // Показываем диалог с предложением установить PIN-код
        final shouldSetPin = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).pinSetupDialogTitle),
            content: Text(AppLocalizations.of(context).pinSetupDialogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context).pinSetupDialogLater),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context).pinSetupDialogSet),
              ),
            ],
          ),
        );

        if (shouldSetPin == true) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PinScreen(
                  isSetup: true,
                  onSuccess: () {
                    Navigator.pop(context); // Закрываем экран PIN-кода
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                ),
              ),
            );
            return;
          }
        }
      }

      // Если PIN не нужен или уже установлен, переходим на главный экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // 4% of screen width
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06), // 6% of screen height
                    Text(
                      loc.login,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontFamily: AppTextStyles.albraFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isOffline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        hintText: loc.email,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !isOffline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        hintText: loc.password,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _isRemembered,
                          onChanged: isOffline
                              ? null
                              : (value) {
                            setState(() {
                              _isRemembered = value ?? false;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          checkColor: theme.colorScheme.onPrimary,
                        ),
                        Flexible(
                          child: Text(
                            loc.rememberMe,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppTextStyles.albraGroteskFontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isOffline || _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
                          disabledForegroundColor: theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          loc.login,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppTextStyles.albraGroteskFontFamily,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isOffline)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleGuestLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            loc.continueAsGuest,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: AppTextStyles.albraGroteskFontFamily,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isOffline
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        disabledForegroundColor: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      child: Text(
                        loc.dontHaveAccount,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: isOffline
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgetPasswordScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        disabledForegroundColor: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      child: Text(
                        loc.forgetPassword,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppTextStyles.albraGroteskFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                ),
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
}