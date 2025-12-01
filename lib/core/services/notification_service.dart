import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotificationResult {
  final bool success;
  final int successCount;
  final int failureCount;
  final String? errorMessage;
  final List<String>? failedUserIds;

  const NotificationResult({
    required this.success,
    this.successCount = 0,
    this.failureCount = 0,
    this.errorMessage,
    this.failedUserIds,
  });

  @override
  String toString() {
    return 'NotificationResult(success: $success, successCount: $successCount, failureCount: $failureCount, error: $errorMessage)';
  }
}

class NotificationService {
  static const String _oneSignalApiUrl =
      'https://api.onesignal.com/notifications?c=push';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 1000);
  static const Duration _requestTimeout = Duration(seconds: 10);
  static const String _androidChannelId =
      'fa9e4583-4994-4f73-97d9-0e652bb0cca0';

  // Track app state to prevent notifications when app is in foreground
  static bool _isAppInForeground = true;

  /// Call this method to update app foreground state
  static void setAppForegroundState(bool isInForeground) {
    _isAppInForeground = isInForeground;
    if (kDebugMode) {
      print(
        '[NotificationService] App state: ${isInForeground ? 'FOREGROUND' : 'BACKGROUND'}',
      );
    }
  }

  /// Get current app foreground state
  static bool get isAppInForeground => _isAppInForeground;

  static void _logError(String context, dynamic error) {
    if (kDebugMode) {
      print('[NotificationService] ERROR in $context: $error');
    }
  }

  static void _logSuccess(String context) {
    if (kDebugMode) {
      print('[NotificationService] SUCCESS: $context');
    }
  }

  static Future<NotificationResult> sendNotification({
    required List<String> userIds,
    required String title,
    required String content,
    Map<String, dynamic>? data,
    String? imageUrl,
    int retryCount = 0,
    bool forceNotification =
        false, // Allow forcing notification even when app is in foreground
  }) async {
    // Always send notifications; suppression is handled on receiver side.

    try {
      final appId = dotenv.get('ONESIGNAL_APP_ID', fallback: '');
      final restApiKey = dotenv.get('ONESIGNAL_REST_API_KEY', fallback: '');

      if (appId.isEmpty || restApiKey.isEmpty) {
        return const NotificationResult(
          success: false,
          errorMessage: 'OneSignal credentials not found',
        );
      }

      final body = {
        "app_id": appId,
        "contents": {"en": content.trim()},
        "headings": {"en": title.trim()},
        "target_channel": 'push',
        "android_channel_id": _androidChannelId,
        "priority": 10,
        "ttl": 259200,
        "include_aliases": {"external_id": userIds},
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        body["big_picture"] = imageUrl;
      }

      if (data != null && data.isNotEmpty) {
        body["data"] = data;
      }

      final response = await http
          .post(
            Uri.parse(_oneSignalApiUrl),
            body: jsonEncode(body),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer Key $restApiKey',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final recipients = responseData['recipients'] as int? ?? userIds.length;

        _logSuccess('Notification sent successfully');
        return NotificationResult(
          success: true,
          successCount: recipients,
          failureCount: userIds.length - recipients,
        );
      } else {
        final errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        _logError('sendNotification', errorMsg);

        if (retryCount < _maxRetries && response.statusCode >= 500) {
          await Future.delayed(_retryDelay);
          return sendNotification(
            userIds: userIds,
            title: title,
            content: content,
            data: data,
            imageUrl: imageUrl,
            retryCount: retryCount + 1,
            forceNotification: forceNotification,
          );
        }

        return NotificationResult(
          success: false,
          failureCount: userIds.length,
          errorMessage: errorMsg,
        );
      }
    } catch (e) {
      _logError('sendNotification', e);
      return NotificationResult(
        success: false,
        failureCount: userIds.length,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<bool> sendForumReactionNotification({
    required String recipientId,
    required String reactorName,
    required String reaction,
    required String originalMessage,
    required int forumId,
    required int chatId,
    bool forceNotification = false,
  }) async {
    final result = await sendNotification(
      userIds: [recipientId],
      title: 'Someone reacted to your message',
      content:
          '$reactorName reacted $reaction to: "${originalMessage.length > 30 ? '${originalMessage.substring(0, 30)}...' : originalMessage}"',
      data: {
        'type': 'forum_reaction',
        'forumId': forumId.toString(),
        'chatId': chatId.toString(),
        'reactorName': reactorName,
        'reaction': reaction,
      },
      forceNotification: forceNotification,
    );

    return result.success;
  }

  static Future<bool> sendForumChatNotification({
    required String recipientId,
    required String senderName,
    required String message,
    required int forumId,
    required int chatId,
    String? forumName,
    bool forceNotification = false,
  }) async {
    final result = await sendNotification(
      userIds: [recipientId],
      title: forumName != null
          ? 'New message in $forumName'
          : 'New Forum Message',
      content:
          '$senderName: ${message.length > 50 ? '${message.substring(0, 50)}...' : message}',
      data: {
        'type': 'forum_chat',
        'forumId': forumId.toString(),
        'chatId': chatId.toString(),
        'senderId': senderName,
      },
      forceNotification: forceNotification,
    );

    return result.success;
  }

  static Future<NotificationResult> sendMentionNotification({
    required String recipientId,
    required String senderName,
    required String message,
    required int forumId,
    required int chatId,
    String? forumName,
    bool forceNotification = false,
  }) async {
    return sendNotification(
      userIds: [recipientId],
      title: '$senderName mentioned you',
      content:
          'In ${forumName ?? 'forum'}: ${message.length > 50 ? '${message.substring(0, 50)}...' : message}',
      data: {
        'type': 'mention',
        'forumId': forumId.toString(),
        'chatId': chatId.toString(),
        'senderId': senderName,
        'mentionType': 'forum_mention',
      },
      forceNotification: forceNotification,
    );
  }

  static Future<bool> sendForumMemberNotification({
    required List<String> memberIds,
    required String senderName,
    required String message,
    required int forumId,
    required int chatId,
    String? forumName,
    bool forceNotification = false,
    bool isMuted = false,
  }) async {
    if (isMuted) {
      return true;
    }
    final result = await sendNotification(
      userIds: memberIds,
      title: forumName != null
          ? 'New message in $forumName'
          : 'New Forum Message',
      content:
          '$senderName: ${message.length > 50 ? '${message.substring(0, 50)}...' : message}',
      data: {
        'type': 'forum_chat',
        'forumId': forumId.toString(),
        'chatId': chatId.toString(),
        'senderId': senderName,
      },
      forceNotification: forceNotification,
    );

    return result.success;
  }
}
