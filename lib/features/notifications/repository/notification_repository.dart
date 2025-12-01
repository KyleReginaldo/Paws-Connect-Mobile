import 'package:flutter/material.dart' hide Notification;
import 'package:paws_connect/core/repository/common_repository.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/notifications/models/notification_model.dart';
import 'package:paws_connect/features/notifications/provider/notification_provider.dart';

class NotificationRepository extends ChangeNotifier {
  List<Notification> _notifications = [];
  String _errorMessage = '';
  bool _isLoadingNotifications = false;
  bool _isLoadingMoreNotifications = false;
  bool _hasMoreNotifications = true;
  int _currentPage = 1;
  final int _pageLimit;
  int _unreadCount = 0;
  final List<int> _notificationIds = [];
  List<int> get notificationIds => _notificationIds;

  List<Notification> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isLoadingMoreNotifications => _isLoadingMoreNotifications;
  bool get hasMoreNotifications => _hasMoreNotifications;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  int get pageLimit => _pageLimit;

  final NotificationProvider provider;

  NotificationRepository(this.provider, {int? pageLimit})
    : _pageLimit = pageLimit ?? NotificationProvider.defaultPageSize;

  void addNotificationId(int id) {
    if (!_notificationIds.contains(id)) {
      _notificationIds.add(id);
      notifyListeners();
    }
  }

  void removeNotificationId(int id) {
    if (_notificationIds.contains(id)) {
      _notificationIds.remove(id);
      notifyListeners();
    }
  }

  void clearNotificationIds() {
    if (_notificationIds.isNotEmpty) {
      _notificationIds.clear();
      notifyListeners();
    }
  }

  void selectAllNotificationIds() {
    final allIds = _notifications.map((n) => n.id).toList();
    if (_notificationIds.length != allIds.length) {
      _notificationIds
        ..clear()
        ..addAll(allIds);
      notifyListeners();
    }
  }

  Future<void> fetchNotifications(String userId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreNotifications = true;
      _notifications.clear();
    }

    _isLoadingNotifications = true;
    notifyListeners();

    final result = await provider.fetchNotification(
      userId,
      page: _currentPage,
      limit: _pageLimit,
    );

    if (result.isError) {
      _isLoadingNotifications = false;
      if (_currentPage == 1) {
        _notifications = [];
        _unreadCount = 0;
      }
      _errorMessage = result.error;
      notifyListeners();
    } else {
      _isLoadingNotifications = false;
      _errorMessage = '';

      final newNotifications = result.value;

      if (_currentPage == 1) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }

      // Check if there are more notifications to load
      _hasMoreNotifications = newNotifications.length == _pageLimit;

      _unreadCount = _notifications.where((n) => n.isViewed == false).length;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications(String userId) async {
    if (_isLoadingMoreNotifications || !_hasMoreNotifications) return;

    _isLoadingMoreNotifications = true;
    _currentPage++;
    notifyListeners();

    final result = await provider.fetchNotification(
      userId,
      page: _currentPage,
      limit: _pageLimit,
    );

    _isLoadingMoreNotifications = false;

    if (result.isError) {
      _currentPage--; // Revert page increment on error
      _errorMessage = result.error;
    } else {
      _errorMessage = '';
      final newNotifications = result.value;
      _notifications.addAll(newNotifications);

      // Check if there are more notifications to load
      _hasMoreNotifications = newNotifications.length == _pageLimit;

      _unreadCount = _notifications.where((n) => n.isViewed == false).length;
    }

    notifyListeners();
  }

  void refreshNotifications(String userId) {
    fetchNotifications(userId, refresh: true);
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
      // Update global notification badge count immediately
      try {
        sl<CommonRepository>().getNotificationCount(userId);
      } catch (_) {}
    }
    try {
      await provider.markAllViewed(userId);
      // Refresh first page to get updated data from server
      refreshNotifications(userId);
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
        // Update global notification badge count immediately
        final uid = USER_ID;
        if (uid != null && uid.isNotEmpty) {
          try {
            sl<CommonRepository>().getNotificationCount(uid);
          } catch (_) {}
        }
        break;
      }
    }
  }

  // Reset pagination state
  void resetPaginationState() {
    _currentPage = 1;
    _hasMoreNotifications = true;
    _notifications.clear();
    _errorMessage = '';
    _isLoadingNotifications = false;
    _isLoadingMoreNotifications = false;
    _unreadCount = 0;
    notifyListeners();
  }

  // Get pagination info for debugging/analytics
  Map<String, dynamic> getPaginationInfo() {
    return {
      'currentPage': _currentPage,
      'pageLimit': _pageLimit,
      'totalNotifications': _notifications.length,
      'hasMoreNotifications': _hasMoreNotifications,
      'isLoadingNotifications': _isLoadingNotifications,
      'isLoadingMoreNotifications': _isLoadingMoreNotifications,
      'unreadCount': _unreadCount,
    };
  }

  // Get loading state summary
  bool get isAnyLoading =>
      _isLoadingNotifications || _isLoadingMoreNotifications;
}
