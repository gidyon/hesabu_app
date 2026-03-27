import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _bioEnabled = false;
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBioSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBioSettings();
    }
  }

  Future<void> _checkBioSettings() async {
    final enabled = await _secureStorage.read(key: 'bio_enabled');
    if (mounted) {
      setState(() => _bioEnabled = enabled == 'true');
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!_bioEnabled) return;

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometrics not supported on this device'),
            ),
          );
        }
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login to Hesabu Online',
        sensitiveTransaction: true,
      );

      if (didAuthenticate && mounted) {
        // Retrieve stored credentials
        final email = await _secureStorage.read(key: 'bio_email');
        final password = await _secureStorage.read(key: 'bio_password');

        if (email != null && password != null) {
          setState(() => _isLoading = true);
          try {
            final success = await context.read<AuthRepository>().login(
              email,
              password,
            );
            if (success && mounted) {
              context.go('/home');
              return;
            }
          } catch (e) {
            // If API login fails with stored credentials, fallback to manual
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        }

        // Fallback or if no stored credentials, use what's in the fields
        _handleLogin();
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: ${e.message}')),
        );
      }
    }
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthRepository>().login(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        // Save credentials for biometrics automatically on login
        await _secureStorage.write(
          key: 'bio_email',
          value: _emailController.text,
        );
        await _secureStorage.write(
          key: 'bio_password',
          value: _passwordController.text,
        );

        context.go('/home'); // Navigate to home
      }
    } catch (e) {
      if (mounted) {
        String message = e.toString().contains('ApiException')
            ? e.toString().split(':').last.trim()
            : 'Login failed. Please check your credentials.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = InheritedThemeController.of(context);
    final accent = themeController.accentColor.primary;
    final isDark = themeController.isDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Geometric Background Elements
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(128),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(192),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Branding
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Securely access your group savings and financial management tools.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.slate400, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  // Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56, // Increased slightly to accommodate floating labels
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1c271f)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3b5443)
                                : AppColors.slate200,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.mail_outline,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email or Phone Number',
                                  labelStyle: const TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: 14,
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: accent,
                                    fontSize: 12,
                                  ),
                                  hintText: 'Enter email or phone',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF9db9a6).withOpacity(0.5)
                                        : AppColors.slate400.withOpacity(0.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1c271f)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3b5443)
                                : AppColors.slate200,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.lock_outline,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: 14,
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: accent,
                                    fontSize: 12,
                                  ),
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF9db9a6).withOpacity(0.5)
                                        : AppColors.slate400.withOpacity(0.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.slate400,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/reset-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: isDark
                            ? AppColors.backgroundDark
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.login),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Social Login Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? const Color(0xFF3b5443)
                              : AppColors.slate200,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            color: AppColors.slate400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? const Color(0xFF3b5443)
                              : AppColors.slate200,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _bioEnabled
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.1),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3b5443)
                                  : AppColors.slate200,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: _bioEnabled ? _handleBiometricLogin : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    size: 24,
                                    color: _bioEnabled
                                        ? accent
                                        : AppColors.slate400,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Biometric',
                                    style: TextStyle(
                                      color: _bioEnabled
                                          ? theme.textTheme.bodyLarge?.color
                                          : AppColors.slate400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3b5443)
                                  : AppColors.slate200,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    size: 24,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Apple ID',
                                    style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/register'),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.slate400),
                          children: [
                            const TextSpan(text: 'New to Hesabu? '),
                            TextSpan(
                              text: 'Register a New Account',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
