import 'package:flutter/material.dart';
import 'package:paws_connect/features/settings/provider/user_settings_provider.dart';

class UserSettingsRepository extends ChangeNotifier {
  final UserSettingsProvider _provider;

  UserSettingsRepository(this._provider);

  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _notificationPreferences;
  Map<String, dynamic>? _accountStatistics;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  Map<String, dynamic>? get notificationPreferences => _notificationPreferences;
  Map<String, dynamic>? get accountStatistics => _accountStatistics;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Load user profile
  Future<void> loadUserProfile(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.getUserProfile(userId);

      if (result.isSuccess) {
        _userProfile = result.value;
      } else {
        _setError(result.error);
      }
    } catch (e) {
      _setError('Failed to load user profile: $e');
    }

    _setLoading(false);
  }

  /// Load notification preferences
  Future<void> loadNotificationPreferences(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.getNotificationPreferences(userId);

      if (result.isSuccess) {
        _notificationPreferences = result.value;
      } else {
        _setError(result.error);
      }
    } catch (e) {
      _setError('Failed to load notification preferences: $e');
    }

    _setLoading(false);
  }

  /// Load account statistics
  Future<void> loadAccountStatistics(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.getAccountStatistics(userId);

      if (result.isSuccess) {
        _accountStatistics = result.value;
      } else {
        _setError(result.error);
      }
    } catch (e) {
      _setError('Failed to load account statistics: $e');
    }

    _setLoading(false);
  }

  /// Change password
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to change password: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.updateProfile(
        userId: userId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      if (result.isSuccess) {
        // Reload profile to get updated data
        await loadUserProfile(userId);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences({
    required String userId,
    bool? forumNotifications,
    bool? messageNotifications,
    bool? mentionNotifications,
    bool? reactionNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.updateNotificationPreferences(
        userId: userId,
        forumNotifications: forumNotifications,
        messageNotifications: messageNotifications,
        mentionNotifications: mentionNotifications,
        reactionNotifications: reactionNotifications,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
      );

      if (result.isSuccess) {
        // Reload preferences to get updated data
        await loadNotificationPreferences(userId);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update notification preferences: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings({
    required String userId,
    bool? profileVisibility,
    bool? onlineStatus,
    bool? lastSeenVisibility,
    bool? phoneNumberVisibility,
    bool? emailVisibility,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.updatePrivacySettings(
        userId: userId,
        profileVisibility: profileVisibility,
        onlineStatus: onlineStatus,
        lastSeenVisibility: lastSeenVisibility,
        phoneNumberVisibility: phoneNumberVisibility,
        emailVisibility: emailVisibility,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update privacy settings: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount({
    required String userId,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.deleteAccount(
        userId: userId,
        password: password,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete account: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.signOut();

      if (result.isSuccess) {
        // Clear all data
        reset();
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to sign out: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset repository state
  void reset() {
    _userProfile = null;
    _notificationPreferences = null;
    _accountStatistics = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Send OTP for account deletion
  Future<bool> sendDeleteAccountOTP({required String email}) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.sendDeleteAccountOTP(email: email);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to send OTP: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Verify OTP for account deletion
  Future<bool> verifyDeleteAccountOTP({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.verifyDeleteAccountOTP(
        email: email,
        otp: otp,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to verify OTP: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete account with OTP verification
  Future<bool> deleteAccountWithOTP({
    required String userId,
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _provider.deleteAccountWithOTP(
        userId: userId,
        email: email,
        otp: otp,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete account: $e');
      _setLoading(false);
      return false;
    }
  }
}
