import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/features/forum/models/forum_model.dart';

class ForumProvider {
  Future<Result<List<Forum>>> fetchForums(String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/forum/user/$userId'),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<Forum> forums = [];
      data['data'].forEach((forum) {
        forums.add(ForumMapper.fromMap(forum));
      });
      return Result.success(forums);
    } else {
      return Result.error(data['message'] ?? 'Failed to fetch forums');
    }
  }

  Future<Result<Forum>> fetchForumById(int forumId, String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId?userId=$userId'),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Result.success(ForumMapper.fromMap(data['data']));
    } else {
      return Result.error(data['message'] ?? 'Failed to fetch forums');
    }
  }

  Future<Result<List<ForumChat>>> fetchForumChats(
    int forumId, {
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId/chats')
        .replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
        );

    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<ForumChat> chats = [];
      data['data'].forEach((chat) {
        chats.add(ForumChatMapper.fromMap(chat));
      });
      return Result.success(chats);
    } else {
      return Result.error(data['message'] ?? 'Failed to fetch forum chats');
    }
  }

  Future<Result<List<AvailableUser>>> fetchAvailableUser(
    int forumId, {
    String? username,
  }) async {
    try {
      final uri =
          Uri.parse(
            '${dotenv.get('BASE_URL')}/forum/$forumId/members/available',
          ).replace(
            queryParameters: {
              if (username != null && username.isNotEmpty) 'search': username,
            },
          );
      final response = await http.get(uri);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<AvailableUser> users = [];
        if (data['data'].isEmpty) {
          return Result.error('No users found');
        } else {
          data['data'].forEach((user) {
            users.add(AvailableUserMapper.fromMap(user));
          });
          return Result.success(users);
        }
      } else {
        return Result.error(
          data['message'] ?? 'Failed to fetch available users',
        );
      }
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }

  Future<Result<List<AvailableUser>>> fetchForumMembers(int forumId) async {
    try {
      final response = await supabase
          .from('forum_members')
          .select('''
            id,
            users!inner (
              id,
              username,
              profile_image_link
            )
          ''')
          .eq('forum', forumId)
          .eq('status', 'approved');

      final List<AvailableUser> members = [];
      for (final row in response) {
        final user = row['users'];
        if (user != null) {
          members.add(
            AvailableUser(
              id: user['id'],
              username: user['username'],
              profileImageLink: user['profile_image_link'],
            ),
          );
        }
      }

      return Result.success(members);
    } catch (e) {
      debugPrint('Error fetching forum members: $e');
      return Result.error('Failed to fetch forum members');
    }
  }

  Future<void> sendChat({
    required String sender,
    required String message,
    required int forumId,
    XFile? imageFile,
    int? repliedTo,
    List<String>? mentions,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await SupabaseService.uploadImage(imageFile);
    }
    debugPrint('Image URL: $imageUrl');
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId/chats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender': sender,
        'message': message,
        if (imageUrl != null) 'image_url': imageUrl,
        if (repliedTo != null) 'replied_to': repliedTo,
        if (mentions != null && mentions.isNotEmpty) 'mentions': mentions,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  Future<void> addForum({
    required String userId,
    required String forumName,
    required bool private,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/forum'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "created_by": userId,
        "forum_name": forumName,
        "private": private,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create forum');
    }
  }

  Future<Result<String>> addMembers({
    required String userId,
    required int forumId,
    required List<String> memberIds,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId/members'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"added_by": userId, "members": memberIds}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Result.success(data['message']);
    } else {
      return Result.error('Failed to add members');
    }
  }

  Future<Result<String>> approveOrRejectMember({
    required int forumId,
    required int forumMemberId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${dotenv.get('BASE_URL')}/forum/$forumId/members/$forumMemberId?status=$status',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Result.success(data['message']);
    } else {
      return Result.error('Failed to add members');
    }
  }

  Future<Result<String>> invitedMemberFromLink({
    required String invitedBy,
    required int forumId,
    required String memberId,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId/members'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "added_by": invitedBy,
        "members": [memberId],
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Result.success(data['message']);
    } else {
      return Result.error('Failed to add members');
    }
  }

  Future<Result<String>> toggleForumNotificationSettings({
    required int forumMemberId,
    required bool mute,
  }) async {
    try {
      await supabase
          .from('forum_members')
          .update({'mute': mute})
          .eq('id', forumMemberId);
      return Result.success(
        mute ? 'Notifications muted' : 'Notifications unmuted',
      );
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }

  Future<Result<String>> addReaction({
    required int forumId,
    required int chatId,
    required String reaction,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${dotenv.get('BASE_URL')}/forum/$forumId/chats/$chatId/reactions',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reaction': reaction, 'user_id': userId}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Result.success(data['message'] ?? 'Reaction added');
      } else {
        return Result.error(data['message'] ?? 'Failed to add reaction');
      }
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }

  Future<Result<String>> removeReaction({
    required int forumId,
    required int chatId,
    required String reaction,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${dotenv.get('BASE_URL')}/forum/$forumId/chats/$chatId/reactions?reaction=$reaction&user_id=$userId',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Result.success(data['message'] ?? 'Reaction removed');
      } else {
        return Result.error(data['message'] ?? 'Failed to remove reaction');
      }
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }

  /// Quit a forum
  ///
  /// Allows a user to leave a forum by providing their user ID.
  ///
  /// Parameters:
  /// - [forumId]: The ID of the forum to quit
  /// - [userId]: The ID of the user who wants to quit the forum
  ///
  /// Returns a [Result] with success message or error message
  Future<Result<String>> quitForum({
    required int forumId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId/quit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);
      debugPrint('Quit Forum Response: $data');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.success(data['message'] ?? 'Successfully quit the forum');
      } else {
        return Result.error(data['error'] ?? 'Failed to quit forum');
      }
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }

  /// Kick a member from a forum
  ///
  /// Allows a forum admin/moderator to remove a member from the forum.
  ///
  /// Parameters:
  /// - [forumId]: The ID of the forum
  /// - [userId]: The ID of the user to be kicked
  /// - [kickedBy]: The ID of the user performing the kick action
  ///
  /// Returns a [Result] with success message or error message
  Future<Result<String>> kickMember({
    required int forumId,
    required String userId,
    required String kickedBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('BASE_URL')}/forum/$forumId/kick'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'kicked_by': kickedBy}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.success(data['message'] ?? 'Member kicked successfully');
      } else {
        return Result.error(data['message'] ?? 'Failed to kick member');
      }
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }

  Future<Result<String>> removeChat({
    required int forumId,
    required int chatId,
    required String sender,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${dotenv.get('BASE_URL')}/forum/$forumId/chats/$chatId?sender=$sender',
        ),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.success(data['message'] ?? 'Chat deleted successfully');
      } else {
        return Result.error(data['error'] ?? 'Failed to delete chat');
      }
    } catch (e) {
      return Result.error('Something went wrong: $e');
    }
  }
}
