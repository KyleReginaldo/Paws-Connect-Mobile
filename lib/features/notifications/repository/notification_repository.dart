import 'package:flutter/material.dart' hide Notification;
import 'package:paws_connect/features/notifications/models/notification_model.dart';
import 'package:paws_connect/features/notifications/provider/notification_provider.dart';

class NotificationRepository extends ChangeNotifier {
  List<Notification> _notifications = [];
  String _errorMessage = '';
  bool _isLoadingNotifications = false;
  List<Notification> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  bool get isLoadingNotifications => _isLoadingNotifications;
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
      notifyListeners();
    } else {
      _isLoadingNotifications = false;
      _errorMessage = '';
      _notifications = result.value;
      notifyListeners();
    }
  }
}
