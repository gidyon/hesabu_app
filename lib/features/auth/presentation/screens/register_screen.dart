import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthRepository>().register(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
      );
      if (success && mounted) {
        // Automatically login after successful registration
        await context.read<AuthRepository>().login(
          _phoneController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          context.go('/groups');
        }
      }
    } catch (e) {
      if (mounted) {
        String message = e.toString().contains('ApiException')
            ? e.toString().split(':').last.trim()
            : 'Registration failed. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Text(
                          'Register',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 48),

                    Text(
                      'Create Account',
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
                      'Join Hesabu and take control of your group savings and finances.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.slate400, fontSize: 14),
                    ),

                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _fullNameController,
                      icon: Icons.person_outline,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _emailController,
                      icon: Icons.mail_outline,
                      labelText: 'Email Address',
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email is required';
                        if (!value.contains('@')) return 'Invalid email format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      labelText: 'Phone Number',
                      hintText: 'e.g. +254 712 345 678',
                      keyboardType: TextInputType.phone,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Phone is required'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      isPassword: true,
                      isVisible: _isPasswordVisible,
                      onToggleVisibility: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Password is required';
                        if (value.length < 6)
                          return 'At least 6 characters required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock_outline,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      isPassword: true,
                      isVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: () {
                        setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please confirm your password';
                        if (value != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Register Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.person_add_outlined),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.slate400),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Login',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        color: InheritedThemeController.of(context).isDark
            ? const Color(0xFF1c271f)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InheritedThemeController.of(context).isDark
              ? const Color(0xFF3b5443)
              : AppColors.slate200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Icon(icon, color: AppColors.slate400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword && !isVisible,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: const TextStyle(
                  color: AppColors.slate400,
                  fontSize: 14,
                ),
                floatingLabelStyle: TextStyle(color: accent, fontSize: 12),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: InheritedThemeController.of(context).isDark
                      ? const Color(0xFF9db9a6).withOpacity(0.5)
                      : AppColors.slate400.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
                errorStyle: const TextStyle(fontSize: 12, height: 1),
              ),
            ),
          ),
          if (isPassword && onToggleVisibility != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.slate400,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          if (!isPassword) const SizedBox(width: 16),
        ],
      ),
    );
  }
}
