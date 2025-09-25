import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../provider/profile_provider.dart';

class ProfileRepository extends ChangeNotifier {
  final ProfileProvider _profileProvider;
  List<UserProfile> _users = [];
  List<UserProfile> get users => _users;
  ProfileRepository(this._profileProvider);
  UserProfile? _visitedProfile;
  UserProfile? get visitedProfile => _visitedProfile;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  bool _profileLoading = false;
  bool _visitedProfileLoading = false;
  bool get profileLoading => _profileLoading;
  bool get visitedProfileLoading => _visitedProfileLoading;

  Future<void> fetchUserProfile(String userId) async {
    _profileLoading = true;
    notifyListeners();
    final result = await _profileProvider.getUserProfile(userId);
    if (result.isSuccess) {
      // debugPrint('Fetched user profile: ${result.value}'); // Commented to reduce console spam
      _userProfile = result.value;
      _profileLoading = false;

      notifyListeners();
    } else {
      debugPrint('Error fetching user profile: ${result.error}');
      _userProfile = null;
      _profileLoading = false;

      notifyListeners();
    }
  }

  Future<void> fetchVisitedProfile(String userId) async {
    _visitedProfileLoading = true;
    notifyListeners();

    final result = await _profileProvider.getUserProfile(userId);
    if (result.isSuccess) {
      debugPrint('Fetched visited profile: ${result.value}');
      _visitedProfile = result.value;
      _visitedProfileLoading = false;

      notifyListeners();
    } else {
      debugPrint('Error fetching visited profile: ${result.error}');
      _visitedProfile = null;
      _visitedProfileLoading = false;

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

  // Clear cached profile state on sign out
  void reset() {
    _users = [];
    _visitedProfile = null;
    _userProfile = null;
    _profileLoading = false;
    _visitedProfileLoading = false;
    notifyListeners();
  }
}
