import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/paws_theme.dart';

class MentionParser {
  static const String _mentionPattern = r'@(\w+)';

  /// Parses a message text and returns a TextSpan with formatted mentions
  static TextSpan parseMessage({
    required String text,
    required TextStyle baseStyle,
    Color? mentionColor,
    Function(String username)? onMentionTapped,
  }) {
    final List<TextSpan> spans = [];
    final RegExp mentionRegex = RegExp(_mentionPattern);

    int lastIndex = 0;

    for (final match in mentionRegex.allMatches(text)) {
      // Add text before mention
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add formatted mention
      final username = match.group(1)!;
      spans.add(
        TextSpan(
          text: '@$username',
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: mentionColor ?? baseStyle.color ?? PawsColors.primary,
          ),
          recognizer: onMentionTapped != null
              ? (TapGestureRecognizer()
                  ..onTap = () => onMentionTapped(username))
              : null,
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return TextSpan(children: spans);
  }

  /// Extracts all mentioned usernames from a text
  static List<String> extractMentions(String text) {
    final RegExp mentionRegex = RegExp(_mentionPattern);
    return mentionRegex
        .allMatches(text)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Checks if a text contains any mentions
  static bool hasMentions(String text) {
    return RegExp(_mentionPattern).hasMatch(text);
  }

  /// Removes all mentions from text (for notifications, etc.)
  static String removeMentions(String text) {
    return text.replaceAll(RegExp(_mentionPattern), '');
  }

  /// Formats mentions for storage (can be used to convert to different format)
  static String formatForStorage(String text) {
    // For now, just return as-is, but this could be used to convert
    // @username to a different format like [mention:userId] if needed
    return text;
  }
}
