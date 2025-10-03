import 'package:flutter/material.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

import '../provider/event_provider.dart';

class EventRepository extends ChangeNotifier {
  List<Event>? _events;
  List<Event>? get events => _events;

  final EventProvider _eventProvider;

  EventRepository(this._eventProvider);

  Future fetchEvents() async {
    final result = await _eventProvider.fetchEvents();
    if (result.isSuccess) {
      _events = result.value;
      notifyListeners();
    } else {
      _events = null;
    }
  }
}
