import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/notifications/models/notification_model.dart';

import '../../../core/config/result.dart';

class NotificationProvider {
  // Default pagination configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Fetches notifications for a specific user with pagination support
  ///
  /// [userId] - The ID of the user to fetch notifications for
  /// [page] - The page number to fetch (1-based indexing)
  /// [limit] - The number of notifications per page (max 100)
  Future<Result<List<Notification>>> fetchNotification(
    String userId, {
    int page = 1,
    int limit = defaultPageSize,
  }) async {
    // Validate parameters
    if (page < 1) {
      return Result.error('Page number must be greater than 0');
    }
    if (limit < 1 || limit > maxPageSize) {
      return Result.error('Limit must be between 1 and $maxPageSize');
    }

    final baseUrl = dotenv.get('BASE_URL');
    final url = '$baseUrl/notifications/user/$userId?page=$page&limit=$limit';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      List<Notification> notifications = [];

      if (response.statusCode == 200) {
        // Handle both array and object responses
        final notificationData = data['data'] ?? data;
        if (notificationData is List) {
          for (var item in notificationData) {
            notifications.add(NotificationMapper.fromMap(item));
          }
        }
        return Result.success(notifications);
      } else {
        final errorMessage =
            data['message'] ??
            data['error'] ??
            'Failed to fetch notifications. Server returned ${response.statusCode}';
        return Result.error(errorMessage);
      }
    } catch (e) {
      return Result.error('Network error: ${e.toString()}');
    }
  }

  Future<void> markAllViewed(String userId) async {
    await http.put(
      Uri.parse('${dotenv.get('BASE_URL')}/notifications/user/$userId/view'),
    );
  }

  Future<Result<String>> removeNotifications({
    required List<int> ids,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/notifications/user/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notificationIds': ids}),
    );

    if (response.statusCode == 200) {
      return Result.success('Notifications removed successfully');
    } else {
      final data = jsonDecode(response.body);
      final errorMessage =
          data['message'] ??
          data['error'] ??
          'Failed to remove notifications. Server returned ${response.statusCode}';
      return Result.error(errorMessage);
    }
  }
}
