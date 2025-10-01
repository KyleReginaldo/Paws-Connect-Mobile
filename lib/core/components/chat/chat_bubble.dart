import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Widget child;
  final bool isMe;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const ChatBubble({
    super.key,
    required this.child,
    required this.isMe,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        color ??
        (isMe ? Theme.of(context).colorScheme.primary : Colors.grey[200]!);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: child,
      ),
    );
  }
}
