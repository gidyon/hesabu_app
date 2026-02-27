import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/auth/data/mock_auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class VerifyResetCodeScreen extends StatefulWidget {
  const VerifyResetCodeScreen({super.key});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final AuthRepository _authRepository = MockAuthRepository();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
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
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
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
      },
    );
  }

  void _onVerify() async {
    String code = _otpControllers.map((e) => e.text).join();
    if (code.length == 6) {
        bool verified = await _authRepository.verifyResetCode("test@example.com", code);
        if (verified && mounted) {
            context.push('/create-password');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
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
                            icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
                            label: const Text('Back', style: TextStyle(color: AppColors.primary, fontSize: 18)),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                        const Text(
                            'Reset Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const SizedBox(width: 48), // Balance
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Header Content
                  const Text(
                    'Verify Reset Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.slate400, fontSize: 16, height: 1.5),
                      children: [
                        TextSpan(text: "We've sent a 6-digit verification code to "),
                        TextSpan(
                          text: "johndoe@email.com",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: ". Please enter it below."),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
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
                        _buildTimerBox(_minutes.toString().padLeft(2, '0'), 'MINUTES'),
                        const SizedBox(width: 16),
                        _buildTimerBox(_start.toString().padLeft(2, '0'), 'SECONDS'),
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
                                              color: AppColors.primary.withOpacity(0.5),
                                              fontWeight: FontWeight.bold,
                                          ),
                                      ),
                                  ]
                              ),
                          )
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: AppColors.primary.withOpacity(0.2),
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

  Widget _buildTimerBox(String value, String label) {
      return Column(
          children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                      value,
                      style: const TextStyle(
                          color: Colors.white,
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
