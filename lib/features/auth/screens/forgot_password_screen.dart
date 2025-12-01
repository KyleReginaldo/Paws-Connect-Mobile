import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';

import '../../../core/theme/paws_theme.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = AuthProvider();
      final result = await authProvider.sendPasswordResetOTP(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.value),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to OTP verification screen
        context.router.push(
          OTPVerificationRoute(email: _emailController.text.trim()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                const PawsText(
                  'Forgot Password?',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: PawsColors.textPrimary,
                ),
                const SizedBox(height: 8),
                PawsText(
                  'Don\'t worry! Enter your email address and we\'ll send you a verification code to reset your password.',
                  fontSize: 16,
                  color: PawsColors.textSecondary,
                ),
                const SizedBox(height: 48),

                // Email field
                const PawsText(
                  'Email Address',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: PawsColors.textPrimary,
                ),
                const SizedBox(height: 8),
                PawsTextField(
                  controller: _emailController,
                  hint: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: PawsColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawsColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send Verification Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const Spacer(),

                // Back to sign in
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PawsText(
                        'Remember your password? ',
                        color: PawsColors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () => context.router.pop(),
                        child: const PawsText(
                          'Sign In',
                          color: PawsColors.primary,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
