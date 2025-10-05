// Example usage of the paginated notification system
// This file demonstrates how to use the enhanced notification repository

import 'package:flutter/material.dart';
import 'package:paws_connect/features/notifications/provider/notification_provider.dart';
import 'package:paws_connect/features/notifications/repository/notification_repository.dart';

class NotificationPaginationExample extends StatefulWidget {
  const NotificationPaginationExample({super.key});

  @override
  State<NotificationPaginationExample> createState() =>
      _NotificationPaginationExampleState();
}

class _NotificationPaginationExampleState
    extends State<NotificationPaginationExample> {
  late NotificationRepository notificationRepo;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    // Initialize with custom page size (optional)
    notificationRepo = NotificationRepository(
      NotificationProvider(),
      pageLimit: 15, // Custom page size
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    // Load initial notifications
    _loadInitialData();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    const userId = "user123"; // Replace with actual user ID
    notificationRepo.fetchNotifications(userId);
  }

  void _onScroll() {
    const userId = "user123"; // Replace with actual user ID

    // Load more when reaching near the bottom
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (notificationRepo.hasMoreNotifications &&
          !notificationRepo.isLoadingMoreNotifications) {
        notificationRepo.loadMoreNotifications(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications with Pagination'),
        actions: [
          // Show pagination info
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final info = notificationRepo.getPaginationInfo();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Page: ${info['currentPage']}, '
                    'Total: ${info['totalNotifications']}, '
                    'Unread: ${info['unreadCount']}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: notificationRepo,
        builder: (context, child) {
          // Show initial loading
          if (notificationRepo.isLoadingNotifications &&
              notificationRepo.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error
          if (notificationRepo.errorMessage.isNotEmpty &&
              notificationRepo.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${notificationRepo.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        notificationRepo.refreshNotifications("user123"),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (notificationRepo.notifications.isEmpty) {
            return const Center(child: Text('No notifications found'));
          }

          // Show notifications with pagination
          return RefreshIndicator(
            onRefresh: () async {
              notificationRepo.refreshNotifications("user123");
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount:
                  notificationRepo.notifications.length +
                  (notificationRepo.isLoadingMoreNotifications ? 1 : 0),
              itemBuilder: (context, index) {
                // Show notification items
                if (index < notificationRepo.notifications.length) {
                  final notification = notificationRepo.notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.content),
                    trailing: notification.isViewed == false
                        ? const Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () {
                      // Mark as viewed when tapped
                      if (notification.isViewed == false) {
                        notificationRepo.markSingleViewed(notification.id);
                      }
                    },
                  );
                }
                // Show loading indicator at bottom
                else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mark all as viewed
          notificationRepo.markAllViewed("user123");
        },
        child: const Icon(Icons.done_all),
      ),
    );
  }
}

/*
Key Features Implemented:

1. **Pagination Parameters**:
   - `page`: 1-based page number
   - `limit`: Number of items per page (default: 20, max: 100)

2. **Repository Methods**:
   - `fetchNotifications(userId, {refresh})`: Load first page or refresh
   - `loadMoreNotifications(userId)`: Load next page
   - `refreshNotifications(userId)`: Reset and reload from first page
   - `resetPaginationState()`: Clear all data and reset pagination

3. **State Management**:
   - `isLoadingNotifications`: Loading first page or refreshing
   - `isLoadingMoreNotifications`: Loading additional pages
   - `hasMoreNotifications`: Whether more data is available
   - `currentPage`: Current page number
   - `notifications`: All loaded notifications

4. **Infinite Scrolling**:
   - Automatically loads more data when user scrolls near bottom
   - Shows loading indicator during pagination
   - Handles errors gracefully

5. **Pull-to-Refresh**:
   - Resets pagination and loads fresh data
   - Maintains user experience consistency

Usage Notes:
- The page parameter is 1-based (starts from 1, not 0)
- The API should return data in the format: { "data": [...] }
- Configure page size via NotificationRepository constructor
- Use refreshNotifications() for pull-to-refresh functionality
- Use loadMoreNotifications() for infinite scrolling
*/
