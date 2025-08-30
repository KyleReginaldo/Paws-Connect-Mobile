import 'package:flutter/material.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';

class PawsDivider extends StatelessWidget {
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final double spacing; // extra vertical spacing

  const PawsDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
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
}
