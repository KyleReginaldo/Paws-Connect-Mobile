import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../provider/profile_provider.dart';

class ProfileRepository extends ChangeNotifier {
  final ProfileProvider _profileProvider;
  ProfileRepository(this._profileProvider);

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<void> fetchUserProfile(String userId) async {
    final result = await _profileProvider.getUserProfile(userId);
    if (result.isSuccess) {
      _userProfile = result.value;
      notifyListeners();
    } else {
      _userProfile = null;
      notifyListeners();
    }
  }
}
