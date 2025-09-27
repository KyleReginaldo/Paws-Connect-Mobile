import 'dart:io';

import 'package:flutter/material.dart';

class AttachmentPreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  final double size;
  const AttachmentPreview({
    super.key,
    required this.file,
    required this.onRemove,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        ),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
