import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

class EventProvider {
  Future<Result<List<Event>>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/events'),
      );
      final data = jsonDecode(response.body);
      // debugPrint('Event Data: ${data['data']}'); // Commented to reduce console spam
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
}
