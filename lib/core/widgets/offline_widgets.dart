import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../features/internet/internet.dart';
import 'text.dart';

/// A small banner that shows when the app is offline.
class NoInternetBanner extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  const NoInternetBanner({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<InternetProvider>().isConnected;
    if (isConnected) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff, color: Colors.redAccent),
          SizedBox(width: 8),
          PawsText('No internet connection', color: Colors.redAccent),
        ],
      ),
    );
  }
}

/// Wraps a child and disables interactions when offline.
///
/// By default the child will be dimmed and wrapped with [AbsorbPointer]
/// when the app is offline. Optionally the banner can be shown above the child
/// by setting [showBanner] to true.
class DisableWhenOffline extends StatelessWidget {
  final Widget child;
  final bool showBanner;
  final double offlineOpacity;

  const DisableWhenOffline({
    super.key,
    required this.child,
    this.showBanner = true,
    this.offlineOpacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<InternetProvider>().isConnected;

    if (isConnected) return child;

    final disabled = AbsorbPointer(
      absorbing: true,
      child: Opacity(opacity: offlineOpacity, child: child),
    );

    if (!showBanner) return disabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [NoInternetBanner(), SizedBox(height: 8), disabled],
    );
  }
}
