# Notification Pagination Implementation

This document outlines the pagination feature added to the notification system in the Paws Connect Mobile app.

## Overview

The notification system now supports server-side pagination with the following query parameters:

- `page`: Page number (1-based indexing)
- `limit`: Number of notifications per page (default: 20, max: 100)

## Files Modified

### 1. NotificationProvider (`lib/features/notifications/provider/notification_provider.dart`)

**Changes:**

- Added pagination parameters (`page`, `limit`) to `fetchNotification()` method
- Added parameter validation (page >= 1, limit between 1-100)
- Enhanced error handling with try-catch blocks
- Improved API response parsing to handle different response formats
- Added configuration constants for default and maximum page sizes

**New API Call:**

```dart
GET /notifications/user/{userId}?page=1&limit=20
```

### 2. NotificationRepository (`lib/features/notifications/repository/notification_repository.dart`)

**New Properties:**

- `isLoadingMoreNotifications`: Tracks pagination loading state
- `hasMoreNotifications`: Indicates if more data is available
- `currentPage`: Current page number
- `pageLimit`: Configurable page size

**New Methods:**

- `loadMoreNotifications(userId)`: Load next page of notifications
- `refreshNotifications(userId)`: Reset pagination and reload from first page
- `resetPaginationState()`: Clear all data and reset pagination state
- `getPaginationInfo()`: Get pagination debugging information
- `isAnyLoading`: Getter for any loading state

**Enhanced Methods:**

- `fetchNotifications()`: Now supports refresh parameter
- `markAllViewed()`: Uses refreshNotifications for consistency

### 3. NotificationScreen (`lib/features/notifications/screens/notification_screen.dart`)

**New Features:**

- Added `ScrollController` for infinite scrolling
- Automatic loading when user scrolls near bottom (200px threshold)
- Loading indicator at bottom during pagination
- Updated RefreshIndicator to use `refreshNotifications()`
- Enhanced ListView to handle pagination loading states

## Usage Example

### Basic Implementation

```dart
// Initialize repository with custom page size
final notificationRepo = NotificationRepository(
  NotificationProvider(),
  pageLimit: 15, // Optional: default is 20
);

// Load initial data
notificationRepo.fetchNotifications(userId);

// Load more data (called automatically on scroll)
notificationRepo.loadMoreNotifications(userId);

// Refresh data (called on pull-to-refresh)
notificationRepo.refreshNotifications(userId);
```

### Infinite Scrolling Setup

```dart
ScrollController scrollController = ScrollController();

scrollController.addListener(() {
  if (scrollController.position.pixels >=
      scrollController.position.maxScrollExtent - 200) {
    if (repo.hasMoreNotifications && !repo.isLoadingMoreNotifications) {
      repo.loadMoreNotifications(userId);
    }
  }
});
```

### ListView with Pagination

```dart
ListView.builder(
  controller: scrollController,
  itemCount: repo.notifications.length +
      (repo.isLoadingMoreNotifications ? 1 : 0),
  itemBuilder: (context, index) {
    if (index < repo.notifications.length) {
      // Show notification
      return NotificationTile(notification: repo.notifications[index]);
    } else {
      // Show loading indicator
      return const Center(child: CircularProgressIndicator());
    }
  },
)
```

## State Management

### Loading States

- `isLoadingNotifications`: First page or refresh loading
- `isLoadingMoreNotifications`: Additional pages loading
- `isAnyLoading`: Any loading state (convenience getter)

### Pagination State

- `currentPage`: Current page number (1-based)
- `hasMoreNotifications`: Whether more data is available
- `pageLimit`: Number of items per page

### Error Handling

- Network errors are caught and returned as Result.error()
- Invalid parameters are validated before API calls
- Loading states are properly reset on errors

## API Requirements

The backend API should support the following query parameters:

- `page`: Page number (1-based)
- `limit`: Items per page

Expected response format:

```json
{
  "data": [
    {
      "id": 1,
      "title": "Notification Title",
      "content": "Notification content",
      "user": "user123",
      "created_at": "2024-01-01T00:00:00Z",
      "is_viewed": false
    }
  ]
}
```

## Configuration

### Default Settings

- Default page size: 20 notifications
- Maximum page size: 100 notifications
- Scroll threshold: 200px from bottom

### Customization

```dart
// Custom page size
NotificationRepository(provider, pageLimit: 30);

// Custom scroll threshold (in NotificationScreen)
if (scrollController.position.pixels >=
    scrollController.position.maxScrollExtent - 300) { // Custom threshold
  // Load more...
}
```

## Benefits

1. **Performance**: Only loads necessary data, reducing initial load time
2. **Memory Efficiency**: Prevents loading thousands of notifications at once
3. **User Experience**: Smooth infinite scrolling with loading indicators
4. **Scalability**: Handles large datasets efficiently
5. **Flexibility**: Configurable page sizes and thresholds

## Migration Notes

The existing `fetchNotifications(userId)` calls remain compatible. The new pagination parameters are optional with sensible defaults.

To enable pagination features:

1. Update API endpoints to support `page` and `limit` query parameters
2. Use `refreshNotifications()` instead of `fetchNotifications()` for pull-to-refresh
3. Implement scroll listener for infinite scrolling (see example above)

## Example Integration

See `lib/features/notifications/examples/pagination_example.dart` for a complete working example demonstrating all pagination features.
