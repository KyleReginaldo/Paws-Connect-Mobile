import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PawsSearchBar extends StatefulWidget {
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
  final FocusNode? focusNode;

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
    this.focusNode,
  });

  @override
  State<PawsSearchBar> createState() => _PawsSearchBarState();
}

class _PawsSearchBarState extends State<PawsSearchBar> {
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant PawsSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
      _hasText = widget.controller?.text.isNotEmpty ?? false;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _unfocus() => _focusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final searchBar = SearchBar(
      focusNode: _focusNode,
      controller: widget.controller,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      autoFocus: widget.autoFocus,

      constraints: const BoxConstraints(minHeight: 45, maxHeight: 54),
      elevation: WidgetStatePropertyAll(0),
      textStyle: WidgetStateProperty.all(
        widget.textStyle ??
            TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
      ),
      hintStyle: WidgetStateProperty.all(
        widget.hintStyle ?? TextStyle(color: theme.hintColor, fontSize: 16),
      ),
      backgroundColor: WidgetStateProperty.all(
        widget.backgroundColor ?? theme.colorScheme.surface,
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      leading: Icon(
        LucideIcons.search,
        color: widget.iconColor ?? theme.iconTheme.color,
      ),
      trailing: [
        if (_hasText)
          IconButton(
            icon: Icon(
              Icons.close,
              color: widget.iconColor ?? theme.iconTheme.color,
            ),
            onPressed: () {
              widget.controller?.clear();
              _unfocus();
              widget.onClear?.call();
            },
          ),
      ],
    );

    return searchBar;
  }
}
