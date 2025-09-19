import 'package:dart_mappable/dart_mappable.dart';

import '../../pets/models/pet_model.dart';

part 'adoption_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Adoption with AdoptionMappable {
  final int id;
  final DateTime createdAt;
  final String user;
  final int pet;
  final String typeOfResidence;
  final bool isRenting;
  final bool havePermissionFromLandlord;
  final bool haveOutdoorSpace;
  final int numberOfHouseholdMembers;
  final bool hasChildrenInHome;
  final bool hasOtherPetsInHome;
  final String status;
  final Pet pets;

  const Adoption({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.pet,
    required this.typeOfResidence,
    required this.isRenting,
    required this.havePermissionFromLandlord,
    required this.haveOutdoorSpace,
    required this.numberOfHouseholdMembers,
    required this.hasChildrenInHome,
    required this.hasOtherPetsInHome,
    required this.status,
    required this.pets,
  });
}
