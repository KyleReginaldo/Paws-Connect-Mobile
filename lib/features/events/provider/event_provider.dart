import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

class EventProvider {
  Future<Result<List<Event>>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/events'),
      );
      final data = jsonDecode(response.body);
      debugPrint('data: ${data['data']}');
      if (response.statusCode == 200) {
        List<Event> events = [];
        for (var event in data['data']) {
          events.add(EventMapper.fromMap(event));
        }
        return Result.success(events);
      } else {
        return Result.error(
          'Failed to load events. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to load events: ${e.toString()}');
    }
  }

  Future<Result<Event>> fetchEventById({required int eventId}) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/events/$eventId'),
      );
      final data = jsonDecode(response.body);
      debugPrint('data: ${data['data']}');
      if (response.statusCode == 200) {
        final event = EventMapper.fromMap(data['data']);
        return Result.success(event);
      } else {
        return Result.error(
          'Failed to load event. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to load event: ${e.toString()}');
    }
  }

  Future<Result<String>> uploadComment({
    required String userId,
    required String eventId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/events/$eventId/comment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': userId, 'content': content}),
    );
    if (response.statusCode == 201) {
      return Result.success('Comment uploaded successfully');
    } else {
      return Result.error(
        'Failed to upload comment. Server returned ${response.statusCode}',
      );
    }
  }

  Future<Result<String>> likeComment({required int commentId}) async {
    final response = await supabase.rpc(
      'increment_comment_like',
      params: {'comment_id': commentId, 'step': 1},
    );
    if (response.error == null) {
      return Result.success('Comment liked successfully');
    } else {
      return Result.error(
        'Failed to like comment. Server returned ${response.error!.message}',
      );
    }
  }

  Future<Result<String>> unlikeComment({required int commentId}) async {
    final response = await supabase.rpc(
      'decrement_comment_like',
      params: {'comment_id': commentId, 'step': 1},
    );
    if (response.error == null) {
      return Result.success('Comment unliked successfully');
    } else {
      return Result.error(
        'Failed to unlike comment. Server returned ${response.error!.message}',
      );
    }
  }
}
