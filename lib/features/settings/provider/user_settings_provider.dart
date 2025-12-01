import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:paws_connect/flavors/flavor_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/result.dart';
import '../../../core/services/user_settings_service.dart';

class UserSettingsProvider {
  final UserSettingsService _userSettingsService = UserSettingsService();

  /// Change user password
  Future<Result<String>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        return Result.error(body['message'] ?? 'Failed to change password');
      }
      return Result.success('Password changed successfully');
    } on AuthException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Update user profile information
  Future<Result<void>> updateProfile({
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    return await _userSettingsService.updateProfile(
      userId: userId,
      username: username,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
  }

  /// Get user profile information
  Future<Result<Map<String, dynamic>>> getUserProfile(String userId) async {
    return await _userSettingsService.getUserProfile(userId);
  }

  /// Update notification preferences
  Future<Result<void>> updateNotificationPreferences({
    required String userId,
    bool? forumNotifications,
    bool? messageNotifications,
    bool? mentionNotifications,
    bool? reactionNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    return await _userSettingsService.updateNotificationPreferences(
      userId: userId,
      forumNotifications: forumNotifications,
      messageNotifications: messageNotifications,
      mentionNotifications: mentionNotifications,
      reactionNotifications: reactionNotifications,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );
  }

  /// Get notification preferences
  Future<Result<Map<String, dynamic>>> getNotificationPreferences(
    String userId,
  ) async {
    return await _userSettingsService.getNotificationPreferences(userId);
  }

  /// Update privacy settings
  Future<Result<void>> updatePrivacySettings({
    required String userId,
    bool? profileVisibility,
    bool? onlineStatus,
    bool? lastSeenVisibility,
    bool? phoneNumberVisibility,
    bool? emailVisibility,
  }) async {
    return await _userSettingsService.updatePrivacySettings(
      userId: userId,
      profileVisibility: profileVisibility,
      onlineStatus: onlineStatus,
      lastSeenVisibility: lastSeenVisibility,
      phoneNumberVisibility: phoneNumberVisibility,
      emailVisibility: emailVisibility,
    );
  }

  /// Delete user account
  Future<Result<void>> deleteAccount({
    required String userId,
    required String password,
  }) async {
    return await _userSettingsService.deleteAccount(
      userId: userId,
      password: password,
    );
  }

  /// Sign out user
  Future<Result<void>> signOut() async {
    return await _userSettingsService.signOut();
  }

  /// Get account statistics
  Future<Result<Map<String, dynamic>>> getAccountStatistics(
    String userId,
  ) async {
    return await _userSettingsService.getAccountStatistics(userId);
  }

  /// Send OTP for account deletion
  Future<Result<void>> sendDeleteAccountOTP({required String email}) async {
    return await _userSettingsService.sendDeleteAccountOTP(email: email);
  }

  /// Verify OTP for account deletion
  Future<Result<void>> verifyDeleteAccountOTP({
    required String email,
    required String otp,
  }) async {
    return await _userSettingsService.verifyDeleteAccountOTP(
      email: email,
      otp: otp,
    );
  }

  /// Delete account with OTP verification
  Future<Result<String>> deleteAccountWithOTP({
    required String userId,
    required String email,
    required String otp,
  }) async {
    return await _userSettingsService.deleteAccountWithOTP(
      userId: userId,
      email: email,
      otp: otp,
    );
  }
}
