import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart'
    as components;

/// Backward-compat wrapper for the new components NetworkImageView.
/// Keeps the same API so older imports continue to work.
class NetworkImageView extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const NetworkImageView(
    this.imageUrl, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return components.NetworkImageView(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
