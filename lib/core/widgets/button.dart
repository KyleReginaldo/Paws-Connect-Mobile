// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

/// 🐾 Elevated Button
class PawsElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final double? size;
  // Editable design props
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double borderRadius;

  const PawsElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: size ?? 18, color: foregroundColor),
        if (icon != null) const SizedBox(width: 8),
        Text(
          label,
          style:
              textStyle ??
              TextStyle(fontWeight: FontWeight.w600, fontSize: size ?? 15),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// 🐾 Outlined Button
class PawsOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  // Editable design props
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double borderRadius;

  const PawsOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: 18, color: foregroundColor ?? primary),
        if (icon != null) const SizedBox(width: 8),
        Text(
          label,
          style:
              textStyle ??
              TextStyle(
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? primary,
              ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(color: borderColor ?? primary),
        ),
        child: child,
      ),
    );
  }
}

/// 🐾 Text Button
class PawsTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  // Editable design props
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double borderRadius;

  const PawsTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.foregroundColor,
    this.padding,
    this.textStyle,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: 18, color: foregroundColor ?? primary),
        if (icon != null) const SizedBox(width: 8),
        Text(
          label,
          style:
              textStyle ??
              TextStyle(
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? primary,
              ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }
}
