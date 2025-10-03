// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

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
  List<String> photos;
  String? color;
  bool? isFavorite;
  final List<PetAdoption>? adoption;
  final PetAdoption? adopted;
  final String? happinessImage;

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
    required this.photos,
    required this.color,
    this.isFavorite,
    this.adoption,
    required this.adopted,
    this.happinessImage,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class PetAdoption with PetAdoptionMappable {
  final int id;
  final DateTime createdAt;
  final UserProfile user;
  final String status;

  PetAdoption({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.status,
  });
}
