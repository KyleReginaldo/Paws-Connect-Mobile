// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final Widget child;
  final bool isMe;
  final Color? color;
  final String? messageWarning;
  final EdgeInsetsGeometry padding;

  const ChatBubble({
    super.key,
    required this.child,
    required this.isMe,
    this.color,
    this.messageWarning,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isWarningVisible = false;

  @override
  Widget build(BuildContext context) {
    final bg =
        widget.color ??
        (widget.isMe
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[200]!);

    // If there's a warning and content is not visible, show warning indicator
    if (widget.messageWarning != null && !_isWarningVisible) {
      return Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isWarningVisible = true;
            });
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.7,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              border: Border.all(color: Colors.red.shade400, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(widget.isMe ? 16 : 0),
                bottomRight: Radius.circular(widget.isMe ? 0 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.messageWarning!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to view message',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show normal message (either no warning or warning is visible)
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.messageWarning != null
              ? widget.isMe
                    ? Colors.red.shade200
                    : Colors.red.shade50
              : bg,
          border: widget.messageWarning != null
              ? Border.all(color: Colors.red.shade400, width: 2)
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(widget.isMe ? 16 : 0),
            bottomRight: Radius.circular(widget.isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show warning indicator if there's a warning and message is visible
            if (widget.messageWarning != null && _isWarningVisible) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.messageWarning!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            widget.child,
          ],
        ),
      ),
    );
  }
}
