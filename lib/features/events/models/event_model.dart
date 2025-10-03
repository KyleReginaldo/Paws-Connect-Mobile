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

  Event(
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.createdBy,
    this.images,
    this.suggestions,
  );
}
