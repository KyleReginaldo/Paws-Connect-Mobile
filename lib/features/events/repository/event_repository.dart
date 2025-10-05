import 'package:flutter/material.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

import '../provider/event_provider.dart';

class EventRepository extends ChangeNotifier {
  List<Event>? _events;
  Event? _event;
  bool _singleEventLoading = false;
  List<Event>? get events => _events;

  Event? get event => _event;
  bool get singleEventLoading => _singleEventLoading;

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

  Future fetchEventById({required int eventId}) async {
    _singleEventLoading = true;
    notifyListeners();
    final result = await _eventProvider.fetchEventById(eventId: eventId);
    if (result.isSuccess) {
      _event = result.value;
      _singleEventLoading = false;
      notifyListeners();
    } else {
      _event = null;
      _singleEventLoading = false;
      notifyListeners();
    }
  }
}
