import 'package:flutter/material.dart';

/// A reusable gradient overlay widget
class GradientOverlay extends StatelessWidget {
  final double? height;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<double>? stops;

  const GradientOverlay({
    super.key,
    this.height,
    this.colors,
    this.begin,
    this.end,
    this.stops,
  });

  /// Creates a bottom-to-top gradient (common for image headers)
  factory GradientOverlay.bottomToTop({double? height, double opacity = 0.4}) {
    return GradientOverlay(
      height: height,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: opacity),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Creates a top-to-bottom gradient
  factory GradientOverlay.topToBottom({double? height, double opacity = 0.4}) {
    return GradientOverlay(
      height: height,
      colors: [
        Colors.black.withValues(alpha: opacity),
        Colors.transparent,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              colors ??
              [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
          begin: begin ?? Alignment.topCenter,
          end: end ?? Alignment.bottomCenter,
          stops: stops,
        ),
      ),
    );
  }
}
