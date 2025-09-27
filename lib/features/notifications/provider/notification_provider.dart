import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/notifications/models/notification_model.dart';

import '../../../core/config/result.dart';

class NotificationProvider {
  Future<Result<List<Notification>>> fetchNotification(String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/notifications/user/$userId'),
    );
    final data = jsonDecode(response.body);
    List<Notification> notifications = [];
    if (response.statusCode == 200) {
      data['data'].forEach((notificationData) {
        notifications.add(NotificationMapper.fromMap(notificationData));
      });
      return Result.success(notifications);
    } else {
      return Result.error(
        'Failed to fetch notifications. Server returned ${response.statusCode}',
      );
    }
  }
}
