import 'package:flutter/material.dart';

class IconCircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? color;
  final Color? iconColor;

  const IconCircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.primary;
    final ic = iconColor ?? Colors.white;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: ic, size: size * 0.4),
      ),
    );
  }
}
