// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

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

  Event(
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.createdBy,
    this.images,
    this.suggestions,
    this.comments,
  );
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Comment with CommentMappable {
  final int like;
  final String content;
  final DateTime createdAt;
  final CommentUser user;

  Comment(this.like, this.content, this.createdAt, this.user);
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CommentUser with CommentUserMappable {
  final String username;
  final String profileImageLink;
  final String id;

  CommentUser(this.username, this.profileImageLink, this.id);
}
