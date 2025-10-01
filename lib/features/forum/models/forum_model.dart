// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

part 'forum_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Forum with ForumMappable {
  final int id;
  final DateTime createdAt;
  final String forumName;
  final DateTime? updatedAt;
  final String createdBy;
  final List<Member>? members;
  final int memberCount;
  final bool private;
  final LastChat? lastChat;

  Forum({
    required this.id,
    required this.createdAt,
    required this.forumName,
    this.updatedAt,
    required this.createdBy,
    this.members,
    required this.memberCount,
    required this.private,
    this.lastChat,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ForumChat with ForumChatMappable {
  final int id;
  final DateTime sentAt;
  final String sender;
  final String message;
  final Users users;
  final String? imageUrl;

  ForumChat({
    required this.id,
    required this.sentAt,
    required this.sender,
    required this.message,
    required this.users,
    this.imageUrl,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Users with UsersMappable {
  final String id;
  final String username;

  Users({required this.id, required this.username});
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
}
