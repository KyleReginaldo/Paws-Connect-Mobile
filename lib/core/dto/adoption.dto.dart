class AdoptionApplicationDTO {
  final bool hasChildrenInHome;
  final bool hasOtherPetsInHome;
  final bool haveOutdoorSpace;
  final bool havePermissionFromLandlord;
  final bool isRenting;
  final int numberOfHouseholdMembers;
  final int pet;
  final String typeOfResidence;
  final String user;

  AdoptionApplicationDTO({
    required this.hasChildrenInHome,
    required this.hasOtherPetsInHome,
    required this.haveOutdoorSpace,
    required this.havePermissionFromLandlord,
    required this.isRenting,
    required this.numberOfHouseholdMembers,
    required this.pet,
    required this.typeOfResidence,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'has_children_in_home': hasChildrenInHome,
      'has_other_pets_in_home': hasOtherPetsInHome,
      'have_outdoor_space': haveOutdoorSpace,
      'have_permission_from_landlord': havePermissionFromLandlord,
      'is_renting': isRenting,
      'number_of_household_members': numberOfHouseholdMembers,
      'pet': pet,
      'type_of_residence': typeOfResidence,
      'user': user,
    };
  }
}
