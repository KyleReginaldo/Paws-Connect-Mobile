// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

import '../../../core/extension/int.ext.dart';
import '../../../flavors/flavor_config.dart';

part 'forum_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Forum with ForumMappable {
  final int id;
  final DateTime createdAt;
  final String forumName;
  final DateTime? updatedAt;
  final String? createdBy;
  final List<Member>? members;
  final int memberCount;
  final bool private;
  final LastChat? lastChat;
  final String? forumImageUrl;

  Forum({
    required this.id,
    required this.createdAt,
    required this.forumName,
    this.updatedAt,
    this.createdBy,
    this.members,
    required this.memberCount,
    required this.private,
    this.lastChat,
    this.forumImageUrl,
  });

  String? get transformedForumImageUrl {
    if (FlavorConfig.isDevelopment()) {
      return forumImageUrl?.transformedUrl;
    } else {
      return forumImageUrl;
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ForumMessage with ForumMessageMappable {
  final List<ForumChat> chats;
  final String forumName;

  ForumMessage({required this.chats, required this.forumName});
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ForumChat with ForumChatMappable {
  final int id;
  final DateTime sentAt;
  final String sender;
  final String message;
  final Users? users;
  final String? imageUrl;
  final ForumChat? repliedTo;
  final List<Reaction>? reactions;
  final List<Viewer>? viewers;
  final List<Mention>? mentions;
  final String? messageWarning;

  ForumChat({
    required this.id,
    required this.sentAt,
    required this.sender,
    required this.message,
    required this.users,
    this.imageUrl,
    this.repliedTo,
    this.reactions,
    this.viewers,
    this.mentions,
    this.messageWarning,
  });

  String? get transformedImageUrl {
    if (FlavorConfig.isDevelopment()) {
      return imageUrl?.transformedUrl;
    } else {
      return imageUrl;
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Viewer with ViewerMappable {
  final String id;
  final String name;
  final String? profileImage;

  Viewer(this.id, this.name, this.profileImage);
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Mention with MentionMappable {
  final String id;
  final String name;
  final String? profileImage;
  final DateTime? mentionedAt;

  Mention(this.id, this.name, this.profileImage, this.mentionedAt);
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Users with UsersMappable {
  final String id;
  final String username;
  final String? profileImageLink;
  final bool? isActive;

  Users({
    required this.id,
    required this.username,
    this.profileImageLink,
    this.isActive,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Member with MemberMappable {
  final int forumMemberId;
  final String id;
  final String username;
  final String? profileImageLink;
  final DateTime joinedAt;
  final String invitationStatus;
  final bool mute;

  Member({
    required this.forumMemberId,
    required this.id,
    required this.username,
    this.profileImageLink,
    required this.joinedAt,
    required this.invitationStatus,
    required this.mute,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class AvailableUser with AvailableUserMappable {
  final String id;
  final String username;
  final String? profileImageLink;

  AvailableUser({
    required this.id,
    required this.username,
    this.profileImageLink,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class LastChat with LastChatMappable {
  final int id;
  final DateTime sentAt;
  final Users sender;
  final String message;
  final String? imageUrl;
  final bool? isViewed;

  LastChat({
    required this.id,
    required this.sentAt,
    required this.sender,
    required this.message,
    this.imageUrl,
    this.isViewed,
  });

  String? get transformedImageUrl {
    if (FlavorConfig.isDevelopment()) {
      return imageUrl?.transformedUrl;
    } else {
      return imageUrl;
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Reaction with ReactionMappable {
  final String emoji;
  final List<String> users;

  Reaction({required this.emoji, required this.users});
}
