import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/repository/common_repository.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/state_views.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/notifications/provider/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;
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

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  String? _cachedUserId;

  // Cache scroll threshold to avoid repeated calculations
  static const double _scrollThreshold = 200.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _cachedUserId = USER_ID;

    // Fetch on first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
        context.read<NotificationRepository>().fetchNotifications(
          _cachedUserId!,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_cachedUserId == null || _cachedUserId!.isEmpty) return;

    final position = _scrollController.position;
    final repo = context.read<NotificationRepository>();

    // Optimized scroll detection with cached values
    if (position.pixels >= position.maxScrollExtent - _scrollThreshold) {
      if (repo.hasMoreNotifications && !repo.isAnyLoading) {
        repo.loadMoreNotifications(_cachedUserId!);
      }
    }
  }

  Future<void> _removeNotifications({required List<int> ids}) async {
    if (_cachedUserId == null || _cachedUserId!.isEmpty || ids.isEmpty) return;

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Removing notifications...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final result = await NotificationProvider().removeNotifications(
        ids: ids,
        userId: _cachedUserId!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result.isSuccess) {
        // Clear selection and refresh
        final repo = context.read<NotificationRepository>();
        repo.clearNotificationIds();
        repo.refreshNotifications(_cachedUserId!);

        // Refresh global badge count as removed items may affect unread total
        try {
          sl<CommonRepository>().getNotificationCount(_cachedUserId!);
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notification(s) removed'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showErrorSnackBar(result.error);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorSnackBar('Failed to remove notifications: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            final repo = context.read<NotificationRepository>();
            final selectedIds = List<int>.from(repo.notificationIds);
            if (selectedIds.isNotEmpty) {
              _removeNotifications(ids: selectedIds);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<NotificationRepository>(
          builder: (context, repo, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PawsText(
                  'Notifications',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationRepository>(
            builder: (context, repo, _) {
              final notificationIds = repo.notificationIds;
              final notifications = repo.notifications;

              if (notificationIds.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Remove selected',
                        icon: const Icon(LucideIcons.trash, size: 16),
                        onPressed: () =>
                            _removeNotifications(ids: notificationIds),
                      ),
                      Checkbox(
                        value:
                            notificationIds.length == notifications.length &&
                            notifications.isNotEmpty,
                        onChanged: (value) {
                          if (value == true) {
                            repo.selectAllNotificationIds();
                          } else {
                            repo.clearNotificationIds();
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _cachedUserId == null || _cachedUserId!.isEmpty
          ? _SignedOutView(
              onRetry: () {
                _cachedUserId = USER_ID;
                if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
                  context.read<NotificationRepository>().refreshNotifications(
                    _cachedUserId!,
                  );
                }
              },
            )
          : const _NotificationListView(),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

// Optimized notification list view widget
class _NotificationListView extends StatelessWidget {
  const _NotificationListView();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationRepository>(
      builder: (context, repo, _) {
        if (repo.isLoadingNotifications && repo.notifications.isEmpty) {
          return const _LoadingView();
        }

        if (repo.errorMessage.isNotEmpty) {
          return _ErrorView(
            message: repo.errorMessage,
            onRetry: () {
              final userId = USER_ID;
              if (userId != null && userId.isNotEmpty) {
                repo.refreshNotifications(userId);
              }
            },
          );
        }

        if (repo.notifications.isEmpty) {
          return const _EmptyView();
        }

        return RefreshTrigger(
          onRefresh: () async {
            final userId = USER_ID;
            if (userId != null && userId.isNotEmpty) {
              return repo.refreshNotifications(userId);
            }
          },
          child: _OptimizedNotificationList(notifications: repo.notifications),
        );
      },
    );
  }
}

// Optimized list with better performance
class _OptimizedNotificationList extends StatelessWidget {
  final List<notif_model.Notification> notifications;

  const _OptimizedNotificationList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationRepository>(
      builder: (context, repo, _) {
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount:
              notifications.length + (repo.isLoadingMoreNotifications ? 1 : 0),
          itemBuilder: (context, index) {
            // Show notifications
            if (index < notifications.length) {
              final notif = notifications[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < notifications.length - 1 ? 12 : 0,
                ),
                child: _NotificationCard(
                  key: ValueKey(notif.id),
                  notification: notif,
                  onTap: () => _handleNotificationTap(context, notif),
                  onLongPress: () =>
                      _handleNotificationLongPress(context, notif),
                ),
              );
            }
            // Show loading indicator at the bottom when loading more
            else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    notif_model.Notification notification,
  ) {
    // Mark as read optimistically
    context.read<NotificationRepository>().markSingleViewed(notification.id);

    // Navigate to detail
    context.router.push(NotificationDetailRoute(notification: notification));
  }

  void _handleNotificationLongPress(
    BuildContext context,
    notif_model.Notification notification,
  ) {
    final repo = context.read<NotificationRepository>();
    if (repo.notificationIds.contains(notification.id)) {
      repo.removeNotificationId(notification.id);
    } else {
      repo.addNotificationId(notification.id);
    }
  }
}

// Optimized list with better performance

// Optimized notification card with better performance
class _NotificationCard extends StatelessWidget {
  final notif_model.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = notification.isViewed == false;
    final created = DateTime.tryParse(notification.createdAt);
    final relative = created != null
        ? timeago.format(created, locale: 'en_short')
        : '';

    return Consumer<NotificationRepository>(
      builder: (context, repo, _) {
        final isSelected = repo.notificationIds.contains(notification.id);
        final hasSelection = repo.notificationIds.isNotEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _getCardColor(scheme, unread, isSelected),
              border: Border.all(
                color: _getBorderColor(scheme, unread, isSelected),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasSelection) ...[
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: isSelected,
                    shape: const CircleBorder(),
                    onChanged: (v) {
                      if (v == true) {
                        repo.addNotificationId(notification.id);
                      } else {
                        repo.removeNotificationId(notification.id);
                      }
                    },
                  ),
                ],
                // Content
                Expanded(
                  child: _NotificationContent(
                    notification: notification,
                    unread: unread,
                    relative: relative,
                    theme: theme,
                    scheme: scheme,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCardColor(ColorScheme scheme, bool unread, bool isSelected) {
    if (isSelected) {
      return scheme.primary.withValues(alpha: 0.12);
    }
    if (unread) {
      return scheme.primary.withValues(alpha: 0.06);
    }
    return scheme.surface;
  }

  Color _getBorderColor(ColorScheme scheme, bool unread, bool isSelected) {
    if (isSelected) {
      return scheme.primary;
    }
    if (unread) {
      return scheme.primary.withValues(alpha: 0.35);
    }
    return scheme.outlineVariant.withValues(alpha: 0.25);
  }
}

// Extracted notification content for better performance
class _NotificationContent extends StatelessWidget {
  final notif_model.Notification notification;
  final bool unread;
  final String relative;
  final ThemeData theme;
  final ColorScheme scheme;

  const _NotificationContent({
    required this.notification,
    required this.unread,
    required this.relative,
    required this.theme,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                notification.title.trim(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (relative.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                relative,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notification.content.trim(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const LoadingStateView();
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: "You're all caught up",
      message:
          'No notifications yet. We\'ll bark or meow when there\'s something new.',
      imagePath: 'assets/images/empty_donation.png',
      imageHeight: 140,
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
            Image.asset(
              'assets/images/no_notif.png',
              height: 140,
              fit: BoxFit.contain,
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
          ],
        ),
      ),
    );
  }
}
