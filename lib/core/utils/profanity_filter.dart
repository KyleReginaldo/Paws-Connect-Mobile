import 'package:flutter/foundation.dart';

/// A simple profanity filter for content moderation
class ProfanityFilter {
  // Basic list of inappropriate words - this can be expanded
  static const List<String> _bannedWords = [
    // Basic profanity (English)
    'fuck', 'shit', 'damn', 'hell', 'bitch', 'ass', 'crap',
    'wtf', 'stfu', 'goddamn',

    // Hate speech and slurs (add carefully based on community guidelines)
    'nigger', 'faggot', 'retard', 'nazi', 'hitler',

    // Sexual content
    'porn', 'sex', 'xxx', 'penis', 'vagina', 'boobs', 'dick',
    'cum', 'blowjob', 'bj', 'anal',

    // Drug related
    'cocaine', 'heroin', 'marijuana', 'drugs', 'weed', 'shabu',

    // Violence
    'kill', 'murder', 'suicide', 'death', 'violence', 'shoot', 'stab',

    // Spam patterns
    'free money', 'click here', 'buy now', 'limited time',
    'urgent', 'act now', 'call now',

    // Filipino / Tagalog profanity
    'putangina',
    'tangina',
    'pota',
    'pakshet',
    'ulol',
    'bobo',
    'tanga',
    'gago',
    'lintik',
    'bwisit',
    'nakakabwisit',
    'hinayupak',
    'punyeta',
    'hayop',
    'leche',
    'kupal',
    'puke',
    'tite',

    // Bisaya / Cebuano profanity
    'yawa',
    'yati',
    'pisti',
    'piste',
    'bilat',
    'unai',
    'bogo',
    'buang',
    'kagwang',
    'atay',
  ];

  // Common bypassing patterns (l33t speak, spaces, etc.)
  static const Map<String, String> _normalizations = {
    '4': 'a',
    '3': 'e',
    '1': 'i',
    '0': 'o',
    '5': 's',
    '7': 't',
    '@': 'a',
    r'$': 's',
    '+': 't',
    '!': 'i',
  };

  /// Checks if a message contains inappropriate content
  static bool containsProfanity(String message) {
    if (message.trim().isEmpty) return false;

    final normalizedMessage = _normalizeText(message);

    for (final bannedWord in _bannedWords) {
      if (_containsWordPattern(normalizedMessage, bannedWord)) {
        debugPrint('🚫 Profanity detected: "$bannedWord" in message');
        return true;
      }
    }

    return false;
  }

  /// Filters a message and returns a cleaned version
  static FilterResult filterMessage(String message) {
    if (message.trim().isEmpty) {
      return FilterResult(
        originalMessage: message,
        filteredMessage: message,
        isFiltered: false,
        warnings: [],
      );
    }

    final normalizedMessage = _normalizeText(message);
    String filteredMessage = message;
    List<String> warnings = [];
    bool isFiltered = false;

    for (final bannedWord in _bannedWords) {
      if (_containsWordPattern(normalizedMessage, bannedWord)) {
        // Replace the banned word with asterisks
        final replacement = '*' * bannedWord.length;
        filteredMessage = _replaceWordInMessage(
          filteredMessage,
          bannedWord,
          replacement,
        );
        warnings.add('Inappropriate language detected and filtered');
        isFiltered = true;
      }
    }

    return FilterResult(
      originalMessage: message,
      filteredMessage: filteredMessage,
      isFiltered: isFiltered,
      warnings: warnings,
    );
  }

  /// Normalizes text by removing special characters and converting l33t speak
  static String _normalizeText(String text) {
    String normalized = text.toLowerCase();

    // Replace l33t speak and special characters
    _normalizations.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    // Remove extra spaces and special characters
    normalized = normalized.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized.trim();
  }

  /// Checks if a normalized message contains a banned word pattern
  static bool _containsWordPattern(
    String normalizedMessage,
    String bannedWord,
  ) {
    // Check for exact word matches (with word boundaries)
    final wordPattern = RegExp(r'\b' + RegExp.escape(bannedWord) + r'\b');
    if (wordPattern.hasMatch(normalizedMessage)) return true;

    // Check for common bypassing patterns (spaces within words)
    final spacedWord = bannedWord.split('').join(' ');
    if (normalizedMessage.contains(spacedWord)) return true;

    // Check for repeated characters (e.g., "fuuuck")
    final extendedPattern = _createExtendedPattern(bannedWord);
    if (RegExp(extendedPattern).hasMatch(normalizedMessage)) return true;

    return false;
  }

  /// Creates a pattern that matches words with repeated characters
  static String _createExtendedPattern(String word) {
    String pattern = r'\b';
    for (int i = 0; i < word.length; i++) {
      pattern += '${word[i]}+';
    }
    pattern += r'\b';
    return pattern;
  }

  /// Replaces banned words in the original message while preserving case
  static String _replaceWordInMessage(
    String message,
    String bannedWord,
    String replacement,
  ) {
    // Simple replacement - this could be made more sophisticated
    final pattern = RegExp(bannedWord, caseSensitive: false);
    return message.replaceAll(pattern, replacement);
  }
}

/// Result class for profanity filtering operations
class FilterResult {
  final String originalMessage;
  final String filteredMessage;
  final bool isFiltered;
  final List<String> warnings;

  const FilterResult({
    required this.originalMessage,
    required this.filteredMessage,
    required this.isFiltered,
    required this.warnings,
  });

  @override
  String toString() {
    return 'FilterResult(isFiltered: $isFiltered, warnings: ${warnings.length})';
  }
}
