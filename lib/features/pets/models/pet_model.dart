import 'package:dart_mappable/dart_mappable.dart';

part 'pet_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Pet with PetMappable {
  int id;
  DateTime createdAt;
  String name;
  String type;
  String breed;
  String gender;
  int age;
  DateTime dateOfBirth;
  String size;
  String weight;
  bool isVaccinated;
  bool isSpayedOrNeutured;
  String healthStatus;
  List<String> goodWith;
  bool isTrained;
  String rescueAddress;
  String description;
  String specialNeeds;
  String addedBy;
  String requestStatus;
  String photo;
  String? color;

  Pet({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.age,
    required this.dateOfBirth,
    required this.size,
    required this.weight,
    required this.isVaccinated,
    required this.isSpayedOrNeutured,
    required this.healthStatus,
    required this.goodWith,
    required this.isTrained,
    required this.rescueAddress,
    required this.description,
    required this.specialNeeds,
    required this.addedBy,
    required this.requestStatus,
    required this.photo,
    required this.color,
  });
}
