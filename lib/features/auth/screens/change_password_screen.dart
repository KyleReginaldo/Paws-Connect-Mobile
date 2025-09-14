import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';

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
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;
  String? _error;

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
          title: const Text('Change Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PawsText(
                  'For security reasons, you must change your password before continuing.',
                ),
                const SizedBox(height: 24),

                // New password
                PawsTextField(
                  hint: 'New Password',
                  controller: _newPassword,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'New password is required';
                    }
                    if (value.trim().length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
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
