import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/notification_model.dart' as notif_model;
import '../repository/notification_repository.dart';

@RoutePage()
class NotificationScreen extends StatefulWidget implements AutoRouteWrapper {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<NotificationRepository>(),
      child: this,
    );
  }
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch on first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = USER_ID;
      if (userId != null && userId.isNotEmpty) {
        context.read<NotificationRepository>().fetchNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = USER_ID;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: userId == null || userId.isEmpty
          ? _SignedOutView(
              onRetry: () {
                // No direct sign-in navigation here; simply try to refetch if user becomes available
                if (USER_ID != null && USER_ID!.isNotEmpty) {
                  context.read<NotificationRepository>().fetchNotifications(
                    USER_ID!,
                  );
                }
              },
            )
          : Consumer<NotificationRepository>(
              builder: (context, repo, _) {
                if (repo.isLoadingNotifications && repo.notifications.isEmpty) {
                  return _LoadingView();
                }

                if (repo.errorMessage.isNotEmpty) {
                  return _ErrorView(
                    message: repo.errorMessage,
                    onRetry: () => repo.fetchNotifications(userId),
                  );
                }

                if (repo.notifications.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<NotificationRepository>()
                      .fetchNotifications(userId),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemBuilder: (context, index) {
                      final notif = repo.notifications[index];
                      return _NotificationCard(notification: notif);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: repo.notifications.length,
                  ),
                );
              },
            ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final notif_model.Notification notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 0.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.notifications, color: scheme.primary),
        ),
        title: Text(
          '${notification.title} ${timeago.format(DateTime.parse(notification.createdAt), locale: 'en_short')}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notification.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/json/paw_loader.json',
        width: 64,
        height: 64,
        repeat: true,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Using existing asset as a friendly illustration
            Image.asset(
              'assets/images/empty_donation.png',
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              "You're all caught up",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No notifications yet. We\'ll bark or meow when there\'s something new.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  final VoidCallback onRetry;
  const _SignedOutView({required this.onRetry});

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
              Icons.notifications_off_outlined,
              size: 72,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to view notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Once you\'re signed in, we\'ll keep you in the loop.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.login),
              label: const Text('I\'m signed in now'),
            ),
          ],
        ),
      ),
    );
  }
}
