import 'package:image_picker/image_picker.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/forum_service.dart';
import 'package:paws_connect/features/forum/models/forum_model.dart';

class ForumProvider {
  final ForumService _forumService = ForumService();

  Future<Result<List<Forum>>> fetchForums(String userId) async {
    return await _forumService.fetchUserForums(userId);
  }

  Future<Result<Forum>> fetchForumById(int forumId, String userId) async {
    return await _forumService.fetchForumById(forumId, userId);
  }

  Future<Result<ForumMessage>> fetchForumChats(
    int forumId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _forumService.fetchForumChats(
      forumId,
      page: page,
      limit: limit,
    );
  }

  Future<Result<List<AvailableUser>>> fetchAvailableUser(
    int forumId, {
    String? username,
  }) async {
    return await _forumService.fetchAvailableUsers(
      forumId,
      searchUsername: username,
    );
  }

  Future<Result<List<AvailableUser>>> fetchForumMembers(int forumId) async {
    return await _forumService.fetchForumMembers(forumId);
  }

  Future<void> sendChat({
    required String sender,
    String? message,
    required int forumId,
    XFile? imageFile,
    int? repliedTo,
    List<String>? mentions,
  }) async {
    final result = await _forumService.sendChat(
      sender: sender,
      message: message,
      forumId: forumId,
      imageFile: imageFile,
      repliedTo: repliedTo,
      mentions: mentions,
    );

    if (result.isError) {
      throw Exception(result.error);
    }
  }

  Future<void> addForum({
    required String userId,
    required String forumName,
    required bool private,
    XFile? forumImageFile,
  }) async {
    final result = await _forumService.createForum(
      userId: userId,
      forumName: forumName,
      private: private,
      forumImageFile: forumImageFile,
    );

    if (result.isError) {
      throw Exception(result.error);
    }
  }

  Future<Result<String>> updateForum({
    required int forumId,
    String? forumName,
    bool? private,
    XFile? forumImageFile,
  }) async {
    final result = await _forumService.updateForum(
      forumId: forumId,
      forumName: forumName,
      private: private,
      forumImageFile: forumImageFile,
    );

    if (result.isSuccess) {
      return Result.success('Forum updated successfully');
    } else {
      return Result.error(result.error);
    }
  }

  Future<Result<String>> addMembers({
    required String userId,
    required int forumId,
    required List<String> memberIds,
  }) async {
    try {
      for (final memberId in memberIds) {
        final result = await _forumService.addMemberToForum(
          forumId: forumId,
          userId: memberId,
          inviterUserId: userId,
        );

        if (result.isError) {
          return Result.error(result.error);
        }
      }
      return Result.success('Members added successfully');
    } catch (e) {
      return Result.error('Failed to add members: $e');
    }
  }

  Future<Result<String>> approveOrRejectMember({
    required int forumId,
    required int forumMemberId,
    required String status,
  }) async {
    final result = await _forumService.updateMemberStatus(
      forumMemberId: forumMemberId,
      status: status,
    );

    if (result.isSuccess) {
      return Result.success('Member status updated successfully');
    } else {
      return Result.error(result.error);
    }
  }

  Future<Result<String>> invitedMemberFromLink({
    required String invitedBy,
    required int forumId,
    required String memberId,
  }) async {
    final result = await _forumService.addMemberToForum(
      forumId: forumId,
      userId: memberId,
      inviterUserId: invitedBy,
    );

    if (result.isSuccess) {
      return Result.success('Member invited successfully');
    } else {
      return Result.error(result.error);
    }
  }

  Future<Result<String>> toggleForumNotificationSettings({
    required int forumMemberId,
    required bool mute,
  }) async {
    final result = await _forumService.toggleNotificationSettings(
      forumMemberId: forumMemberId,
      mute: mute,
    );

    if (result.isSuccess) {
      return Result.success(
        mute ? 'Notifications muted' : 'Notifications unmuted',
      );
    } else {
      return Result.error(result.error);
    }
  }

  Future<Result<String>> addReaction({
    required int forumId,
    required int chatId,
    required String reaction,
    required String userId,
  }) async {
    final result = await _forumService.toggleReaction(
      chatId: chatId,
      userId: userId,
      reaction: reaction,
      isAdding: true,
    );

    if (result.isSuccess) {
      return Result.success('Reaction added');
    } else {
      return Result.error(result.error);
    }
  }

  Future<Result<String>> removeReaction({
    required int forumId,
    required int chatId,
    required String reaction,
    required String userId,
  }) async {
    final result = await _forumService.toggleReaction(
      chatId: chatId,
      userId: userId,
      reaction: reaction,
      isAdding: false,
    );

    if (result.isSuccess) {
      return Result.success('Reaction removed');
    } else {
      return Result.error(result.error);
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
    final result = await _forumService.leaveForum(
      forumId: forumId,
      userId: userId,
    );

    if (result.isSuccess) {
      return Result.success('Successfully left the forum');
    } else {
      return Result.error(result.error);
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
    final result = await _forumService.removeMemberFromForum(
      forumId: forumId,
      userId: userId,
      removedBy: kickedBy,
    );

    if (result.isSuccess) {
      return Result.success('Member removed successfully');
    } else {
      return Result.error(result.error);
    }
  }

  Future<Result<String>> removeChat({
    required int forumId,
    required int chatId,
    required String sender,
  }) async {
    final result = await _forumService.deleteChat(
      chatId: chatId,
      userId: sender,
    );

    if (result.isSuccess) {
      return Result.success('Chat deleted successfully');
    } else {
      return Result.error(result.error);
    }
  }
}
