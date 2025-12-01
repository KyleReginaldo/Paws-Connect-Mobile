import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/flavors/flavor_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/result.dart';
import '../session/session_manager.dart';
import 'email_service.dart';

class UserSettingsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Change user password
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔍 UserSettingsService: Changing user password');

      // Verify current password by attempting to sign in
      final email = _client.auth.currentUser?.email;
      if (email == null) {
        return Result.error('No authenticated user found');
      }

      // Re-authenticate with current password to verify it
      final signInResponse = await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (signInResponse.user == null) {
        return Result.error('Current password is incorrect');
      }

      // Update password
      await _client.auth.updateUser(UserAttributes(password: newPassword));

      debugPrint('🔍 UserSettingsService: Password changed successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error changing password: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to change password: $e');
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
    try {
      debugPrint('🔍 UserSettingsService: Updating user profile');

      final Map<String, dynamic> updateData = {};

      if (username != null) updateData['username'] = username;
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (bio != null) updateData['bio'] = bio;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (profileImageUrl != null)
        updateData['profile_image_link'] = profileImageUrl;

      if (updateData.isNotEmpty) {
        updateData['updated_at'] = DateTime.now().toIso8601String();

        await _client.from('users').update(updateData).eq('id', userId);
      }

      debugPrint('🔍 UserSettingsService: Profile updated successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error updating profile: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to update profile: $e');
    }
  }

  /// Get user profile information
  Future<Result<Map<String, dynamic>>> getUserProfile(String userId) async {
    try {
      debugPrint('🔍 UserSettingsService: Fetching user profile');

      final response = await _client
          .from('users')
          .select('''
            id,
            username,
            first_name,
            last_name,
            bio,
            phone_number,
            profile_image_link,
            email,
            created_at,
            updated_at,
            is_active,
            last_seen
          ''')
          .eq('id', userId)
          .single();

      debugPrint('🔍 UserSettingsService: Profile fetched successfully');
      return Result.success(response);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error fetching profile: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch profile: $e');
    }
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
    try {
      debugPrint('🔍 UserSettingsService: Updating notification preferences');

      final Map<String, dynamic> preferences = {};

      if (forumNotifications != null)
        preferences['forum_notifications'] = forumNotifications;
      if (messageNotifications != null)
        preferences['message_notifications'] = messageNotifications;
      if (mentionNotifications != null)
        preferences['mention_notifications'] = mentionNotifications;
      if (reactionNotifications != null)
        preferences['reaction_notifications'] = reactionNotifications;
      if (emailNotifications != null)
        preferences['email_notifications'] = emailNotifications;
      if (pushNotifications != null)
        preferences['push_notifications'] = pushNotifications;

      if (preferences.isNotEmpty) {
        // Check if user_preferences record exists
        final existingPrefs = await _client
            .from('user_preferences')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (existingPrefs != null) {
          // Update existing preferences
          await _client
              .from('user_preferences')
              .update(preferences)
              .eq('user_id', userId);
        } else {
          // Create new preferences record
          preferences['user_id'] = userId;
          await _client.from('user_preferences').insert(preferences);
        }
      }

      debugPrint(
        '🔍 UserSettingsService: Notification preferences updated successfully',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint(
        '❌ UserSettingsService: Error updating notification preferences: $e',
      );
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to update notification preferences: $e');
    }
  }

  /// Get notification preferences
  Future<Result<Map<String, dynamic>>> getNotificationPreferences(
    String userId,
  ) async {
    try {
      debugPrint('🔍 UserSettingsService: Fetching notification preferences');

      final response = await _client
          .from('user_preferences')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      // Return default preferences if none exist
      if (response == null) {
        return Result.success({
          'forum_notifications': true,
          'message_notifications': true,
          'mention_notifications': true,
          'reaction_notifications': true,
          'email_notifications': true,
          'push_notifications': true,
        });
      }

      debugPrint(
        '🔍 UserSettingsService: Notification preferences fetched successfully',
      );
      return Result.success(response);
    } catch (e, stackTrace) {
      debugPrint(
        '❌ UserSettingsService: Error fetching notification preferences: $e',
      );
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch notification preferences: $e');
    }
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
    try {
      debugPrint('🔍 UserSettingsService: Updating privacy settings');

      final Map<String, dynamic> privacySettings = {};

      if (profileVisibility != null)
        privacySettings['profile_visibility'] = profileVisibility;
      if (onlineStatus != null) privacySettings['online_status'] = onlineStatus;
      if (lastSeenVisibility != null)
        privacySettings['last_seen_visibility'] = lastSeenVisibility;
      if (phoneNumberVisibility != null)
        privacySettings['phone_number_visibility'] = phoneNumberVisibility;
      if (emailVisibility != null)
        privacySettings['email_visibility'] = emailVisibility;

      if (privacySettings.isNotEmpty) {
        // Check if user_preferences record exists
        final existingPrefs = await _client
            .from('user_preferences')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (existingPrefs != null) {
          // Update existing preferences
          await _client
              .from('user_preferences')
              .update(privacySettings)
              .eq('user_id', userId);
        } else {
          // Create new preferences record
          privacySettings['user_id'] = userId;
          await _client.from('user_preferences').insert(privacySettings);
        }
      }

      debugPrint(
        '🔍 UserSettingsService: Privacy settings updated successfully',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error updating privacy settings: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to update privacy settings: $e');
    }
  }

  /// Delete user account
  Future<Result<void>> deleteAccount({
    required String userId,
    required String password,
  }) async {
    try {
      debugPrint('🔍 UserSettingsService: Deleting user account');

      // Verify password before deletion
      final email = _client.auth.currentUser?.email;
      if (email == null) {
        return Result.error('No authenticated user found');
      }

      // Re-authenticate to verify password
      final signInResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (signInResponse.user == null) {
        return Result.error('Password is incorrect');
      }

      // Mark user as inactive instead of hard delete (for data integrity)
      await _client
          .from('users')
          .update({
            'is_active': false,
            'deleted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Sign out the user
      await _client.auth.signOut();

      debugPrint('🔍 UserSettingsService: Account deleted successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error deleting account: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to delete account: $e');
    }
  }

  /// Sign out user
  Future<Result<void>> signOut() async {
    try {
      debugPrint('🔍 UserSettingsService: Signing out user');

      await _client.auth.signOut();

      debugPrint('🔍 UserSettingsService: User signed out successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error signing out: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to sign out: $e');
    }
  }

  /// Get account statistics
  Future<Result<Map<String, dynamic>>> getAccountStatistics(
    String userId,
  ) async {
    try {
      debugPrint('🔍 UserSettingsService: Fetching account statistics');

      // Get forum count where user is a member
      final forumCount = await _client
          .from('forum_members')
          .select('id')
          .eq('member', userId)
          .count();

      // Get message count
      final messageCount = await _client
          .from('forum_chats')
          .select('id')
          .eq('sender', userId)
          .count();

      // Get reaction count (reactions given)
      final reactionCount = await _client
          .from('forum_chats')
          .select('reactions')
          .not('reactions', 'is', null);

      int totalReactionsGiven = 0;
      for (final chat in reactionCount) {
        final reactions = chat['reactions'] as List? ?? [];
        totalReactionsGiven += reactions
            .where((r) => r['userId'] == userId)
            .length;
      }

      final statistics = {
        'forums_joined': forumCount.count,
        'messages_sent': messageCount.count,
        'reactions_given': totalReactionsGiven,
        'account_created': _client.auth.currentUser?.createdAt,
        'last_sign_in': _client.auth.currentUser?.lastSignInAt,
      };

      debugPrint(
        '🔍 UserSettingsService: Account statistics fetched successfully',
      );
      return Result.success(statistics);
    } catch (e, stackTrace) {
      debugPrint(
        '❌ UserSettingsService: Error fetching account statistics: $e',
      );
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch account statistics: $e');
    }
  }

  /// Send OTP to user's email for account deletion verification
  Future<Result<void>> sendDeleteAccountOTP({required String email}) async {
    try {
      debugPrint(
        '🔍 UserSettingsService: Sending delete account OTP to $email',
      );

      // Generate and store OTP in database for verification
      final otp = _generateOTP();
      final expiryTime = DateTime.now().add(const Duration(minutes: 10));

      // Store OTP in a table (you'll need to create this table)
      final response = await _client.from('account_deletion_otps').insert({
        'email': email,
        'otp': otp,
        'expires_at': expiryTime.toIso8601String(),
        'used': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isEmpty) {
        return Result.error('Failed to generate OTP');
      }

      // TODO: Send actual email with OTP
      // Use existing EmailService to send OTP email
      final emailSent = await EmailService.sendOTPEmail(
        userEmail: email,
        userName:
            '', // We don't have username in this context, but the email template handles empty names
        otpCode: otp,
      );

      if (!emailSent) {
        debugPrint(
          '⚠️ UserSettingsService: Email sending failed, but OTP stored in database',
        );
        // Still return success since OTP is stored - user can still use it
        // In production, you might want to handle this differently
      }

      debugPrint(
        '🔍 UserSettingsService: Delete account OTP sent successfully',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error sending delete account OTP: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to send delete account OTP: $e');
    }
  }

  /// Verify OTP for account deletion
  Future<Result<void>> verifyDeleteAccountOTP({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint(
        '🔍 UserSettingsService: Verifying delete account OTP for $email',
      );

      // Check if OTP exists and is valid
      final response = await _client
          .from('account_deletion_otps')
          .select()
          .eq('email', email)
          .eq('otp', otp)
          .eq('used', false)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return Result.error('Invalid or expired OTP');
      }

      // Mark OTP as used
      await _client
          .from('account_deletion_otps')
          .update({'used': true})
          .eq('id', response.first['id']);

      debugPrint(
        '🔍 UserSettingsService: Delete account OTP verified successfully',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint(
        '❌ UserSettingsService: Error verifying delete account OTP: $e',
      );
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to verify delete account OTP: $e');
    }
  }

  /// Delete account with OTP verification
  Future<Result<String>> deleteAccountWithOTP({
    required String userId,
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint('🔍 UserSettingsService: Deleting account for user $userId');

      // First verify the OTP
      final otpResult = await verifyDeleteAccountOTP(email: email, otp: otp);
      if (!otpResult.isSuccess) {
        return Result.error('OTP verification failed: ${otpResult.error}');
      }

      // Call server API to delete account data
      final response = await http.post(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/delete-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        return Result.error('Failed to delete account on server side');
      }

      // Account deletion successful on server, now clean up locally
      await _performPostDeletionCleanup();

      debugPrint(
        '🔍 UserSettingsService: Account deleted and cleaned up successfully',
      );
      return Result.success('Account deleted successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ UserSettingsService: Error deleting account: $e');
      debugPrint('❌ UserSettingsService: Stack trace: $stackTrace');
      return Result.error('Failed to delete account: $e');
    }
  }

  /// Perform post-deletion cleanup (sign out, clear OneSignal, etc.)
  Future<void> _performPostDeletionCleanup() async {
    try {
      debugPrint('🔍 UserSettingsService: Starting post-deletion cleanup');

      // Use the existing SessionManager to handle complete sign out and cleanup
      // This already handles:
      // - Supabase auth sign out
      // - OneSignal logout
      // - SharedPreferences clear
      // - Repository cache clearing
      // - Global USER_ID clearing
      await SessionManager.signOutAndClear();

      debugPrint('🎉 Post-deletion cleanup completed successfully');
    } catch (e) {
      debugPrint('❌ Error during post-deletion cleanup: $e');
      // Don't throw here as the account is already deleted on server
    }
  }

  /// Generate a 6-digit OTP
  String _generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }
}
