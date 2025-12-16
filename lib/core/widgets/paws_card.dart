import 'package:flutter/material.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';

/// A reusable card widget with consistent styling
class PawsCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Widget? trailing;

  const PawsCard({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PawsText(
                    title!,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PawsColors.textPrimary,
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// A reusable section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PawsText(
            title,
            fontSize: fontSize ?? 18,
            fontWeight: fontWeight ?? FontWeight.w600,
            color: PawsColors.textPrimary,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
