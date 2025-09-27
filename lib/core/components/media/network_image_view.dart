import 'package:flutter/material.dart';

/// Reusable Network Image with loading, error, and fullscreen tap.
class NetworkImageView extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableTapToView;

  const NetworkImageView(
    this.imageUrl, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableTapToView = true,
  });

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, widget, loadingProgress) {
        if (loadingProgress == null) return widget;
        return SizedBox(
          height: height,
          width: width,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (!enableTapToView) return child;

    return GestureDetector(onTap: () => _openFullScreen(context), child: child);
  }
}
