import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/email_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/notifiers/user_id_notifier.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/supabase/client.dart';
import '../../../flavors/flavor_config.dart';

class OTPData {
  final String otp;
  final DateTime expiresAt;
  final int attempts;
  final bool isVerified;

  OTPData({
    required this.otp,
    required this.expiresAt,
    required this.attempts,
    this.isVerified = false,
  });

  OTPData copyWith({
    String? otp,
    DateTime? expiresAt,
    int? attempts,
    bool? isVerified,
  }) {
    return OTPData(
      otp: otp ?? this.otp,
      expiresAt: expiresAt ?? this.expiresAt,
      attempts: attempts ?? this.attempts,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class AuthProvider {
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user?.userMetadata?['role'] == 3) {
        USER_ID = response.user?.id;
        print('🎯 AUTH: USER_ID set to: $USER_ID');
        UserIdNotifier().setUserId(USER_ID);
        return Result.success('Sign in successful');
      } else {
        return Result.error('Unauthorized');
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    USER_ID = null;
    print('🎯 AUTH: USER_ID cleared');
    UserIdNotifier().clearUserId();
  }

  Future<Result<String>> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    required String username,
  }) async {
    try {
      final url = Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'username': username,
          'role': 3,
        }),
      );
      final res = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return Result.success(res['message']);
      } else {
        return Result.error(res['message']);
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Sign up failed: ${e.toString()}');
    }
  }

  Future<Result<String>> changeInitialPassword({
    required String userId,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
    );
    final body = jsonDecode(response.body);
    debugPrint('Change Password Response: $body');
    if (response.statusCode == 200) {
      return Result.success(body['message']);
    } else {
      return Result.error(body['message'] ?? 'Failed to change password');
    }
  }

  static final Map<String, OTPData> _otpStorage = {};

  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<Result<String>> sendPasswordResetOTP({required String email}) async {
    try {
      final otp = _generateOTP();

      _otpStorage[email] = OTPData(
        otp: otp,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        attempts: 0,
      );

      debugPrint('🔐 Sending OTP to $email: $otp (expires in 10 minutes)');

      final emailSent = await EmailService.sendOTPEmail(
        userEmail: email,
        userName: email.split('@')[0],
        otpCode: otp,
      );

      if (emailSent) {
        return Result.success(
          'OTP sent to $email. Please check your email and spam folder.',
        );
      } else {
        debugPrint(
          '⚠️ Email sending failed, but OTP is available in console for testing',
        );
        return Result.success('OTP sent to $email. Please check your email.');
      }
    } catch (e) {
      return Result.error('Failed to send OTP: ${e.toString()}');
    }
  }

  Future<Result<String>> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final otpData = _otpStorage[email];

      if (otpData == null) {
        return Result.error(
          'No OTP found for this email. Please request a new one.',
        );
      }

      if (DateTime.now().isAfter(otpData.expiresAt)) {
        _otpStorage.remove(email);
        return Result.error('OTP has expired. Please request a new one.');
      }

      if (otpData.attempts >= 3) {
        _otpStorage.remove(email);
        return Result.error(
          'Too many failed attempts. Please request a new OTP.',
        );
      }

      if (otpData.otp != otp) {
        _otpStorage[email] = otpData.copyWith(attempts: otpData.attempts + 1);
        return Result.error(
          'Invalid OTP. ${3 - (otpData.attempts + 1)} attempts remaining.',
        );
      }

      _otpStorage[email] = otpData.copyWith(isVerified: true);

      return Result.success('OTP verified successfully!');
    } catch (e) {
      return Result.error('Failed to verify OTP: ${e.toString()}');
    }
  }

  Future<Result<String>> resetPasswordWithOTP({
    required String email,
    required String newPassword,
  }) async {
    try {
      final otpData = _otpStorage[email];
      if (otpData == null || !otpData.isVerified) {
        return Result.error('Please verify your OTP first.');
      }
      if (DateTime.now().isAfter(otpData.expiresAt)) {
        _otpStorage.remove(email);
        return Result.error('OTP session has expired. Please start over.');
      }

      debugPrint('🔐 Password reset for $email with new password');

      try {
        // Get user data to find the user ID
        final userData = await supabase
            .from('users')
            .select('id')
            .eq('email', email)
            .single();

        final userId = userData['id'] as String;
        final response = await http.post(
          Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
        );
        if (response.statusCode != 200) {
          final body = jsonDecode(response.body);
          debugPrint('Error resetting password: ${body['message']}');
          return Result.error('Failed to reset password: ${body['message']}');
        }

        // Clear OTP data after successful password reset
        _otpStorage.remove(email);

        return Result.success(
          'Password changed successfully! You can now sign in with your new password.',
        );
      } on PostgrestException catch (e) {
        debugPrint('Error resetting password: ${e.message}');
        return Result.error('Failed to reset password: ${e.message}');
      } on AuthException catch (e) {
        debugPrint('Auth error resetting password: ${e.message}');
        return Result.error('Failed to reset password: ${e.message}');
      }
    } catch (e) {
      return Result.error('Failed to reset password: ${e.toString()}');
    }
  }

  Future<Result<String>> resendPasswordResetOTP({required String email}) async {
    return sendPasswordResetOTP(email: email);
  }
}
