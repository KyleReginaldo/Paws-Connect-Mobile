import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/widgets/text.dart';

/// A reusable loading state widget
class LoadingStateView extends StatelessWidget {
  final String? message;
  final bool useDogAnimation;
  final double? size;

  const LoadingStateView({
    super.key,
    this.message,
    this.useDogAnimation = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (useDogAnimation) {
      return Center(
        child: Lottie.asset(
          'assets/json/dog_loading.json',
          width: size ?? 100,
          height: size ?? 100,
          repeat: true,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            PawsText(message!),
          ],
        ],
      ),
    );
  }
}

/// A reusable empty state widget
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? imagePath;
  final Widget? action;
  final double? imageHeight;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.imagePath,
    this.action,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: imageHeight ?? 140,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            const SizedBox(height: 16),
            PawsText(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            PawsText(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// A reusable error state widget
class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData? icon;
  final IconData? retryIcon;

  const ErrorStateView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.icon,
    this.retryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            PawsText(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            PawsText(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(retryIcon ?? LucideIcons.refreshCcw),
                label: PawsText(retryLabel ?? 'Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
