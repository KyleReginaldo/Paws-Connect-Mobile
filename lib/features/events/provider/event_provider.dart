import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/features/events/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../flavors/flavor_config.dart';

class EventProvider {
  Future<Result<List<Event>>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/events'),
      );
      final data = jsonDecode(response.body);
      debugPrint('data: ${data['data']}');
      if (response.statusCode == 200) {
        List<Event> events = [];
        for (var event in data['data']) {
          if (event['ended_at'] != null) {
            events.add(EventMapper.fromMap(event));
          }
        }
        return Result.success(events);
      } else {
        return Result.error('Failed to load events');
      }
    } catch (e) {
      return Result.error('Failed to load events');
    }
  }

  Future<Result<Event>> fetchEventById({required int eventId}) async {
    try {
      final response = await http.get(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/events/$eventId'),
      );
      final data = jsonDecode(response.body);
      debugPrint('data: ${data['data']}');
      if (response.statusCode == 200) {
        final event = EventMapper.fromMap(data['data']);
        return Result.success(event);
      } else {
        return Result.error('Failed to load event');
      }
    } catch (e) {
      return Result.error('Failed to load event');
    }
  }

  Future<Result<String>> uploadComment({
    required String userId,
    required int eventId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/events/$eventId/comment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': userId, 'content': content}),
    );
    if (response.statusCode == 201) {
      return Result.success('Comment uploaded successfully');
    } else {
      return Result.error('Failed to comment');
    }
  }

  Future<Result<String>> toogleLike({
    required int commentId,
    required String userId,
  }) async {
    try {
      await supabase.rpc(
        'toggle_comment_like',
        params: {'comment_id': commentId, 'user_id': userId},
      );
      return Result.success('Reacted to comment');
    } on PostgrestException catch (_) {
      return Result.error('Failed to react');
    } catch (e) {
      return Result.error('Failed to react');
    }
  }

  Future<Result<String>> joinEvent({
    required int eventId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.success('Successfully joined the event!');
      } else {
        return Result.error(
          data['message'] ??
              data['error'] ??
              'Failed to join event. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to join event: ${e.toString()}');
    }
  }

  Future<Result<String>> leaveEvent({
    required int eventId,
    required String userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Result.success(
          data['message'] ?? 'Successfully left the event!',
        );
      } else {
        return Result.error(
          data['message'] ??
              data['error'] ??
              'Failed to leave event. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to leave event: ${e.toString()}');
    }
  }
}
