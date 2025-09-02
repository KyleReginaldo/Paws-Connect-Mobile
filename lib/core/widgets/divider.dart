import 'package:flutter/material.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';

class PawsDivider extends StatelessWidget {
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final double spacing; // extra vertical spacing
  final String? text;
  final TextStyle? textStyle;
  final double horizontalPadding;

  const PawsDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    this.spacing = 0,
    this.text,
    this.textStyle,
    this.horizontalPadding = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing),
        child: Divider(
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
          color: color ?? PawsColors.border,
          height: thickness, // keeps it compact
        ),
      );
    }

    final effectiveTextStyle =
        textStyle ?? Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: thickness,
              color: color ?? PawsColors.border,
              height: thickness,
              endIndent: horizontalPadding,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              text!,
              style: effectiveTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Divider(
              thickness: thickness,
              color: color ?? PawsColors.border,
              height: thickness,
              indent: horizontalPadding,
            ),
          ),
        ],
      ),
    );
  }
}
