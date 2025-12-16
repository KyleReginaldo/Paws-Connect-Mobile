import 'package:flutter/material.dart';
import 'package:paws_connect/core/extension/ext.dart';

/// A reusable image carousel widget with page indicators
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double? height;
  final BoxFit fit;
  final bool showIndicators;

  const ImageCarousel({
    super.key,
    required this.images,
    this.height,
    this.fit = BoxFit.cover,
    this.showIndicators = true,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final scheme = Theme.of(context).colorScheme;
    final count = images.length;
    final height = widget.height ?? MediaQuery.of(context).size.width * 0.4;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            itemCount: count,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, i) {
              final url = images[i];
              return Image.network(
                url.transformedUrl,
                fit: widget.fit,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              );
            },
          ),
        ),
        if (widget.showIndicators && count > 1)
          PageIndicator(count: count, currentIndex: _currentIndex),
      ],
    );
  }
}

/// A reusable page indicator for carousels
class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final EdgeInsets? padding;
  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final double spacing;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.padding,
    this.activeWidth = 18,
    this.inactiveWidth = 6,
    this.height = 6,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: spacing),
            width: i == currentIndex ? activeWidth : inactiveWidth,
            height: height,
            decoration: BoxDecoration(
              color: i == currentIndex
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(height),
            ),
          );
        }),
      ),
    );
  }
}
