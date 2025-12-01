import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

import '../../pets/models/pet_model.dart';

part 'adoption_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Adoption with AdoptionMappable {
  final int id;
  final DateTime createdAt;
  final UserProfile users;
  final String? typeOfResidence;
  final bool? isRenting;
  final bool? havePermissionFromLandlord;
  final bool? haveOutdoorSpace;
  final int? numberOfHouseholdMembers;
  final bool? hasChildrenInHome;
  final bool? hasOtherPetsInHome;
  final String status;
  final Pet pets;
  // New fields for adoption form
  final String? reasonForAdopting;
  final bool? willingToVisitShelter;
  final bool? willingToVisitAgain;
  final bool? adoptingForSelf;
  final String? howCanYouGiveFurReverHome;
  final String? whereDidYouHearAboutUs;

  const Adoption({
    required this.id,
    required this.createdAt,
    required this.users,
    this.typeOfResidence,
    this.isRenting,
    this.havePermissionFromLandlord,
    this.haveOutdoorSpace,
    this.numberOfHouseholdMembers,
    this.hasChildrenInHome,
    this.hasOtherPetsInHome,
    required this.status,
    required this.pets,
    this.reasonForAdopting,
    this.willingToVisitShelter,
    this.willingToVisitAgain,
    this.adoptingForSelf,
    this.howCanYouGiveFurReverHome,
    this.whereDidYouHearAboutUs,
  });
}
