import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/paws_theme.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool isSending;
  final File? previewImage;
  final VoidCallback? onRemovePreview;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    this.isSending = false,
    this.previewImage,
    this.onRemovePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (previewImage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    previewImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRemovePreview,
                  color: PawsColors.textPrimary,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(onPressed: onPickImage, icon: const Icon(Icons.image)),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isSending ? null : onSend,

                icon: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(LucideIcons.send, color: PawsColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
