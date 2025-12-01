import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repository/user_settings_repository.dart';

class DeleteAccountDialog extends StatefulWidget {
  final UserSettingsRepository repository;

  const DeleteAccountDialog({super.key, required this.repository});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user's email
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser?.email != null) {
      _emailController.text = currentUser!.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          Icon(
            LucideIcons.info,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Delete Account'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isOtpSent) ...[
              const Text(
                'To delete your account, we need to verify your identity. Please confirm your email address and we\'ll send you a verification code.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.mail),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
            ] else ...[
              const Text(
                'We\'ve sent a verification code to your email. Please enter it below to proceed with account deletion.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.mail),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.key),
                  hintText: 'Enter 6-digit code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) {
                    return 'Verification code must be 6 digits';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                enabled: !_isLoading,
                autofocus: true,
              ),
            ],
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      color: Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!_isOtpSent)
          ElevatedButton(
            onPressed: _isLoading ? null : _sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Verification Code'),
          )
        else ...[
          TextButton(
            onPressed: _isLoading ? null : _resendOTP,
            child: const Text('Resend Code'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _verifyOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify & Continue'),
          ),
        ],
      ],
    );
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = widget.repository;
    repository.clearError();

    final success = await repository.sendDeleteAccountOTP(
      email: _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _isOtpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage =
            repository.errorMessage ?? 'Failed to send verification code';
      });
    }
  }

  Future<void> _resendOTP() async {
    await _sendOTP();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog first
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = widget.repository;
    repository.clearError();

    if (USER_ID == null) {
      setState(() => _isLoading = false);
      return;
    }

    final success = await repository.deleteAccountWithOTP(
      userId: USER_ID ?? '',
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Close the dialog first
        Navigator.of(context).pop(true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account deleted successfully. You have been signed out.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to main screen after a brief delay
        context.router.popUntilRoot();
      } else {
        setState(() {
          _errorMessage = repository.errorMessage ?? 'Failed to delete account';
        });
      }
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Icon(
              LucideIcons.info,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Final Confirmation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you absolutely sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone. All your data, including:',
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Profile information'),
                Text('• Forum posts and messages'),
                Text('• Pet listings'),
                Text('• Adoption records'),
                Text('• All other personal data'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'will be permanently deleted.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
