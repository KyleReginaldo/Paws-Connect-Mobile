import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../flavors/flavor_config.dart';
import '../config/result.dart';
import '../models/chat_filter_model.dart';

class ChatFilterService {
  // Singleton pattern
  static final ChatFilterService _instance = ChatFilterService._internal();
  factory ChatFilterService() => _instance;
  ChatFilterService._internal();

  // Cache filters to avoid frequent API calls
  List<ChatFilter>? _cachedFilters;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 10);

  /// Fetch chat filters from the API
  Future<Result<List<ChatFilter>>> fetchChatFilters({
    bool forceRefresh = false,
  }) async {
    // Return cached data if available and fresh
    if (!forceRefresh &&
        _cachedFilters != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      debugPrint('ChatFilterService: Using cached filters');
      return Result.success(_cachedFilters!);
    }

    try {
      debugPrint('ChatFilterService: Fetching filters from API');
      final uri = Uri.parse('${FlavorConfig.instance.apiBaseUrl}/chat-filters');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('ChatFilterService: Raw API response: ${response.body}');
        final filterResponse = ChatFilterResponse.fromJson(data);

        // Cache the filters
        _cachedFilters = filterResponse.data;
        _lastFetchTime = DateTime.now();

        debugPrint(
          'ChatFilterService: ✅ Successfully fetched ${filterResponse.data.length} filters',
        );

        // Log each filter for debugging
        for (final filter in filterResponse.data) {
          debugPrint(
            '  - Filter: "${filter.word}" (${filter.category}, active: ${filter.isActive}, severity: ${filter.severity})',
          );
        }

        return Result.success(filterResponse.data);
      } else {
        debugPrint(
          'ChatFilterService: Failed to fetch filters. Status: ${response.statusCode}',
        );
        return Result.error(
          'Failed to fetch chat filters. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('ChatFilterService: Error fetching filters: $e');
      return Result.error('Failed to fetch chat filters: ${e.toString()}');
    }
  }

  /// Check if a message contains any filtered words
  /// Returns a FilterValidationResult with details about violations
  Future<FilterValidationResult> validateMessage(String message) async {
    debugPrint(
      '🔍 ChatFilterService: Starting validation for message: "$message"',
    );

    if (message.trim().isEmpty) {
      debugPrint('✅ ChatFilterService: Message is empty, allowing');
      return FilterValidationResult(
        isValid: true,
        violatedWords: [],
        highestSeverity: 0,
      );
    }

    // Fetch filters (will use cache if available)
    final result = await fetchChatFilters();

    if (result.isError) {
      // On error, allow the message through but log the error
      debugPrint('⚠️ ChatFilterService: Validation error: ${result.error}');
      debugPrint(
        '⚠️ ChatFilterService: Allowing message due to filter fetch error',
      );
      return FilterValidationResult(
        isValid: true,
        violatedWords: [],
        highestSeverity: 0,
      );
    }

    final filters = result.value;
    final activeFilters = filters.where((filter) => filter.isActive).toList();
    debugPrint(
      '📋 ChatFilterService: Checking against ${activeFilters.length} active filters',
    );
    debugPrint(
      '📋 ChatFilterService: Total filters in database: ${filters.length}',
    );

    // Convert message to lowercase for case-insensitive matching
    final messageLower = message.toLowerCase();

    // Find all violated words
    final violatedWords = <ChatFilter>[];
    int highestSeverity = 0;

    for (final filter in activeFilters) {
      // Check if the word appears as a whole word in the message
      final wordPattern = RegExp(
        r'\b' + RegExp.escape(filter.word.toLowerCase()) + r'\b',
        caseSensitive: false,
      );

      if (wordPattern.hasMatch(messageLower)) {
        debugPrint(
          '🚫 ChatFilterService: VIOLATION FOUND! Word: "${filter.word}" (Category: ${filter.category}, Severity: ${filter.severity})',
        );
        violatedWords.add(filter);
        if (filter.severity > highestSeverity) {
          highestSeverity = filter.severity;
        }
      }
    }

    if (violatedWords.isEmpty) {
      debugPrint('✅ ChatFilterService: Message is clean, no violations found');
    } else {
      debugPrint(
        '❌ ChatFilterService: Found ${violatedWords.length} violations',
      );
    }

    return FilterValidationResult(
      isValid: violatedWords.isEmpty,
      violatedWords: violatedWords,
      highestSeverity: highestSeverity,
    );
  }

  /// Clear the cache
  void clearCache() {
    _cachedFilters = null;
    _lastFetchTime = null;
    debugPrint('ChatFilterService: Cache cleared');
  }

  /// Get cached filters without making an API call
  List<ChatFilter>? get cachedFilters => _cachedFilters;
}

class FilterValidationResult {
  final bool isValid;
  final List<ChatFilter> violatedWords;
  final int highestSeverity;

  FilterValidationResult({
    required this.isValid,
    required this.violatedWords,
    required this.highestSeverity,
  });

  /// Get a user-friendly message about the violation
  String getViolationMessage() {
    if (isValid) return '';

    if (violatedWords.length == 1) {
      final filter = violatedWords.first;
      return 'Your message contains inappropriate content (${filter.category}). Please revise your message.';
    } else {
      return 'Your message contains ${violatedWords.length} inappropriate words. Please revise your message.';
    }
  }

  /// Get categories of violated words
  Set<String> getViolatedCategories() {
    return violatedWords.map((filter) => filter.category).toSet();
  }
}
