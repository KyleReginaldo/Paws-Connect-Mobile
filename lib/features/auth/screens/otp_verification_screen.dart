import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/paws_theme.dart';

@RoutePage()
class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP(String pin) async {
    if (pin.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = AuthProvider();
      final result = await authProvider.verifyPasswordResetOTP(
        email: widget.email,
        otp: pin,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to reset password screen
        context.router.push(ResetPasswordRoute(email: widget.email));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error), backgroundColor: Colors.red),
        );

        // Clear OTP fields on error
        _pinController.clear();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      final authProvider = AuthProvider();
      final result = await authProvider.resendPasswordResetOTP(
        email: widget.email,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent again!'),
            backgroundColor: Colors.green,
          ),
        );
        _pinController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PawsColors.textPrimary),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Header
              const PawsText(
                'Verify Your Email',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: PawsColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              PawsText(
                'We\'ve sent a 6-digit verification code to\n${widget.email}',
                fontSize: 16,
                color: PawsColors.textSecondary,
                textAlign: TextAlign.center,
              ),

              // Show OTP in debug mode
              const SizedBox(height: 16),

              // Pinput OTP Input
              Center(
                child: Pinput(
                  controller: _pinController,
                  focusNode: _focusNode,
                  length: 6,
                  enabled: !_isLoading,
                  onCompleted: _verifyOTP,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 60,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PawsColors.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: PawsColors.border, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56,
                    height: 60,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PawsColors.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: PawsColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 56,
                    height: 60,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: PawsColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: PawsColors.primary,
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: 56,
                    height: 60,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: PawsColors.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  cursor: Container(
                    width: 2,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: PawsColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(1)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Loading indicator
              if (_isLoading)
                const CircularProgressIndicator(color: PawsColors.primary),

              const SizedBox(height: 32),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PawsText(
                    'Didn\'t receive the code? ',
                    color: PawsColors.textSecondary,
                  ),
                  GestureDetector(
                    onTap: _isLoading || _isResending ? null : _resendOTP,
                    child: PawsText(
                      'Resend',
                      color: (_isLoading || _isResending)
                          ? PawsColors.disabled
                          : PawsColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PawsColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PawsColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: PawsColors.info, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: PawsText(
                        'Enter the 6-digit code sent to your email. The code will expire in 10 minutes.',
                        fontSize: 14,
                        color: PawsColors.info,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
