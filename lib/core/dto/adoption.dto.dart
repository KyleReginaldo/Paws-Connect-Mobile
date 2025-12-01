class AdoptionApplicationDTO {
  final String? createdAt;
  final bool? hasChildrenInHome;
  final bool? hasOtherPetsInHome;
  final bool? haveOutdoorSpace;
  final bool? havePermissionFromLandlord;
  final int? id;
  final bool? isRenting;
  final int? numberOfHouseholdMembers;
  final int? pet;
  final String? typeOfResidence;
  final String? user;
  // New fields for adoption form
  final String? reasonForAdopting;
  final bool? willingToVisitShelter;
  final bool? willingToVisitAgain;
  final bool? adoptingForSelf;
  final String? howCanYouGiveFurReverHome;
  final String? whereDidYouHearAboutUs;

  AdoptionApplicationDTO({
    this.createdAt,
    this.hasChildrenInHome,
    this.hasOtherPetsInHome,
    this.haveOutdoorSpace,
    this.havePermissionFromLandlord,
    this.id,
    this.isRenting,
    this.numberOfHouseholdMembers,
    this.pet,
    this.typeOfResidence,
    this.user,
    this.reasonForAdopting,
    this.willingToVisitShelter,
    this.willingToVisitAgain,
    this.adoptingForSelf,
    this.howCanYouGiveFurReverHome,
    this.whereDidYouHearAboutUs,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (createdAt != null) map['created_at'] = createdAt;
    if (hasChildrenInHome != null)
      map['has_children_in_home'] = hasChildrenInHome;
    if (hasOtherPetsInHome != null)
      map['has_other_pets_in_home'] = hasOtherPetsInHome;
    if (haveOutdoorSpace != null) map['have_outdoor_space'] = haveOutdoorSpace;
    if (havePermissionFromLandlord != null)
      map['have_permission_from_landlord'] = havePermissionFromLandlord;
    if (id != null) map['id'] = id;
    if (isRenting != null) map['is_renting'] = isRenting;
    if (numberOfHouseholdMembers != null)
      map['number_of_household_members'] = numberOfHouseholdMembers;
    if (pet != null) map['pet'] = pet;
    if (typeOfResidence != null) map['type_of_residence'] = typeOfResidence;
    if (user != null) map['user'] = user;
    if (reasonForAdopting != null)
      map['reason_for_adopting'] = reasonForAdopting;
    if (willingToVisitShelter != null)
      map['willing_to_visit_shelter'] = willingToVisitShelter;
    if (willingToVisitAgain != null)
      map['willing_to_visit_again'] = willingToVisitAgain;
    if (adoptingForSelf != null) map['adopting_for_self'] = adoptingForSelf;
    if (howCanYouGiveFurReverHome != null)
      map['how_can_you_give_fur_rever_home'] = howCanYouGiveFurReverHome;
    if (whereDidYouHearAboutUs != null)
      map['where_did_you_hear_about_us'] = whereDidYouHearAboutUs;

    return map;
  }
}
