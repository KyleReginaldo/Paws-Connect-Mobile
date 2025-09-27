import 'package:flutter/material.dart';

class MessageTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  const MessageTextField({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      onSubmitted: onSubmitted,
      decoration: const InputDecoration(
        hintText: 'Type a message...',
        border: OutlineInputBorder(),
      ),
    );
  }
}
