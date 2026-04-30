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
import 'package:hesabu_app/core/widgets/auth_icon.dart';
import 'package:hesabu_app/core/security/security_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _showLoginForm = false;
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check biometrics after first frame to determine default view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final securityController = context.read<SecurityController>();
      if (mounted) {
        setState(() {
          _showLoginForm = !securityController.biometricEnabled;
        });
      }
    });
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
    // No longer need to manually check bio settings as Provider handles it
  }

  Future<void> _handleBiometricLogin() async {
    final securityController = context.read<SecurityController>();
    if (!securityController.biometricEnabled) return;

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
          _handleLogin(email: email, password: password);
        } else {
          // Fallback to what is in the fields if no stored credentials
          _handleLogin();
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: ${e.message}')),
        );
      }
    }
  }

  void _handleLogin({String? email, String? password}) async {
    // If credentials are not provided, validate the form fields
    if (email == null || password == null) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _isLoading = true);
    try {
      final loginEmail = email ?? _emailController.text.trim();
      final loginPassword = password ?? _passwordController.text;

      final response = await context.read<AuthRepository>().login(
        loginEmail,
        loginPassword,
      );

      if (!response.hasError && response.data == true && mounted) {
        // Save successfully used credentials for future biometric login
        await _secureStorage.write(key: 'bio_email', value: loginEmail);
        await _secureStorage.write(key: 'bio_password', value: loginPassword);

        // ignore: use_build_context_synchronously
        context.go('/home'); // Navigate to home
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ??
                  'Login failed. Please check your credentials.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'An unexpected error occurred. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
    final fieldColor = isDark ? theme.cardColor : Colors.white;
    final fieldBorderColor = isDark ? theme.dividerColor : AppColors.slate200;
    final fieldIconColor = isDark
        ? Colors.white.withValues(alpha: 0.62)
        : AppColors.slate400;
    final fieldHintColor = isDark
        ? Colors.white.withValues(alpha: 0.58)
        : AppColors.slate400.withValues(alpha: 0.7);
    final fieldLabelColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppColors.slate400;

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
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(128),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.1),
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
                color: accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(192),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.05),
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
              child: Form(
                key: _formKey,
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

                    const Center(child: AuthIcon()),
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
                    Text(
                      'Securely access your group savings and financial management tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),
                    Consumer<SecurityController>(
                      builder: (context, security, _) {
                        if (security.biometricEnabled && !_showLoginForm) {
                          // Biometric View
                          return Column(
                            children: [
                              Center(
                                child: GestureDetector(
                                  onTap: _handleBiometricLogin,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.fingerprint,
                                      size: 50,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap above to use Biometrics',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 48),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _showLoginForm = true),
                                child: Text(
                                  'Use Password Instead',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // Login Form View
                        return Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 56,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fieldColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: fieldBorderColor),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          top: 16,
                                        ),
                                        child: Icon(
                                          Icons.mail_outline,
                                          color: fieldIconColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _emailController,
                                          style: TextStyle(
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Email or phone is required';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Email or Phone Number',
                                            labelStyle: TextStyle(
                                              color: fieldLabelColor,
                                              fontSize: 14,
                                            ),
                                            floatingLabelStyle: TextStyle(
                                              color: accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            hintText: 'Enter email or phone',
                                            hintStyle: TextStyle(
                                              color: fieldHintColor,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 8,
                                                ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
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
                                  constraints: const BoxConstraints(
                                    minHeight: 56,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fieldColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: fieldBorderColor),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          top: 16,
                                        ),
                                        child: Icon(
                                          Icons.lock_outline,
                                          color: fieldIconColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          style: TextStyle(
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password is required';
                                            }
                                            if (value.length < 4) {
                                              return 'Password too short';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              color: fieldLabelColor,
                                              fontSize: 14,
                                            ),
                                            floatingLabelStyle: TextStyle(
                                              color: accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            hintText: 'Enter your password',
                                            hintStyle: TextStyle(
                                              color: fieldHintColor,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 8,
                                                ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: fieldIconColor,
                                          ),
                                          onPressed: () => setState(
                                            () => _isPasswordVisible =
                                                !_isPasswordVisible,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push('/reset-password'),
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
                              width: double.infinity,
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
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                            if (security.biometricEnabled) ...[
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: () =>
                                    setState(() => _showLoginForm = false),
                                icon: Icon(Icons.fingerprint, color: accent),
                                label: Text(
                                  'Use Biometric Login',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/register'),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.secondaryText(context),
                            ),
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
          ),
        ],
      ),
    );
  }
}
