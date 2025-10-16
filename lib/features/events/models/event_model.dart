// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/features/fundraising/models/fundraising_model.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

import '../../../core/extension/int.ext.dart';
import '../../../flavors/flavor_config.dart';

part 'event_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Event with EventMappable {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final List<String>? images;
  final List<String>? suggestions;
  final List<Comment>? comments;
  final DateTime? startingDate;
  final DateTime? endedAt;
  final List<EventMember>? members;
  final Fundraising? fundraising;
  final Pet? pet;

  Event(
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.createdBy,
    this.images,
    this.suggestions,
    this.comments,
    this.startingDate,
    this.endedAt,
    this.members,
    this.fundraising,
    this.pet,
  );

  /// Check if a user is a member of this event
  bool isUserMember(String userId) {
    return members?.any((e) => e.user.id == userId) ?? false;
  }

  /// Get the number of members in this event
  int get memberCount => members?.length ?? 0;

  List<String>? get transformedImages {
    if (FlavorConfig.isDevelopment()) {
      return images?.map((image) => image.transformedUrl).toList();
    } else {
      return images;
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Comment with CommentMappable {
  final int id;
  final List<String>? likes;
  final String content;
  final DateTime createdAt;
  final CommentUser user;

  Comment(this.id, this.likes, this.content, this.createdAt, this.user);
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CommentUser with CommentUserMappable {
  final String username;
  final String? profileImageLink;
  final String id;

  CommentUser(this.username, this.profileImageLink, this.id);
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Member with MemberMappable {
  final String username;
  final String? profileImageLink;
  final String id;

  Member(this.username, this.profileImageLink, this.id);
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class EventMember with EventMemberMappable {
  final int id;
  final DateTime joinedAt;
  final Member user;

  EventMember(this.id, this.joinedAt, this.user);
}
