# Event Join/Leave Functionality Implementation

## Overview

This document outlines the implementation of join and leave event functionality for the Paws Connect Mobile app, including API integration, state management, and UI components.

## API Endpoints

### Join Event

- **Method**: POST
- **URL**: `{{base_url}}/events/{eventId}`
- **Body**:
  ```json
  {
    "user_id": "08a7f0ab-8d48-4776-af40-df7150517fa5"
  }
  ```

### Leave Event

- **Method**: PATCH
- **URL**: `{{base_url}}/events/{eventId}`
- **Body**:
  ```json
  {
    "user_id": "08a7f0ab-8d48-4776-af40-df7150517fa5"
  }
  ```

## Implementation Details

### 1. EventProvider Updates

**File**: `lib/features/events/provider/event_provider.dart`

Added two new methods:

- `joinEvent()`: Handles POST request to join an event
- `leaveEvent()`: Handles PATCH request to leave an event

Both methods include:

- Proper error handling with Result pattern
- JSON body construction with user_id
- Response status code validation
- User-friendly error messages

### 2. Event Model Enhancement

**File**: `lib/features/events/models/event_model.dart`

Enhanced the Event model with:

- `members` field: List of user IDs who joined the event
- `isUserMember(String userId)`: Method to check if a user is a member
- `memberCount` getter: Returns the number of event members

### 3. EventRepository Integration

**File**: `lib/features/events/repository/event_repository.dart`

Added repository methods for better state management:

- `joinEvent()`: Calls provider and refreshes event data
- `leaveEvent()`: Calls provider and refreshes event data
- Automatic state updates after successful operations

### 4. UI Implementation

**File**: `lib/features/events/screens/event_detail_screen.dart`

Added comprehensive UI components:

#### Event Members Section

- Displays member count with icon
- Shows current membership status
- Clean card-style design with proper spacing

#### Join/Leave Button

- Dynamic button that changes based on membership status
- **Join Button**: Green primary color with "Join Event" text and user-plus icon
- **Leave Button**: Red color with "Leave Event" text and user-minus icon
- Full-width responsive design

#### User State Handling

- Shows join/leave button for authenticated users
- Displays "Sign in to join this event" message for unauthenticated users
- Proper loading states with EasyLoading integration

#### Visual Design

- Consistent with app theme using PawsColors
- Proper spacing and border radius
- Icon integration with LucideIcons
- Responsive layout that works on all screen sizes

## User Experience Flow

### For Authenticated Users

1. **Viewing Event**: User sees member count and current membership status
2. **Joining Event**:

   - User taps "Join Event" button
   - Loading indicator shows "Joining event..."
   - Success/error toast message appears
   - UI updates to show "Leave Event" button
   - Member count increases

3. **Leaving Event**:
   - User taps "Leave Event" button
   - Loading indicator shows "Leaving event..."
   - Success/error toast message appears
   - UI updates to show "Join Event" button
   - Member count decreases

### For Unauthenticated Users

- Clear message indicating sign-in is required
- No interactive buttons displayed
- Member count still visible for transparency

## Error Handling

### Network Errors

- Timeout handling
- Connection failure messages
- Server error responses with proper status codes

### User Feedback

- Loading states during API calls
- Success messages for completed actions
- Clear error messages for failed operations
- Toast notifications positioned at the top

### State Consistency

- Automatic refresh of event data after successful operations
- Consistent UI state with server data
- Graceful fallbacks for edge cases

## Security Considerations

### Authentication

- USER_ID validation before API calls
- Proper user session management
- Sign-in requirement enforcement

### API Security

- JSON body validation
- Proper HTTP methods for different operations
- Error message sanitization

## Performance Optimizations

### State Management

- Efficient state updates using ChangeNotifier
- Minimal rebuilds with targeted Consumer widgets
- Local state optimization before server sync

### Network Efficiency

- Single API call per operation
- Automatic data refresh only when needed
- Proper loading state management

## Future Enhancements

### Suggested Improvements

1. **Member List Display**: Show actual member profiles
2. **Real-time Updates**: WebSocket integration for live member count
3. **Batch Operations**: Join/leave multiple events
4. **Member Permissions**: Different member roles and permissions
5. **Event Capacity**: Maximum member limits and waiting lists

### Analytics Integration

1. **User Engagement**: Track join/leave patterns
2. **Popular Events**: Identify high-engagement events
3. **User Journey**: Monitor user interaction flows

## Testing Recommendations

### Unit Tests

- EventProvider join/leave methods
- Event model member validation
- Repository state management

### Integration Tests

- API endpoint validation
- Error handling scenarios
- State consistency across operations

### UI Tests

- Button state changes
- Loading indicator display
- Toast message validation
- Authentication flow testing

## Conclusion

The join/leave event functionality provides a complete user experience with:

- ✅ Robust API integration with proper error handling
- ✅ Clean, intuitive UI design
- ✅ Efficient state management
- ✅ Comprehensive user feedback
- ✅ Security and authentication considerations
- ✅ Performance optimizations

This implementation follows Flutter best practices and maintains consistency with the existing codebase architecture.
