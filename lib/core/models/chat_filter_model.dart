class ChatFilter {
  final String id;
  final String word;
  final String category;
  final bool isActive;
  final int severity;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatFilter({
    required this.id,
    required this.word,
    required this.category,
    required this.isActive,
    required this.severity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatFilter.fromJson(Map<String, dynamic> json) {
    return ChatFilter(
      id: json['id'] as String,
      word: json['word'] as String,
      category: json['category'] as String,
      isActive: json['is_active'] as bool,
      severity: json['severity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'category': category,
      'is_active': isActive,
      'severity': severity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChatFilter(id: $id, word: $word, category: $category, isActive: $isActive, severity: $severity)';
  }
}

class ChatFilterResponse {
  final String message;
  final List<ChatFilter> data;

  ChatFilterResponse({required this.message, required this.data});

  factory ChatFilterResponse.fromJson(Map<String, dynamic> json) {
    return ChatFilterResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => ChatFilter.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
