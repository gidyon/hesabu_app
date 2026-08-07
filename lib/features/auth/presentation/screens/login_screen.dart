import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/security/security_controller.dart';
import 'package:hesabu_app/core/widgets/auth_icon.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _showPasswordFallback = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    final security = context.read<SecurityController>();
    if (!security.biometricEnabled || _isLoading) return;

    try {
      final canAuthenticate =
          await _localAuthentication.canCheckBiometrics ||
          await _localAuthentication.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          _showMessage('Biometric authentication is unavailable.');
          setState(() => _showPasswordFallback = true);
        }
        return;
      }

      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Unlock your Hesabu Online account',
        biometricOnly: true,
        sensitiveTransaction: true,
      );
      if (!authenticated || !mounted) return;

      final identifier = await _secureStorage.read(key: 'bio_email');
      final password = await _secureStorage.read(key: 'bio_password');
      if (identifier == null || password == null) {
        if (mounted) {
          _showMessage(
            'Sign in with your password once to restore biometrics.',
          );
          setState(() => _showPasswordFallback = true);
        }
        return;
      }

      await _submitLogin(identifier: identifier, password: password);
    } on PlatformException {
      if (mounted) {
        _showMessage('Biometric authentication was not completed.');
      }
    }
  }

  Future<void> _handlePasswordLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _submitLogin(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _submitLogin({
    required String identifier,
    required String password,
  }) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await context.read<AuthRepository>().login(
        identifier,
        password,
      );
      if (!mounted) return;

      if (response.hasError || response.data != true) {
        _showMessage(
          response.errorMessage ?? 'Login failed. Check your credentials.',
          isError: true,
        );
        return;
      }

      await _secureStorage.write(key: 'bio_email', value: identifier);
      await _secureStorage.write(key: 'bio_password', value: password);
      if (!mounted) return;

      await context.read<ActivityProvider>().record(
        type: AccountActivityType.welcome,
        title: 'Welcome back',
        description: 'You signed in securely to Hesabu Online.',
        status: AccountActivityStatus.info,
      );
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        _showMessage(
          'An unexpected error occurred. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AuthIcon()),
                  const SizedBox(height: 18),
                  Text(
                    'Hesabu Online',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Secure access to your group savings ledgers',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Consumer<SecurityController>(
                        builder: (context, security, _) {
                          if (!security.isInitialized) {
                            return const SizedBox(
                              height: 190,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final showBiometric =
                              security.biometricEnabled &&
                              !_showPasswordFallback;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: showBiometric
                                ? _buildBiometricPanel(accent)
                                : _buildPasswordPanel(
                                    showBiometricOption:
                                        security.biometricEnabled,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Create a new Hesabu account'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.tertiaryText(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Encrypted session • Protected account access',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.tertiaryText(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricPanel(Color accent) {
    return Column(
      key: const ValueKey('biometric-login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.fingerprint_rounded, color: accent, size: 34),
        ),
        const SizedBox(height: 14),
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Use your fingerprint or face to open your financial workspace.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _isLoading ? null : _handleBiometricLogin,
          icon: _isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fingerprint_rounded),
          label: const Text('Unlock with Biometrics'),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() => _showPasswordFallback = true),
          child: const Text('Use Password Instead'),
        ),
      ],
    );
  }

  Widget _buildPasswordPanel({required bool showBiometricOption}) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('password-login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign in',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your registered phone number or email.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Email or phone number',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Email or phone number is required'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _handlePasswordLogin(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 4) return 'Password is too short';
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/reset-password'),
              child: const Text('Forgot password?'),
            ),
          ),
          FilledButton.icon(
            onPressed: _isLoading ? null : _handlePasswordLogin,
            icon: _isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: const Text('Sign in securely'),
          ),
          if (showBiometricOption) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _showPasswordFallback = false),
              icon: const Icon(Icons.fingerprint_rounded, size: 19),
              label: const Text('Use biometric login'),
            ),
          ],
        ],
      ),
    );
  }
}
