import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hesabu_app/core/widgets/auth_icon.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number'),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await context.read<AuthRepository>().sendResetCode(
        _emailController.text.trim(),
      );
      if (!response.hasError && response.data == true && mounted) {
        // Pass the email to the verify screen via extra
        context.push('/verify-reset-code', extra: _emailController.text.trim());
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ??
                  'Failed to send reset code. Please try again.',
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
    final titleColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 64),

                    const Center(child: AuthIcon()),
                    const SizedBox(height: 24),

                    Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No worries! Enter your registered email or phone number and we\'ll send you a verification code to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.slate400,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Step indicator
                    Row(
                      children: [
                        _buildStep(
                          '1',
                          'Enter Email',
                          isActive: true,
                          isDone: false,
                          accent: accent,
                          isDark: isDark,
                        ),
                        _buildStepConnector(isActive: false, accent: accent),
                        _buildStep(
                          '2',
                          'Verify Code',
                          isActive: false,
                          isDone: false,
                          accent: accent,
                          isDark: isDark,
                        ),
                        _buildStepConnector(isActive: false, accent: accent),
                        _buildStep(
                          '3',
                          'New Password',
                          isActive: false,
                          isDone: false,
                          accent: accent,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Email field
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Email or Phone Number',
                        style: TextStyle(
                          color: AppColors.slate200,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: titleColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16, top: 16),
                            child: Icon(
                              Icons.mail_outline,
                              color: AppColors.slate400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email or phone is required';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your email or phone',
                                hintStyle: TextStyle(
                                  color: titleColor.withValues(alpha: 0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
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

                    const SizedBox(height: 32),

                    // Send Code Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendResetCode,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Send Verification Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.send_outlined),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Back to login
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.slate400),
                            children: [
                              const TextSpan(text: 'Remember your password? '),
                              TextSpan(
                                text: 'Back to Login',
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

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    String number,
    String label, {
    required bool isActive,
    required bool isDone,
    required Color accent,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isDone
                  ? accent
                  : accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? Icon(
                      Icons.check,
                      color: isDark ? Colors.black : Colors.white,
                      size: 16,
                    )
                  : Text(
                      number,
                      style: TextStyle(
                        color: isActive
                            ? (isDark ? Colors.black : Colors.white)
                            : AppColors.slate400,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? accent : AppColors.slate400,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isActive, required Color accent}) {
    return Container(
      width: 24,
      height: 2,
      color: isActive ? accent : accent.withValues(alpha: 0.2),
      margin: const EdgeInsets.only(bottom: 20),
    );
  }
}
