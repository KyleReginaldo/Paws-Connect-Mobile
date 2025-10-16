import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws_connect/core/provider/common_provider.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/notification_model.dart' as notif_model;

@RoutePage(name: 'NotificationDetailRoute')
class NotificationDetailScreen extends StatefulWidget {
  final notif_model.Notification notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.notification.isViewed == false) {
        final userId = USER_ID;
        if (userId != null && userId.isNotEmpty) {
          try {
            CommonProvider().markNotificationAsViewed(widget.notification.id);
            setState(() => _marked = true);
          } catch (_) {}
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notif = widget.notification;
    final created = DateTime.tryParse(notif.createdAt);
    final relative = created != null ? timeago.format(created) : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Simple Header
            Text(
              "You’ve got an update!",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Here’s the latest info from Paws Connect.",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // 📄 Notification Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_marked || notif.isViewed == true)
                          Icon(
                            Icons.check_circle,
                            color: scheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (relative.isNotEmpty)
                      Text(
                        relative,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    const Divider(height: 24),
                    Text(
                      notif.content,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ✏️ Actions
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: notif.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  onPressed: () {
                    // Add share logic if needed
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
