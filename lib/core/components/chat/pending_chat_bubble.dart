import 'package:flutter/material.dart';

import 'chat_bubble.dart';

class PendingChatBubble extends StatelessWidget {
  final String message;

  const PendingChatBubble(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      isMe: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Sending...',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
