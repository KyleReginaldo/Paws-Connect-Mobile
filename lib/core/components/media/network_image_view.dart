import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/extension/ext.dart';

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
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl.transformedUrl,
                  fit: BoxFit.contain,
                  cacheKey: '${imageUrl}_fullscreen',
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CachedNetworkImage(
      imageUrl: imageUrl.transformedUrl,
      height: height,
      width: width,
      cacheKey: imageUrl,
      fit: fit,
      progressIndicatorBuilder: (context, widget, loadingProgress) {
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
      errorWidget: (context, error, stackTrace) {
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
