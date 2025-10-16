import 'package:flutter/foundation.dart';

import '../supabase/client.dart';

class UserIdNotifier extends ChangeNotifier {
  static final UserIdNotifier _instance = UserIdNotifier._internal();
  factory UserIdNotifier() => _instance;
  UserIdNotifier._internal() {
    // Initialize with current USER_ID if available
    _userId = USER_ID;
  }

  String? _userId;

  String? get userId => _userId;

  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      print('🎯 USER_ID_NOTIFIER: USER_ID changed to: $userId');
      notifyListeners();
    }
  }

  void clearUserId() {
    if (_userId != null) {
      _userId = null;
      print('🎯 USER_ID_NOTIFIER: USER_ID cleared');
      notifyListeners();
    }
  }
}
