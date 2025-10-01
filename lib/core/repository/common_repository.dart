import 'package:flutter/material.dart';
import 'package:paws_connect/core/provider/common_provider.dart';

class CommonRepository extends ChangeNotifier {
  int? _messageCount;
  int? _notificationCount;
  int? get messageCount => _messageCount;
  int? get notificationCount => _notificationCount;
  final CommonProvider _provider;
  CommonRepository(this._provider);

  void getMessageCount(String userId) async {
    final result = await _provider.fetchUserUnviewedMessagesCount(userId);
    if (result.isSuccess) {
      _messageCount = result.value;
      notifyListeners();
    } else {
      _messageCount = null;
      notifyListeners();
    }
  }

  void getNotificationCount(String userId) async {
    final result = await _provider.fetchUserUnviewedNotificationsCount(userId);
    if (result.isSuccess) {
      _notificationCount = result.value;
      notifyListeners();
    } else {
      _notificationCount = null;
      notifyListeners();
    }
  }

  void clear() {
    _messageCount = null;
    _notificationCount = null;
    notifyListeners();
  }

  Future<void> markMessagesViewed({
    required String userId,
    required int forumId,
  }) async {
    final result = await _provider.markForumMessagesAsViewed(
      userId: userId,
      forumId: forumId,
    );
    if (result.isSuccess) {
      // Refresh count after marking viewed
      getMessageCount(userId);
    }
  }

  Future<void> markNotificationsViewed(String userId) async {
    final result = await _provider.markAllNotificationsAsViewed(userId);
    if (result.isSuccess) {
      // Refresh count after marking viewed
      getNotificationCount(userId);
    }
  }
}
