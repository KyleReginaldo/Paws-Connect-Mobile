import 'package:flutter/material.dart' hide Notification;
import 'package:paws_connect/features/notifications/models/notification_model.dart';
import 'package:paws_connect/features/notifications/provider/notification_provider.dart';

class NotificationRepository extends ChangeNotifier {
  List<Notification> _notifications = [];
  String _errorMessage = '';
  bool _isLoadingNotifications = false;
  int _unreadCount = 0;
  List<Notification> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  bool get isLoadingNotifications => _isLoadingNotifications;
  int get unreadCount => _unreadCount;
  final NotificationProvider provider;

  NotificationRepository(this.provider);

  Future<void> fetchNotifications(String userId) async {
    _isLoadingNotifications = true;
    notifyListeners();
    final result = await provider.fetchNotification(userId);
    if (result.isError) {
      _isLoadingNotifications = false;
      _notifications = [];
      _errorMessage = result.error;
      _unreadCount = 0;
      notifyListeners();
    } else {
      _isLoadingNotifications = false;
      _errorMessage = '';
      _notifications = result.value;
      _unreadCount = _notifications.where((n) => n.isViewed == false).length;
      notifyListeners();
    }
  }

  void markAllViewed(String userId) async {
    // Optimistic update
    bool changed = false;
    _notifications = _notifications.map((n) {
      if (n.isViewed == false) {
        changed = true;
        return n.copyWith(isViewed: true);
      }
      return n;
    }).toList();
    if (changed) {
      _unreadCount = 0;
      notifyListeners();
    }
    try {
      await provider.markAllViewed(userId);
      // Optionally refetch
      fetchNotifications(userId);
    } catch (_) {
      // ignore errors; state will refresh on next fetch
    }
  }

  // Optimistically mark a single notification as viewed
  void markSingleViewed(int notificationId) {
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if (n.id == notificationId && n.isViewed == false) {
        _notifications[i] = n.copyWith(isViewed: true);
        if (_unreadCount > 0) _unreadCount -= 1;
        notifyListeners();
        break;
      }
    }
  }
}
