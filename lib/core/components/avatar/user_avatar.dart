import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 32,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey.shade200,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.transparent,
                width: borderWidth,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? NetworkImageView(
              imageUrl!,
              height: size,
              width: size,
              fit: BoxFit.cover,
              enableTapToView: false,
            )
          : Center(
              child: Text(
                (initials ?? '?').substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                  color: Colors.black87,
                ),
              ),
            ),
    );
    return GestureDetector(onTap: onTap, child: avatar);
  }
}
