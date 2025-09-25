import 'package:flutter/material.dart';

/// A small helper widget to display a network image with placeholder,
/// error handling and tappable fullscreen viewer.
class NetworkImageView extends StatefulWidget {
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
  State<NetworkImageView> createState() => _NetworkImageViewState();
}

class _NetworkImageViewState extends State<NetworkImageView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.black),
            backgroundColor: Colors.black,
            body: Center(
              child: InteractiveViewer(
                child: Image.network(widget.imageUrl, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Image.network(
        widget.imageUrl,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      ),
    );
  }
}
