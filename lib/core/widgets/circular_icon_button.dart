import 'package:flutter/material.dart';

/// A reusable circular icon button with customizable background
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final double? backgroundOpacity;
  final EdgeInsets? padding;
  final String? tooltip;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.backgroundOpacity,
    this.padding,
    this.tooltip,
  });

  /// Creates a semi-transparent black background button (common for overlays)
  factory CircularIconButton.overlay({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    double? iconSize,
    String? tooltip,
  }) {
    return CircularIconButton(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: Colors.black,
      backgroundOpacity: 0.5,
      iconColor: iconColor,
      iconSize: iconSize,
      tooltip: tooltip,
    );
  }

  /// Creates a colored background button
  factory CircularIconButton.colored({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    Color iconColor = Colors.white,
    double? iconSize,
    double opacity = 0.9,
    String? tooltip,
  }) {
    return CircularIconButton(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: color,
      backgroundOpacity: opacity,
      iconColor: iconColor,
      iconSize: iconSize,
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.black;
    final opacity = backgroundOpacity ?? 0.5;

    final button = Container(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.white),
        iconSize: iconSize,
        onPressed: onPressed,
        padding: padding,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
