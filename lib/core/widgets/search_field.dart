import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PawsSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autoFocus;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double borderRadius;
  final bool readOnly;
  final VoidCallback? onTap;

  const PawsSearchBar({
    super.key,
    this.controller,
    this.hintText = "Search...",
    this.onChanged,
    this.onClear,
    this.autoFocus = false,
    this.backgroundColor,
    this.iconColor,
    this.textStyle,
    this.hintStyle,
    this.borderRadius = 12,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchBar(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onTap: onTap,
      autoFocus: autoFocus,
      elevation: WidgetStatePropertyAll(0),
      textStyle: WidgetStateProperty.all(
        textStyle ??
            TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
      ),
      hintStyle: WidgetStateProperty.all(
        hintStyle ?? TextStyle(color: theme.hintColor, fontSize: 16),
      ),
      backgroundColor: WidgetStateProperty.all(
        backgroundColor ?? theme.colorScheme.surface,
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      leading: Icon(
        LucideIcons.search,
        color: iconColor ?? theme.iconTheme.color,
      ),
      trailing: [
        if (controller != null && controller!.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.close, color: iconColor ?? theme.iconTheme.color),
            onPressed: () {
              controller?.clear();
              onClear?.call();
            },
          ),
      ],
    );
  }
}
