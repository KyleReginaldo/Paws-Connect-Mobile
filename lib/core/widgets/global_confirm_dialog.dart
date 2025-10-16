import 'package:flutter/material.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';

import 'button.dart';
import 'text.dart';

/// Shows a simple, reusable confirmation dialog and returns `true` if the
/// user confirmed, `false` if they cancelled, or `null` if dismissed.
Future<bool?> showGlobalConfirmDialog(
  BuildContext context, {
  String title = 'Confirm',
  String? message,
  String confirmLabel = 'Yes',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: PawsText(title, fontSize: 18, fontWeight: FontWeight.w600),
        content: message != null ? PawsText(message) : null,
        actions: [
          PawsTextButton(
            padding: EdgeInsets.zero,
            label: cancelLabel,
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            foregroundColor: PawsColors.textSecondary,
          ),
          PawsTextButton(
            padding: EdgeInsets.zero,
            label: confirmLabel,
            onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
            foregroundColor: PawsColors.error,
          ),
        ],
      );
    },
  );
}
