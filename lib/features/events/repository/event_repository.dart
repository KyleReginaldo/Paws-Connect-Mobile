import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

import '../provider/event_provider.dart';

class EventRepository extends ChangeNotifier {
  List<Event>? _events;
  Event? _event;
  bool _singleEventLoading = false;
  final Set<int> _eventsWithGeneratedSuggestions = <int>{};

  List<Event>? get events => _events;

  Event? get event => _event;
  bool get singleEventLoading => _singleEventLoading;

  final EventProvider _eventProvider;

  EventRepository(this._eventProvider);

  Future fetchEvents() async {
    final result = await _eventProvider.fetchEvents();
    if (result.isSuccess) {
      _events = result.value;

      // Auto-generate suggestions for events that don't have any
      if (_events != null) {
        await _generateMissingSuggestions();
      }

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

      // Auto-generate suggestions if the event doesn't have any
      if (_event != null &&
          (_event!.suggestions == null || _event!.suggestions!.isEmpty) &&
          !_eventsWithGeneratedSuggestions.contains(_event!.id)) {
        try {
          debugPrint(
            'Generating suggestions for single event: "${_event!.title}"',
          );
          final suggestions = await _generateSuggestionsForEvent(_event!);
          if (suggestions.isNotEmpty) {
            _event = _event!.copyWith(suggestions: suggestions);
            _eventsWithGeneratedSuggestions.add(_event!.id);
            debugPrint(
              'Generated ${suggestions.length} suggestions for "${_event!.title}": ${suggestions.join(", ")}',
            );
          }
        } catch (e) {
          debugPrint('Failed to generate suggestions for event $eventId: $e');
        }
      }

      _singleEventLoading = false;
      notifyListeners();
    } else {
      _event = null;
      _singleEventLoading = false;
      notifyListeners();
    }
  }

  Future reloadComments({required int eventId}) async {
    final result = await _eventProvider.fetchEventById(eventId: eventId);
    if (result.isSuccess) {
      _event = result.value;
      notifyListeners();
    } else {
      _event = null;
      notifyListeners();
    }
  }

  /// Join an event and update local state
  Future<String?> joinEvent({
    required int eventId,
    required String userId,
  }) async {
    final result = await _eventProvider.joinEvent(
      eventId: eventId,
      userId: userId,
    );

    if (result.isSuccess) {
      // Refresh the event data to get updated members list
      await fetchEventById(eventId: eventId);
      return result.value;
    } else {
      return result.error;
    }
  }

  /// Leave an event and update local state
  Future<String?> leaveEvent({
    required int eventId,
    required String userId,
  }) async {
    final result = await _eventProvider.leaveEvent(
      eventId: eventId,
      userId: userId,
    );

    if (result.isSuccess) {
      // Refresh the event data to get updated members list
      await fetchEventById(eventId: eventId);
      return result.value;
    } else {
      return result.error;
    }
  }

  /// Generate suggestions for events that don't have any
  Future<void> _generateMissingSuggestions() async {
    if (_events == null) return;

    final eventsNeedingSuggestions = _events!
        .where(
          (event) =>
              (event.suggestions == null || event.suggestions!.isEmpty) &&
              !_eventsWithGeneratedSuggestions.contains(event.id),
        )
        .toList();

    if (eventsNeedingSuggestions.isEmpty) {
      debugPrint('All events already have suggestions');
      return;
    }

    debugPrint(
      'Generating suggestions for ${eventsNeedingSuggestions.length} events...',
    );

    for (final event in eventsNeedingSuggestions) {
      try {
        debugPrint('Generating suggestions for event: "${event.title}"');
        final suggestions = await _generateSuggestionsForEvent(event);
        if (suggestions.isNotEmpty) {
          // Update the local event with generated suggestions
          final updatedEvent = event.copyWith(suggestions: suggestions);
          final index = _events!.indexWhere((e) => e.id == event.id);
          if (index != -1) {
            _events![index] = updatedEvent;
            _eventsWithGeneratedSuggestions.add(event.id);
            debugPrint(
              'Generated ${suggestions.length} suggestions for "${event.title}": ${suggestions.join(", ")}',
            );
          }
        }
      } on TimeoutException catch (e) {
        debugPrint('Timeout generating suggestions for event ${event.id}: $e');
        // Continue with other events even if one times out
      } catch (e) {
        debugPrint('Failed to generate suggestions for event ${event.id}: $e');
        // Continue with other events even if one fails
      }
    }

    // Notify listeners only once after all suggestions are generated
    if (eventsNeedingSuggestions.isNotEmpty) {
      debugPrint('Finished generating suggestions. Notifying listeners...');
      notifyListeners();
    }
  }

  /// Generate AI-powered suggestions for a specific event
  Future<List<String>> _generateSuggestionsForEvent(Event event) async {
    try {
      final response = await Gemini.instance
          .prompt(
            safetySettings: [
              SafetySetting(
                category: SafetyCategory.harassment,
                threshold: SafetyThreshold.blockLowAndAbove,
              ),
            ],
            parts: [
              Part.text(
                'Context: You are helping users with a pet adoption/animal welfare organization located at "Blk 4, 23 Officers Avenue, Bacoor, Cavite". '
                'This organization focuses on pet adoption, animal shelter services, fundraising campaigns, donation drives, community forums, community outreach, and various pet-related events.\n\n'
                'Based on this specific event: "${event.title}" with description: "${event.description}", '
                'generate 4-5 helpful suggestion topics that people interested in this event might want to know more about. '
                'These should be short, concise phrases (2-4 words each) that relate specifically to pet/animal welfare activities. '
                'Consider topics like: "What to bring", "Adoption process", "Pet requirements", "Preparation tips", "Documents needed", "Cost information", "Pet care", '
                '"Location details", "Parking info", "Volunteer opportunities", "Donation needs", "Contact information", "Event schedule", "Age restrictions".\n\n'
                'If someone asks about location, mention it\'s at Blk 4, 23 Officers Avenue, Bacoor, Cavite. '
                'Focus on practical, actionable information that would be most helpful for someone planning to attend or participate. '
                'Return only the 4-5 suggestion topics separated by commas, no other text.',
              ),
            ],
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Request timed out',
              Duration(seconds: 30),
            ),
          );

      if (response?.output != null) {
        final suggestions = response!.output!
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .take(5) // Limit to 5 suggestions max
            .toList();

        return suggestions;
      }
    } catch (e) {
      debugPrint('Error generating suggestions for event ${event.title}: $e');
    }

    // Return default pet-related suggestions if Gemini fails
    return [
      'Location details',
      'What to bring',
      'Adoption process',
      'Donation needs',
      'Event schedule',
    ];
  }
}
