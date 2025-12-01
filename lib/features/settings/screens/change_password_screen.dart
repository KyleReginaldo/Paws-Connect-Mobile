import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:provider/provider.dart';

import '../repository/user_settings_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final bool _obscureCurrentPassword = true;
  final bool _obscureNewPassword = true;
  final bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer<UserSettingsRepository>(
        builder: (context, repository, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your password should be at least 8 characters long and include a mix of letters, numbers, and special characters.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Current Password
                  PawsTextField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    hint: 'Current Password',
                    prefixIcon: const Icon(LucideIcons.lockKeyhole),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // New Password
                  PawsTextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    prefixIcon: const Icon(LucideIcons.lockKeyhole),
                    hint: 'New Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (value == _currentPasswordController.text) {
                        return 'New password must be different from current password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password
                  PawsTextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(LucideIcons.lockKeyhole),
                    hint: 'Confirm New Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Password Strength Indicator
                  _buildPasswordStrengthIndicator(),

                  const SizedBox(height: 24),

                  // Error Message
                  if (repository.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              repository.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (repository.errorMessage != null)
                    const SizedBox(height: 24),

                  // Change Password Button
                  PawsElevatedButton(
                    label: 'Change Password',
                    onPressed: repository.isLoading ? null : _changePassword,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _calculatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Strength',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  strength <= 1
                      ? Colors.red
                      : strength <= 2
                      ? Colors.orange
                      : strength <= 3
                      ? Colors.yellow
                      : Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength <= 1
                  ? 'Weak'
                  : strength <= 2
                  ? 'Fair'
                  : strength <= 3
                  ? 'Good'
                  : 'Strong',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: strength <= 1
                    ? Colors.red
                    : strength <= 2
                    ? Colors.orange
                    : strength <= 3
                    ? Colors.yellow
                    : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getPasswordRequirements(password),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]')))
      strength++;

    return strength > 4 ? 4 : strength;
  }

  String _getPasswordRequirements(String password) {
    List<String> missing = [];

    if (password.length < 8) missing.add('8+ characters');
    if (!password.contains(RegExp(r'[a-z]'))) missing.add('lowercase letter');
    if (!password.contains(RegExp(r'[A-Z]'))) missing.add('uppercase letter');
    if (!password.contains(RegExp(r'[0-9]'))) missing.add('number');
    if (!password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]')))
      missing.add('special character');

    if (missing.isEmpty) {
      return 'All requirements met!';
    } else {
      return 'Missing: ${missing.join(', ')}';
    }
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final repository = context.read<UserSettingsRepository>();
      repository.clearError();

      final success = await repository.changePassword(
        userId: USER_ID ?? '',
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
