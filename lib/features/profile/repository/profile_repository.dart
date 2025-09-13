import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../provider/profile_provider.dart';

class ProfileRepository extends ChangeNotifier {
  final ProfileProvider _profileProvider;
  List<UserProfile> _users = [];
  List<UserProfile> get users => _users;
  ProfileRepository(this._profileProvider);

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<void> fetchUserProfile(String userId) async {
    final result = await _profileProvider.getUserProfile(userId);
    if (result.isSuccess) {
      debugPrint('Fetched user profile: ${result.value}');
      _userProfile = result.value;
      notifyListeners();
    } else {
      debugPrint('Error fetching user profile: ${result.error}');
      _userProfile = null;
      notifyListeners();
    }
  }

  void fetchUsers() async {
    final result = await _profileProvider.fetchUsers();
    if (result.isSuccess) {
      debugPrint('Fetched users: ${result.value}');
      _users = result.value;
      notifyListeners();
    } else {
      debugPrint('Error fetching users: ${result.error}');
      _users = [];
      notifyListeners();
    }
  }
}
