import 'package:flutter/material.dart';

class PawsText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextDecoration? decoration;

  const PawsText(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,

      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style:
          style ??
          TextStyle(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontWeight.normal,
            decoration: decoration,
          ),
    );
  }
}
