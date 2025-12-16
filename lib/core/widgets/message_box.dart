import 'package:flutter/material.dart';
import 'package:paws_connect/core/widgets/text.dart';

/// A reusable message box widget for displaying messages with custom colors
class MessageBox extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final IconData? icon;
  final Widget? child;

  const MessageBox({
    super.key,
    this.message = '',
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.borderWidth,
    this.icon,
    this.child,
  });

  /// Creates an error message box
  factory MessageBox.error({
    required String message,
    IconData? icon,
    Widget? child,
  }) {
    return MessageBox(
      message: message,
      backgroundColor: Colors.red.withValues(alpha: 0.08),
      borderColor: Colors.redAccent.withValues(alpha: 0.4),
      textColor: Colors.red,
      icon: icon ?? Icons.error_outline,
      child: child,
    );
  }

  /// Creates a success message box
  factory MessageBox.success({
    required String message,
    IconData? icon,
    Widget? child,
  }) {
    return MessageBox(
      message: message,
      backgroundColor: Colors.green.withValues(alpha: 0.08),
      borderColor: Colors.greenAccent.withValues(alpha: 0.4),
      textColor: Colors.green,
      icon: icon ?? Icons.check_circle_outline,
      child: child,
    );
  }

  /// Creates a warning message box
  factory MessageBox.warning({
    required String message,
    IconData? icon,
    Widget? child,
  }) {
    return MessageBox(
      message: message,
      backgroundColor: Colors.orange.withValues(alpha: 0.08),
      borderColor: Colors.orangeAccent.withValues(alpha: 0.4),
      textColor: Colors.orange,
      icon: icon ?? Icons.warning_outlined,
      child: child,
    );
  }

  /// Creates an info message box
  factory MessageBox.info({
    required String message,
    IconData? icon,
    Widget? child,
  }) {
    return MessageBox(
      message: message,
      backgroundColor: Colors.blue.withValues(alpha: 0.08),
      borderColor: Colors.blueAccent.withValues(alpha: 0.4),
      textColor: Colors.blue,
      icon: icon ?? Icons.info_outline,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withValues(alpha: 0.08),
        border: Border.all(
          color: borderColor ?? Colors.grey.withValues(alpha: 0.4),
          width: borderWidth ?? 1,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: child ??
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: PawsText(
                  message,
                  color: textColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
    );
  }
}
