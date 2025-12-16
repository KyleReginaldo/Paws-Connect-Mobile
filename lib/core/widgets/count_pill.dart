import 'package:flutter/material.dart';

/// A reusable count pill widget for displaying counts with icons
class CountPill extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final double? iconSize;
  final double? fontSize;
  final EdgeInsets? padding;
  final double? borderRadius;

  const CountPill({
    super.key,
    required this.icon,
    required this.count,
    required this.color,
    this.iconSize,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize ?? 12, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
