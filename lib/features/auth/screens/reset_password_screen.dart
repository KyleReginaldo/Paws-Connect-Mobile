import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';

import '../../../core/theme/paws_theme.dart';

@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password validation state
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      hasMinLength = password.length >= 8;
      hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  bool get _isPasswordValid {
    return hasMinLength &&
        hasUpperCase &&
        hasLowerCase &&
        hasNumber &&
        hasSpecialChar;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (!_isPasswordValid) {
      return 'Password must meet all requirements';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = AuthProvider();
      final result = await authProvider.resetPasswordWithOTP(
        email: widget.email,
        newPassword: _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: PawsColors.success, size: 24),
              const SizedBox(width: 12),
              const PawsText(
                'Success!',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
          content: const PawsText(
            'Your password has been updated successfully. You can now sign in with your new password.',
            fontSize: 16,
            color: PawsColors.textSecondary,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.router.popUntil(
                  (route) => route.isFirst,
                ); // Go back to sign in
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PawsColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const PawsText(
                'Sign In Now',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isValid ? Colors.green : Colors.redAccent,
        ),
        const SizedBox(width: 8),
        PawsText(
          text,
          color: isValid ? PawsColors.textSecondary : Colors.redAccent,
          fontSize: 13,
        ),
      ],
    );
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
                  'Reset Password',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: PawsColors.textPrimary,
                ),
                const SizedBox(height: 8),
                PawsText(
                  'Create a new secure password for your account.',
                  fontSize: 16,
                  color: PawsColors.textSecondary,
                ),
                const SizedBox(height: 48),

                // New Password field
                const PawsText(
                  'New Password',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: PawsColors.textPrimary,
                ),
                const SizedBox(height: 8),
                PawsTextField(
                  controller: _newPasswordController,
                  hint: 'Enter your new password',
                  obscureText: _obscureNewPassword,
                  validator: _validateNewPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: PawsColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: PawsColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),

                // Password requirements
                if (_newPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PawsText(
                          'Password must contain:',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: PawsColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordRequirement(
                          'At least 8 characters',
                          hasMinLength,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One uppercase letter',
                          hasUpperCase,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One lowercase letter',
                          hasLowerCase,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement('One number', hasNumber),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One special character',
                          hasSpecialChar,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Confirm Password field
                const PawsText(
                  'Confirm Password',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: PawsColors.textPrimary,
                ),
                const SizedBox(height: 8),
                PawsTextField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm your new password',
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: PawsColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: PawsColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdatePassword,
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
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const Spacer(),

                // Security info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PawsColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PawsColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: PawsColors.success, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: PawsText(
                          'Your new password will be encrypted and stored securely.',
                          fontSize: 14,
                          color: PawsColors.success,
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
