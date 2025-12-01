import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/button.dart';
import '../../../dependency.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget implements AutoRouteWrapper {
  final void Function(bool success)? onResult;

  const ChangePasswordScreen({super.key, this.onResult});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  String? _error;

  // Password validation state
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();

    // Add password validation listener
    _newPassword.addListener(() {
      _validatePassword(_newPassword.text);
    });
  }

  void _validatePassword(String value) {
    final min = value.length >= 8;
    final upper = RegExp(r'[A-Z]').hasMatch(value);
    final lower = RegExp(r'[a-z]').hasMatch(value);
    final number = RegExp(r'[0-9]').hasMatch(value);
    final special = RegExp(r'[!@#\$%^&*]').hasMatch(value);

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        hasMinLength = min;
        hasUpperCase = upper;
        hasLowerCase = lower;
        hasNumber = number;
        hasSpecialChar = special;
      });
    });
  }

  Widget _buildPasswordRequirement(String text, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: ok ? Colors.green : Colors.redAccent,
        ),
        const SizedBox(width: 8),
        PawsText(
          text,
          color: ok ? PawsColors.textSecondary : Colors.redAccent,
          fontSize: 13,
        ),
      ],
    );
  }

  String? _validateNewPasswordField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'New password is required';
    }

    final v = value.trim();
    final okMin = v.length >= 8;
    final okUpper = RegExp(r'[A-Z]').hasMatch(v);
    final okLower = RegExp(r'[a-z]').hasMatch(v);
    final okNum = RegExp(r'[0-9]').hasMatch(v);
    final okSpec = RegExp(r'[!@#\$%^&*]').hasMatch(v);

    if (!(okMin && okUpper && okLower && okNum && okSpec)) {
      return 'Password does not meet all requirements';
    }
    return null;
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = AuthProvider();
      final success = await repo.changeInitialPassword(
        userId: USER_ID ?? "",
        newPassword: _newPassword.text.trim(),
      );

      if (success.isSuccess) {
        widget.onResult?.call(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          context.router.pop(true);
        }
      } else {
        setState(() {
          _error = 'Failed to change password. Please try again.';
        });
        widget.onResult?.call(false);
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
      });
      widget.onResult?.call(false);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent skipping back
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // hides back button
          title: const Text(
            'Change Password',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PawsText(
                  'For security reasons, please enter your current password and set a new one.',
                ),
                const SizedBox(height: 24),

                // Current password
                PawsTextField(
                  hint: 'Current Password',
                  controller: _currentPassword,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New password
                PawsTextField(
                  hint: 'New Password',
                  controller: _newPassword,
                  obscureText: true,
                  validator: _validateNewPasswordField,
                ),
                const SizedBox(height: 8),

                // Password requirements indicator
                if (_newPassword.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PawsColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PawsText(
                          'Password Requirements:',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: PawsColors.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordRequirement(
                          'At least 8 characters',
                          hasMinLength,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One uppercase letter (A-Z)',
                          hasUpperCase,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One lowercase letter (a-z)',
                          hasLowerCase,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One number (0-9)',
                          hasNumber,
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement(
                          'One special character (!@#\$%^&*)',
                          hasSpecialChar,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Confirm password
                PawsTextField(
                  hint: 'Confirm Password',
                  controller: _confirmPassword,
                  obscureText: true,

                  validator: (value) {
                    if (value != _newPassword.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                ],

                PawsElevatedButton(
                  label: 'Change Password',
                  onPressed: _loading ? null : _handleChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
