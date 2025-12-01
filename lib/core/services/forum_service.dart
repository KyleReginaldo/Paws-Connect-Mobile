import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/forum/models/forum_model.dart';
import '../config/result.dart';
import '../utils/profanity_filter.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

/// Service class for handling all forum-related operations using Supabase SDK
///
/// This service provides direct Supabase SDK integration for:
/// - Forum management (create, fetch, update, delete)
/// - Forum chat operations (send, fetch, delete messages)
/// - Member management (add, remove, approve members)
/// - Reactions and interactions
/// - Real-time subscriptions
class ForumService {
  final SupabaseClient _client;

  ForumService() : _client = Supabase.instance.client;

  /// Fetches all forums for a specific user
  Future<Result<List<Forum>>> fetchUserForums(String userId) async {
    try {
      debugPrint('🔍 ForumService: Fetching forums for user: $userId');

      // Fetch forums where user is a member
      final response = await _client
          .from('forum')
          .select('''
            id,
            created_at,
            updated_at,
            forum_name,
            forum_image_url,
            private,
            created_by,
            forum_members!inner(
              id,
              member,
              invitation_status,
              mute,
              created_at,
              users(
                id,
                username,
                profile_image_link,
                is_active
              )
            )
          ''')
          .eq('forum_members.member', userId)
          .eq('forum_members.invitation_status', 'APPROVED')
          .order('updated_at', ascending: false);

      debugPrint('🔍 ForumService: Raw forums response: $response');

      final List<Forum> forums = [];
      for (final forumData in response) {
        // Get the latest chat for each forum
        final lastChatResponse = await _client
            .from('forum_chats')
            .select('''
            id,
            message,
            sent_at,
            sender,
            users(id, username, profile_image_link)
          ''')
            .eq('forum', forumData['id'])
            .order('sent_at', ascending: false)
            .limit(1);

        final forum = _mapToForum(forumData);
        if (lastChatResponse.isNotEmpty) {
          final lastChatData = lastChatResponse.first;
          final senderData = lastChatData['users'];
          final forumWithLastChat = forum.copyWith(
            lastChat: LastChat(
              id: lastChatData['id'],
              sentAt: DateTime.parse(lastChatData['sent_at']),
              sender: Users(
                id: senderData['id'],
                username: senderData['username'] ?? '',
                profileImageLink: senderData['profile_image_link'],
              ),
              message: lastChatData['message'] ?? '',
            ),
          );
          forums.add(forumWithLastChat);
        } else {
          forums.add(forum);
        }
      }

      debugPrint(
        '🔍 ForumService: Successfully fetched ${forums.length} forums',
      );
      return Result.success(forums);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error fetching forums: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch forums: $e');
    }
  }

  /// Fetches a specific forum by ID
  Future<Result<Forum>> fetchForumById(int forumId, String userId) async {
    try {
      debugPrint(
        '🔍 ForumService: Fetching forum by ID: $forumId for user: $userId',
      );

      final response = await _client
          .from('forum')
          .select('''
            id,
            created_at,
            updated_at,
            forum_name,
            forum_image_url,
            private,
            created_by,
            forum_members(
              id,
              member,
              invitation_status,
              mute,
              created_at,
              users(
                id,
                username,
                profile_image_link,
                is_active
              )
            )
          ''')
          .eq('id', forumId)
          .single();

      debugPrint('🔍 ForumService: Forum response: $response');

      final forum = _mapToForum(response);

      debugPrint(
        '🔍 ForumService: Successfully fetched forum: ${forum.forumName}',
      );
      return Result.success(forum);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error fetching forum by ID: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch forum: $e');
    }
  }

  /// Fetches forum chats with pagination
  Future<Result<ForumMessage>> fetchForumChats(
    int forumId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Fetching chats for forum: $forumId, page: $page, limit: $limit',
      );

      // Calculate offset for pagination
      final offset = (page - 1) * limit;

      final response = await _client
          .from('forum_chats')
          .select('''
            id,
            message,
            image_url,
            sent_at,
            sender,
            replied_to,
            reactions,
            viewers,
            message_warning,
            users(
              id,
              username,
              profile_image_link,
              is_active
            ),
            replied_to_chat:forum_chats!replied_to(
              id,
              message,
              sender,
              users(username, profile_image_link)
            ),
            mentions(
              id,
              user,
              users(id, username)
            )
          ''')
          .eq('forum', forumId)
          .order('sent_at', ascending: false)
          .range(offset, offset + limit - 1);

      debugPrint(
        '🔍 ForumService: Raw chats response count: ${response.length}',
      );

      // Get forum name
      final forumResponse = await _client
          .from('forum')
          .select('forum_name')
          .eq('id', forumId)
          .single();

      final forumName = forumResponse['forum_name'] ?? 'Unknown Forum';

      // Map response to ForumChat objects with error handling
      final List<ForumChat> chats = [];
      for (int i = 0; i < response.length; i++) {
        try {
          Map<String, dynamic> data = response[i];
          debugPrint('viewers ids: ${data['viewers']}');

          // Handle null or empty viewers
          if (data['viewers'] != null && (data['viewers'] as List).isNotEmpty) {
            final viewersData = await supabase
                .from('users')
                .select('id, username, profile_image_link')
                .inFilter('id', data['viewers'] as List);
            debugPrint('viewers data: $viewersData');
            data['viewers'] = viewersData;
          } else {
            // Set empty list for null viewers
            data['viewers'] = <Map<String, dynamic>>[];
          }

          chats.add(_mapToForumChat(data));
        } catch (e) {
          debugPrint('⚠️ ForumService: Error mapping chat at index $i: $e');
          debugPrint('⚠️ ForumService: Chat data: ${response[i]}');
          // Continue with the rest, don't let one bad record break everything
        }
      }

      // Reverse to get chronological order (oldest first for UI)
      chats.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      final forumMessage = ForumMessage(chats: chats, forumName: forumName);

      debugPrint('🔍 ForumService: Successfully fetched ${chats.length} chats');
      return Result.success(forumMessage);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error fetching forum chats: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch forum chats: $e');
    }
  }

  /// Sends a new chat message
  Future<Result<ForumChat>> sendChat({
    required String sender,
    String? message,
    required int forumId,
    XFile? imageFile,
    int? repliedTo,
    List<String>? mentions,
  }) async {
    try {
      // Validate that either message or image is provided
      if ((message == null || message.trim().isEmpty) && imageFile == null) {
        return Result.error('Either message text or image must be provided');
      }

      debugPrint('🔍 ForumService: Sending chat message to forum: $forumId');

      // Apply profanity filtering to message if present
      String? filteredMessage = message;
      String? messageWarning;

      if (message != null && message.trim().isNotEmpty) {
        final filterResult = ProfanityFilter.filterMessage(message);
        if (filterResult.isFiltered) {
          filteredMessage = filterResult.filteredMessage;
          messageWarning = 'This message contains filtered content';
          debugPrint('🚫 Message filtered: "$message" -> "$filteredMessage"');
        }
      }

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await SupabaseService.uploadImage(imageFile);
        debugPrint('🔍 ForumService: Uploaded image URL: $imageUrl');
      }

      // Insert the chat message
      final response = await _client
          .from('forum_chats')
          .insert({
            'forum': forumId,
            'sender': sender,
            'message':
                filteredMessage ?? '', // Use filtered message or empty string
            // 'sent_at': DateTime.now().toIso8601String(),
            if (imageUrl != null) 'image_url': imageUrl,
            if (repliedTo != null) 'replied_to': repliedTo,
            if (messageWarning != null) 'message_warning': messageWarning,
          })
          .select('''
            id,
            message,
            image_url,
            sent_at,
            sender,
            replied_to,
            reactions,
            viewers,
            message_warning,
            users(
              id,
              username,
              profile_image_link,
              is_active
            )
          ''')
          .single();

      // Insert mentions if any
      if (mentions != null && mentions.isNotEmpty) {
        final mentionInserts = mentions
            .map((userId) => {'forum_chat': response['id'], 'user': userId})
            .toList();

        await _client.from('mentions').insert(mentionInserts);
        debugPrint('🔍 ForumService: Inserted ${mentions.length} mentions');
      }

      // Update forum's updated_at timestamp
      await _client
          .from('forum')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', forumId);

      final forumChat = _mapToForumChat(response);

      debugPrint(
        '🔍 ForumService: Successfully sent chat message with ID: ${forumChat.id}',
      );

      // Send push notifications to other forum members (async, don't wait)
      _sendForumChatNotifications(
        forumId: forumId,
        senderId: sender,
        senderName: forumChat.users?.username ?? 'Unknown',
        message: filteredMessage ?? '',
        chatId: forumChat.id,
        imageUrl: imageUrl,
        icon: response['users']['profile_image_link'],
      ).catchError((error) {
        debugPrint('❌ Failed to send push notifications: $error');
      });

      return Result.success(forumChat);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error sending chat message: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to send message: $e');
    }
  }

  /// Adds or removes a reaction to a chat message
  Future<Result<void>> toggleReaction({
    required int chatId,
    required String userId,
    required String reaction,
    required bool isAdding,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: ${isAdding ? 'Adding' : 'Removing'} reaction "$reaction" to chat: $chatId',
      );

      // Get current reactions
      final currentResponse = await _client
          .from('forum_chats')
          .select('reactions')
          .eq('id', chatId)
          .single();

      List<dynamic> reactions = currentResponse['reactions'] ?? [];

      // Find existing reaction by this user with this emoji
      final existingReactionIndex = reactions.indexWhere(
        (r) => r['userId'] == userId && r['reaction'] == reaction,
      );

      // Find any existing reaction by this user (regardless of emoji)
      final anyExistingReactionIndex = reactions.indexWhere(
        (r) => r['userId'] == userId,
      );

      if (isAdding) {
        if (existingReactionIndex != -1) {
          // User is trying to add the same reaction they already have - do nothing
          debugPrint('🔍 ForumService: User already has this reaction');
        } else {
          // Remove any existing reaction by this user first (one reaction per user rule)
          if (anyExistingReactionIndex != -1) {
            final oldReaction = reactions[anyExistingReactionIndex]['reaction'];
            reactions.removeAt(anyExistingReactionIndex);
            debugPrint(
              '🔍 ForumService: Removed previous reaction "$oldReaction" for user',
            );
          }

          // Add new reaction
          reactions.add({
            'userId': userId,
            'reaction': reaction,
            'timestamp': DateTime.now().toIso8601String(),
          });
          debugPrint(
            '🔍 ForumService: Added new reaction "$reaction" for user',
          );
        }
      } else if (existingReactionIndex != -1) {
        // Remove existing reaction
        reactions.removeAt(existingReactionIndex);
        debugPrint('🔍 ForumService: Removed reaction "$reaction" for user');
      }

      // Update the chat with new reactions
      await _client
          .from('forum_chats')
          .update({'reactions': reactions})
          .eq('id', chatId);

      debugPrint('🔍 ForumService: Successfully toggled reaction');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error toggling reaction: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to toggle reaction: $e');
    }
  }

  /// Deletes a chat message
  Future<Result<void>> deleteChat({
    required int chatId,
    required String userId,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Deleting chat message: $chatId by user: $userId',
      );

      // First verify the user owns this message or is admin
      final chatResponse = await _client
          .from('forum_chats')
          .select('sender')
          .eq('id', chatId)
          .single();

      if (chatResponse['sender'] != userId) {
        return Result.error('You can only delete your own messages');
      }

      // Delete the message
      await _client.from('forum_chats').delete().eq('id', chatId);

      debugPrint('🔍 ForumService: Successfully deleted chat message');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error deleting chat message: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to delete message: $e');
    }
  }

  /// Creates a new forum
  Future<Result<Forum>> createForum({
    required String userId,
    required String forumName,
    required bool private,
    XFile? forumImageFile,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Creating forum: $forumName by user: $userId',
      );

      String? forumImageUrl;
      if (forumImageFile != null) {
        forumImageUrl = await SupabaseService.uploadImage(forumImageFile);
        debugPrint('🔍 ForumService: Uploaded forum image URL: $forumImageUrl');
      }

      // Create the forum
      final forumResponse = await _client
          .from('forum')
          .insert({
            'forum_name': forumName,
            'private': private,
            'created_by': userId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            if (forumImageUrl != null) 'forum_image_url': forumImageUrl,
          })
          .select()
          .single();

      // Add the creator as the first member with approved status
      await _client.from('forum_members').insert({
        'forum': forumResponse['id'],
        'member': userId,
        'invitation_status': 'APPROVED',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Fetch the complete forum data including members
      final result = await fetchForumById(forumResponse['id'], userId);

      debugPrint(
        '🔍 ForumService: Successfully created forum with ID: ${forumResponse['id']}',
      );
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error creating forum: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to create forum: $e');
    }
  }

  /// Fetches available users that can be added to a forum
  Future<Result<List<AvailableUser>>> fetchAvailableUsers(
    int forumId, {
    String? searchUsername,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Fetching available users for forum: $forumId',
      );

      // Get current forum members
      final memberResponse = await _client
          .from('forum_members')
          .select('member')
          .eq('forum', forumId);

      final currentMemberIds = memberResponse
          .map((m) => m['member'] as String)
          .toList();

      // Build query to get users not in the forum
      var query = _client
          .from('users')
          .select('id, username, profile_image_link')
          .not('id', 'in', '(${currentMemberIds.join(',')})')
          .eq('role', 3)
          .order('username');

      // Note: we'll apply optional search filtering client-side after the query

      final rawResponse = await query.limit(50); // Limit for performance

      // rawResponse is a List of maps; optionally filter client-side for search
      final List items = List.from(rawResponse as List);
      final List filtered =
          (searchUsername != null && searchUsername.isNotEmpty)
          ? items
                .where(
                  (u) => (u['username'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(searchUsername.toLowerCase()),
                )
                .toList()
          : items;

      final List<AvailableUser> users = filtered.map((userData) {
        return AvailableUser(
          id: userData['id'],
          username: userData['username'] ?? '',
          profileImageLink: userData['profile_image_link'],
        );
      }).toList();

      debugPrint('🔍 ForumService: Found ${users.length} available users');
      return Result.success(users);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error fetching available users: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch available users: $e');
    }
  }

  /// Fetches forum members
  Future<Result<List<AvailableUser>>> fetchForumMembers(int forumId) async {
    try {
      debugPrint('🔍 ForumService: Fetching members for forum: $forumId');

      final response = await _client
          .from('forum_members')
          .select('''
            member,
            invitation_status,
            users(
              id,
              username,
              profile_image_link
            )
          ''')
          .eq('forum', forumId)
          .eq('invitation_status', 'APPROVED');

      final List<AvailableUser> members = response.map((memberData) {
        final user = memberData['users'];
        return AvailableUser(
          id: user['id'],
          username: user['username'] ?? '',
          profileImageLink: user['profile_image_link'],
        );
      }).toList();

      debugPrint('🔍 ForumService: Found ${members.length} forum members');
      return Result.success(members);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error fetching forum members: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to fetch forum members: $e');
    }
  }

  /// Adds a user to a forum (sends invitation)
  Future<Result<void>> addMemberToForum({
    required int forumId,
    required String userId,
    required String inviterUserId,
  }) async {
    try {
      debugPrint('🔍 ForumService: Adding user $userId to forum: $forumId');

      await _client.from('forum_members').insert({
        'forum': forumId,
        'member': userId,
        'invitation_status': 'PENDING',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('🔍 ForumService: Successfully added member to forum');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error adding member to forum: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to add member to forum: $e');
    }
  }

  /// Approves or rejects a forum member invitation
  Future<Result<void>> updateMemberStatus({
    required int forumMemberId,
    required String status, // 'APPROVED' or 'REJECTED'
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Updating member status to: $status for member: $forumMemberId',
      );

      await _client
          .from('forum_members')
          .update({'invitation_status': status})
          .eq('id', forumMemberId);

      debugPrint('🔍 ForumService: Successfully updated member status');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error updating member status: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to update member status: $e');
    }
  }

  /// Toggles forum notification settings for a member
  Future<Result<void>> toggleNotificationSettings({
    required int forumMemberId,
    required bool mute,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Setting mute to: $mute for member: $forumMemberId',
      );

      await _client
          .from('forum_members')
          .update({'mute': mute})
          .eq('id', forumMemberId);

      debugPrint('🔍 ForumService: Successfully updated notification settings');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error updating notification settings: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to update notification settings: $e');
    }
  }

  /// Marks messages as viewed by a user in a forum
  Future<Result<void>> markMessagesAsViewed({
    required String userId,
    required int forumId,
  }) async {
    try {
      debugPrint(
        '🔍 ForumService: Marking messages as viewed for user: $userId in forum: $forumId',
      );

      // Get all unread messages in this forum
      final unreadMessages = await _client
          .from('forum_chats')
          .select('id, viewers')
          .eq('forum', forumId)
          .neq('sender', userId); // Don't mark own messages

      for (final message in unreadMessages) {
        List<String> viewers = List<String>.from(message['viewers'] ?? []);

        if (!viewers.contains(userId)) {
          viewers.add(userId);

          await _client
              .from('forum_chats')
              .update({'viewers': viewers})
              .eq('id', message['id']);
        }
      }

      debugPrint('🔍 ForumService: Successfully marked messages as viewed');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error marking messages as viewed: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to mark messages as viewed: $e');
    }
  }

  /// Gets the count of unread messages for a user across all forums they're a member of
  Future<Result<int>> getUnreadMessageCount(String userId) async {
    try {
      debugPrint(
        '🔍 ForumService: Getting unread message count for user: $userId',
      );

      // Get forum memberships
      final membershipResponse = await _client
          .from('forum_members')
          .select('forum')
          .eq('member', userId)
          .eq('invitation_status', 'APPROVED');

      if (membershipResponse.isEmpty) {
        return Result.success(0);
      }

      final forumIds = membershipResponse
          .map((m) => m['forum'] as int)
          .toList();

      // Get unread messages
      final unreadResponse = await _client
          .from('forum_chats')
          .select('id, viewers, sender')
          .inFilter('forum', forumIds)
          .neq('sender', userId);

      int unreadCount = 0;
      for (final chat in unreadResponse) {
        final viewers = chat['viewers'] as List?;
        if (viewers == null || !viewers.contains(userId)) {
          unreadCount++;
        }
      }

      debugPrint('🔍 ForumService: Found $unreadCount unread messages');
      return Result.success(unreadCount);
    } catch (e, stackTrace) {
      debugPrint('❌ ForumService: Error getting unread message count: $e');
      debugPrint('❌ ForumService: Stack trace: $stackTrace');
      return Result.error('Failed to get unread message count: $e');
    }
  }

  /// Helper method to map database response to Forum object
  Forum _mapToForum(Map<String, dynamic> data) {
    final List<Member> members = [];
    debugPrint('viewers: ${data['viewers']}');

    if (data['forum_members'] != null) {
      for (final memberData in data['forum_members']) {
        final userData = memberData['users'];
        if (userData != null) {
          members.add(
            Member(
              forumMemberId: memberData['id'],
              id: userData['id'],
              username: userData['username'] ?? '',
              profileImageLink: userData['profile_image_link'],
              joinedAt: DateTime.parse(memberData['created_at']),
              invitationStatus: memberData['invitation_status'] ?? '',
              mute: memberData['mute'] ?? false,
            ),
          );
        }
      }
    }

    return Forum(
      id: data['id'],
      createdAt: DateTime.parse(data['created_at']),
      forumName: data['forum_name'] ?? '',
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      createdBy: data['created_by'],
      members: members,
      memberCount: members.length,
      private: data['private'] ?? false,
      forumImageUrl: data['forum_image_url'],
    );
  }

  /// Helper method to map database response to ForumChat object
  ForumChat _mapToForumChat(Map<String, dynamic> data) {
    final userData = data['users'];
    final repliedToData = data['replied_to_chat'];
    final mentionsData = data['mentions'] as List? ?? [];
    // Parse reactions
    final List<Reaction> reactions = [];
    List<Viewer> viewers = [];

    // Parse viewers (handle null and empty cases)
    if (data['viewers'] != null && data['viewers'] is List) {
      final viewersList = data['viewers'] as List;
      for (final raw in viewersList) {
        if (raw != null && raw is Map<String, dynamic>) {
          viewers.add(
            Viewer(
              raw['id'] ?? '',
              raw['username'] ?? '',
              raw['profile_image_link'],
            ),
          );
        }
      }
    }
    if (data['reactions'] != null) {
      final reactionsData = data['reactions'] as List;
      debugPrint('🔍 ForumService: Parsing ${reactionsData.length} reactions');

      // Group reactions by emoji
      final Map<String, List<String>> groupedReactions = {};

      for (final reactionData in reactionsData) {
        final emoji = reactionData['reaction'] ?? '';
        final userId = reactionData['userId'] ?? '';

        if (emoji.isNotEmpty && userId.isNotEmpty) {
          if (!groupedReactions.containsKey(emoji)) {
            groupedReactions[emoji] = [];
          }
          if (!groupedReactions[emoji]!.contains(userId)) {
            groupedReactions[emoji]!.add(userId);
          }
        }
      }

      // Convert grouped reactions to Reaction objects
      groupedReactions.forEach((emoji, userIds) {
        reactions.add(Reaction(emoji: emoji, users: userIds));
      });

      debugPrint(
        '🔍 ForumService: Grouped into ${reactions.length} unique reaction types',
      );
    }

    // Parse mentions
    final List<Mention> mentions = [];
    for (final mentionData in mentionsData) {
      mentions.add(
        Mention(
          mentionData['id'].toString(),
          mentionData['users']?['username'] ?? '',
          mentionData['users']?['profile_image_link'],
          null,
        ),
      );
    }

    // Handle replied_to_chat properly - it might be a list or a map
    ForumChat? repliedToChat;
    if (repliedToData != null) {
      if (repliedToData is List && repliedToData.isNotEmpty) {
        // If it's a list, take the first element
        repliedToChat = _mapToForumChat(
          repliedToData.first as Map<String, dynamic>,
        );
      } else if (repliedToData is Map<String, dynamic>) {
        // If it's already a map, use it directly
        repliedToChat = _mapToForumChat(repliedToData);
      }
    }

    return ForumChat(
      id: data['id'],
      message: data['message'] ?? '',
      imageUrl: data['image_url'],
      sentAt: DateTime.parse(data['sent_at']),
      sender: data['sender'] ?? '',
      repliedTo: repliedToChat,
      reactions: reactions,
      viewers: viewers,
      messageWarning: data['message_warning'],
      users: userData != null
          ? Users(
              id: userData['id'],
              username: userData['username'] ?? '',
              profileImageLink: userData['profile_image_link'],
              isActive: userData['is_active'] ?? false,
            )
          : null,
      mentions: mentions,
    );
  }

  /// Send push notifications to forum members about a new chat message
  Future<void> _sendForumChatNotifications({
    required int forumId,
    required String senderId,
    required String senderName,
    required String message,
    required int chatId,
    String? imageUrl,
    String? icon,
  }) async {
    try {
      // Fetch forum details and members (excluding the sender)
      final forumResponse = await _client
          .from('forum')
          .select('''
            forum_name,
            forum_members!inner(
              users!inner(id, username),
              mute
            )
          ''')
          .eq('id', forumId)
          .single();

      final forumName = forumResponse['forum_name'] ?? 'Unknown Forum';
      final members = forumResponse['forum_members'] as List<dynamic>;

      // Get member IDs who should receive notifications (not muted, not the sender)
      final memberIds = members
          .where((member) {
            final userId = member['users']['id'] as String;
            final isMuted = member['mute'] as bool? ?? false;
            return userId != senderId && !isMuted;
          })
          .map((member) => member['users']['id'] as String)
          .toList();

      if (memberIds.isNotEmpty) {
        // Send notification to all members at once
        final success = await NotificationService.sendForumMemberNotification(
          memberIds: memberIds,
          senderName: senderName,
          message: message,
          forumId: forumId,
          chatId: chatId,
          forumName: forumName,
        );

        if (success) {
          debugPrint(
            '✅ Forum chat notifications sent to ${memberIds.length} members',
          );
        } else {
          debugPrint('❌ Failed to send forum chat notifications');
        }
      } else {
        debugPrint('ℹ️ No members to notify for forum $forumId');
      }
    } catch (e) {
      debugPrint('❌ Error sending forum chat notifications: $e');
    }
  }

  /// Updates forum details like name, privacy, and image
  Future<Result<void>> updateForum({
    required int forumId,
    String? forumName,
    bool? private,
    XFile? forumImageFile,
  }) async {
    try {
      debugPrint('🔄 ForumService: Updating forum $forumId');

      String? imageUrl;

      // Handle image upload if provided
      if (forumImageFile != null) {
        imageUrl = await SupabaseService.uploadImage(forumImageFile);

        if (imageUrl == null) {
          return Result.error('Failed to upload forum image');
        }
      }

      // Build update data
      final Map<String, dynamic> updateData = {};
      if (forumName != null) updateData['forum_name'] = forumName;
      if (private != null) updateData['private'] = private;
      if (imageUrl != null) updateData['forum_image_url'] = imageUrl;

      if (updateData.isEmpty) {
        return Result.error('No data to update');
      }

      // Update forum
      await _client.from('forum').update(updateData).eq('id', forumId);

      debugPrint('✅ ForumService: Forum updated successfully');
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ ForumService: Error updating forum: $e');
      return Result.error('Failed to update forum: $e');
    }
  }

  /// Removes a member from the forum
  Future<Result<void>> removeMemberFromForum({
    required int forumId,
    required String userId,
    required String removedBy,
  }) async {
    try {
      debugPrint(
        '🚫 ForumService: Removing member $userId from forum $forumId',
      );

      // Check if the person removing has permission (is creator or admin)
      final forumResponse = await _client
          .from('forum')
          .select('created_by')
          .eq('id', forumId)
          .single();

      final createdBy = forumResponse['created_by'] as String;

      // Only the creator can remove members
      if (removedBy != createdBy && removedBy != userId) {
        return Result.error('Only forum creator can remove members');
      }

      // Remove member from forum_members table
      await _client
          .from('forum_members')
          .delete()
          .eq('forum', forumId)
          .eq('member', userId);

      debugPrint('✅ ForumService: Member removed successfully');
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ ForumService: Error removing member: $e');
      return Result.error('Failed to remove member: $e');
    }
  }

  /// Allows a user to leave a forum
  Future<Result<void>> leaveForum({
    required int forumId,
    required String userId,
  }) async {
    try {
      debugPrint('🚪 ForumService: User $userId leaving forum $forumId');

      // Check if user is the creator
      final forumResponse = await _client
          .from('forum')
          .select('created_by')
          .eq('id', forumId)
          .single();

      final createdBy = forumResponse['created_by'] as String;

      // Count approved members
      final membersResponse = await _client
          .from('forum_members')
          .select('id')
          .eq('forum', forumId)
          .eq('invitation_status', 'APPROVED');

      final memberCount = membersResponse.length;

      if (createdBy == userId) {
        // If creator is leaving, either transfer ownership or delete forum
        if (memberCount > 1) {
          // Transfer ownership to first available member
          final membersResponse = await _client
              .from('forum_members')
              .select('member')
              .eq('forum', forumId)
              .neq('member', userId)
              .eq('invitation_status', 'APPROVED')
              .limit(1);

          if (membersResponse.isNotEmpty) {
            final newCreator = membersResponse.first['member'] as String;

            // Update forum creator
            await _client
                .from('forum')
                .update({'created_by': newCreator})
                .eq('id', forumId);

            debugPrint('👑 ForumService: Transferred ownership to $newCreator');
          }
        } else {
          // Delete forum if creator is the only member
          await _client.from('forum').delete().eq('id', forumId);
          debugPrint(
            '🗑️ ForumService: Deleted forum as creator was the only member',
          );
          return Result.success(null);
        }
      }

      // Remove user from forum_members
      await _client
          .from('forum_members')
          .delete()
          .eq('forum', forumId)
          .eq('member', userId);

      debugPrint('✅ ForumService: User left forum successfully');
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ ForumService: Error leaving forum: $e');
      return Result.error('You cannot leave this forum');
    }
  }
}
