import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hesabu_app/core/widgets/auth_icon.dart';

import 'dart:async';

class VerifyResetCodeScreen extends StatefulWidget {
  final String msisdn;
  const VerifyResetCodeScreen({super.key, required this.msisdn});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _start = 48; // Seconds
  int _minutes = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0 && _minutes == 0) {
        setState(() {
          timer.cancel();
        });
      } else if (_start == 0) {
        setState(() {
          _minutes--;
          _start = 59;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _onVerify() async {
    String code = _otpControllers.map((e) => e.text).join();
    if (code.length == 6) {
      final response = await context.read<AuthRepository>().verifyResetCode(
        widget.msisdn,
        code,
      );
      if (!response.hasError && response.data == true && mounted) {
        context.push(
          '/create-password',
          extra: {'msisdn': widget.msisdn, 'otp': code},
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Verification failed.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
          // Subtle background glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                shape: BoxShape.circle,
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.chevron_left,
                          color: accent,
                          size: 28,
                        ),
                        label: Text(
                          'Back',
                          style: TextStyle(
                            color: accent,
                            fontSize: 18,
                          ),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Center(child: AuthIcon()),
                  const SizedBox(height: 24),

                  Text(
                    'Verify Reset Code',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text: "We've sent a 6-digit verification code to ",
                        ),
                        TextSpan(
                          text: widget.msisdn,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: ". Please enter it below."),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP Inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: titleColor.withOpacity(0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: titleColor.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: accent,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimerBox(
                        _minutes.toString().padLeft(2, '0'),
                        'MINUTES',
                        accent,
                        isDark,
                        titleColor,
                      ),
                      const SizedBox(width: 16),
                      _buildTimerBox(
                        _start.toString().padLeft(2, '0'),
                        'SECONDS',
                        accent,
                        isDark,
                        titleColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: null, // Disabled state as per design
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.slate400),
                          children: [
                            const TextSpan(text: "Didn't receive the code? "),
                            TextSpan(
                              text: "Resend Code",
                              style: TextStyle(
                                color: accent.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: accent.withOpacity(0.2),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Need help? Contact Hesabu Support',
                      style: TextStyle(color: AppColors.slate400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBox(String value, String label, Color accent, bool isDark, Color titleColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: titleColor.withOpacity(0.1)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate400,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
