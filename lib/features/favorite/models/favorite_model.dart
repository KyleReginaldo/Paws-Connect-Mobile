// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

part 'favorite_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Favorite with FavoriteMappable {
  final int id;
  final DateTime createdAt;
  final Pet pet;

  Favorite({required this.id, required this.createdAt, required this.pet});
}
