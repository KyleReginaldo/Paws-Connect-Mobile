// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

part 'notification_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Notification with NotificationMappable {
  final int id;
  final String title;
  final String content;
  final String user;
  final String createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.createdAt,
  });
}
