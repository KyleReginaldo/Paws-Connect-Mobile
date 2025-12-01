// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'adoption_model.dart';

class AdoptionMapper extends ClassMapperBase<Adoption> {
  AdoptionMapper._();

  static AdoptionMapper? _instance;
  static AdoptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AdoptionMapper._());
      UserProfileMapper.ensureInitialized();
      PetMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Adoption';

  static int _$id(Adoption v) => v.id;
  static const Field<Adoption, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(Adoption v) => v.createdAt;
  static const Field<Adoption, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static UserProfile _$users(Adoption v) => v.users;
  static const Field<Adoption, UserProfile> _f$users = Field('users', _$users);
  static String? _$typeOfResidence(Adoption v) => v.typeOfResidence;
  static const Field<Adoption, String> _f$typeOfResidence = Field(
    'typeOfResidence',
    _$typeOfResidence,
    key: r'type_of_residence',
    opt: true,
  );
  static bool? _$isRenting(Adoption v) => v.isRenting;
  static const Field<Adoption, bool> _f$isRenting = Field(
    'isRenting',
    _$isRenting,
    key: r'is_renting',
    opt: true,
  );
  static bool? _$havePermissionFromLandlord(Adoption v) =>
      v.havePermissionFromLandlord;
  static const Field<Adoption, bool> _f$havePermissionFromLandlord = Field(
    'havePermissionFromLandlord',
    _$havePermissionFromLandlord,
    key: r'have_permission_from_landlord',
    opt: true,
  );
  static bool? _$haveOutdoorSpace(Adoption v) => v.haveOutdoorSpace;
  static const Field<Adoption, bool> _f$haveOutdoorSpace = Field(
    'haveOutdoorSpace',
    _$haveOutdoorSpace,
    key: r'have_outdoor_space',
    opt: true,
  );
  static int? _$numberOfHouseholdMembers(Adoption v) =>
      v.numberOfHouseholdMembers;
  static const Field<Adoption, int> _f$numberOfHouseholdMembers = Field(
    'numberOfHouseholdMembers',
    _$numberOfHouseholdMembers,
    key: r'number_of_household_members',
    opt: true,
  );
  static bool? _$hasChildrenInHome(Adoption v) => v.hasChildrenInHome;
  static const Field<Adoption, bool> _f$hasChildrenInHome = Field(
    'hasChildrenInHome',
    _$hasChildrenInHome,
    key: r'has_children_in_home',
    opt: true,
  );
  static bool? _$hasOtherPetsInHome(Adoption v) => v.hasOtherPetsInHome;
  static const Field<Adoption, bool> _f$hasOtherPetsInHome = Field(
    'hasOtherPetsInHome',
    _$hasOtherPetsInHome,
    key: r'has_other_pets_in_home',
    opt: true,
  );
  static String _$status(Adoption v) => v.status;
  static const Field<Adoption, String> _f$status = Field('status', _$status);
  static Pet _$pets(Adoption v) => v.pets;
  static const Field<Adoption, Pet> _f$pets = Field('pets', _$pets);
  static String? _$reasonForAdopting(Adoption v) => v.reasonForAdopting;
  static const Field<Adoption, String> _f$reasonForAdopting = Field(
    'reasonForAdopting',
    _$reasonForAdopting,
    key: r'reason_for_adopting',
    opt: true,
  );
  static bool? _$willingToVisitShelter(Adoption v) => v.willingToVisitShelter;
  static const Field<Adoption, bool> _f$willingToVisitShelter = Field(
    'willingToVisitShelter',
    _$willingToVisitShelter,
    key: r'willing_to_visit_shelter',
    opt: true,
  );
  static bool? _$willingToVisitAgain(Adoption v) => v.willingToVisitAgain;
  static const Field<Adoption, bool> _f$willingToVisitAgain = Field(
    'willingToVisitAgain',
    _$willingToVisitAgain,
    key: r'willing_to_visit_again',
    opt: true,
  );
  static bool? _$adoptingForSelf(Adoption v) => v.adoptingForSelf;
  static const Field<Adoption, bool> _f$adoptingForSelf = Field(
    'adoptingForSelf',
    _$adoptingForSelf,
    key: r'adopting_for_self',
    opt: true,
  );
  static String? _$howCanYouGiveFurReverHome(Adoption v) =>
      v.howCanYouGiveFurReverHome;
  static const Field<Adoption, String> _f$howCanYouGiveFurReverHome = Field(
    'howCanYouGiveFurReverHome',
    _$howCanYouGiveFurReverHome,
    key: r'how_can_you_give_fur_rever_home',
    opt: true,
  );
  static String? _$whereDidYouHearAboutUs(Adoption v) =>
      v.whereDidYouHearAboutUs;
  static const Field<Adoption, String> _f$whereDidYouHearAboutUs = Field(
    'whereDidYouHearAboutUs',
    _$whereDidYouHearAboutUs,
    key: r'where_did_you_hear_about_us',
    opt: true,
  );

  @override
  final MappableFields<Adoption> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #users: _f$users,
    #typeOfResidence: _f$typeOfResidence,
    #isRenting: _f$isRenting,
    #havePermissionFromLandlord: _f$havePermissionFromLandlord,
    #haveOutdoorSpace: _f$haveOutdoorSpace,
    #numberOfHouseholdMembers: _f$numberOfHouseholdMembers,
    #hasChildrenInHome: _f$hasChildrenInHome,
    #hasOtherPetsInHome: _f$hasOtherPetsInHome,
    #status: _f$status,
    #pets: _f$pets,
    #reasonForAdopting: _f$reasonForAdopting,
    #willingToVisitShelter: _f$willingToVisitShelter,
    #willingToVisitAgain: _f$willingToVisitAgain,
    #adoptingForSelf: _f$adoptingForSelf,
    #howCanYouGiveFurReverHome: _f$howCanYouGiveFurReverHome,
    #whereDidYouHearAboutUs: _f$whereDidYouHearAboutUs,
  };

  static Adoption _instantiate(DecodingData data) {
    return Adoption(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      users: data.dec(_f$users),
      typeOfResidence: data.dec(_f$typeOfResidence),
      isRenting: data.dec(_f$isRenting),
      havePermissionFromLandlord: data.dec(_f$havePermissionFromLandlord),
      haveOutdoorSpace: data.dec(_f$haveOutdoorSpace),
      numberOfHouseholdMembers: data.dec(_f$numberOfHouseholdMembers),
      hasChildrenInHome: data.dec(_f$hasChildrenInHome),
      hasOtherPetsInHome: data.dec(_f$hasOtherPetsInHome),
      status: data.dec(_f$status),
      pets: data.dec(_f$pets),
      reasonForAdopting: data.dec(_f$reasonForAdopting),
      willingToVisitShelter: data.dec(_f$willingToVisitShelter),
      willingToVisitAgain: data.dec(_f$willingToVisitAgain),
      adoptingForSelf: data.dec(_f$adoptingForSelf),
      howCanYouGiveFurReverHome: data.dec(_f$howCanYouGiveFurReverHome),
      whereDidYouHearAboutUs: data.dec(_f$whereDidYouHearAboutUs),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Adoption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Adoption>(map);
  }

  static Adoption fromJson(String json) {
    return ensureInitialized().decodeJson<Adoption>(json);
  }
}

mixin AdoptionMappable {
  String toJson() {
    return AdoptionMapper.ensureInitialized().encodeJson<Adoption>(
      this as Adoption,
    );
  }

  Map<String, dynamic> toMap() {
    return AdoptionMapper.ensureInitialized().encodeMap<Adoption>(
      this as Adoption,
    );
  }

  AdoptionCopyWith<Adoption, Adoption, Adoption> get copyWith =>
      _AdoptionCopyWithImpl<Adoption, Adoption>(
        this as Adoption,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AdoptionMapper.ensureInitialized().stringifyValue(this as Adoption);
  }

  @override
  bool operator ==(Object other) {
    return AdoptionMapper.ensureInitialized().equalsValue(
      this as Adoption,
      other,
    );
  }

  @override
  int get hashCode {
    return AdoptionMapper.ensureInitialized().hashValue(this as Adoption);
  }
}

extension AdoptionValueCopy<$R, $Out> on ObjectCopyWith<$R, Adoption, $Out> {
  AdoptionCopyWith<$R, Adoption, $Out> get $asAdoption =>
      $base.as((v, t, t2) => _AdoptionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AdoptionCopyWith<$R, $In extends Adoption, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  UserProfileCopyWith<$R, UserProfile, UserProfile> get users;
  PetCopyWith<$R, Pet, Pet> get pets;
  $R call({
    int? id,
    DateTime? createdAt,
    UserProfile? users,
    String? typeOfResidence,
    bool? isRenting,
    bool? havePermissionFromLandlord,
    bool? haveOutdoorSpace,
    int? numberOfHouseholdMembers,
    bool? hasChildrenInHome,
    bool? hasOtherPetsInHome,
    String? status,
    Pet? pets,
    String? reasonForAdopting,
    bool? willingToVisitShelter,
    bool? willingToVisitAgain,
    bool? adoptingForSelf,
    String? howCanYouGiveFurReverHome,
    String? whereDidYouHearAboutUs,
  });
  AdoptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AdoptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Adoption, $Out>
    implements AdoptionCopyWith<$R, Adoption, $Out> {
  _AdoptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Adoption> $mapper =
      AdoptionMapper.ensureInitialized();
  @override
  UserProfileCopyWith<$R, UserProfile, UserProfile> get users =>
      $value.users.copyWith.$chain((v) => call(users: v));
  @override
  PetCopyWith<$R, Pet, Pet> get pets =>
      $value.pets.copyWith.$chain((v) => call(pets: v));
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    UserProfile? users,
    Object? typeOfResidence = $none,
    Object? isRenting = $none,
    Object? havePermissionFromLandlord = $none,
    Object? haveOutdoorSpace = $none,
    Object? numberOfHouseholdMembers = $none,
    Object? hasChildrenInHome = $none,
    Object? hasOtherPetsInHome = $none,
    String? status,
    Pet? pets,
    Object? reasonForAdopting = $none,
    Object? willingToVisitShelter = $none,
    Object? willingToVisitAgain = $none,
    Object? adoptingForSelf = $none,
    Object? howCanYouGiveFurReverHome = $none,
    Object? whereDidYouHearAboutUs = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (users != null) #users: users,
      if (typeOfResidence != $none) #typeOfResidence: typeOfResidence,
      if (isRenting != $none) #isRenting: isRenting,
      if (havePermissionFromLandlord != $none)
        #havePermissionFromLandlord: havePermissionFromLandlord,
      if (haveOutdoorSpace != $none) #haveOutdoorSpace: haveOutdoorSpace,
      if (numberOfHouseholdMembers != $none)
        #numberOfHouseholdMembers: numberOfHouseholdMembers,
      if (hasChildrenInHome != $none) #hasChildrenInHome: hasChildrenInHome,
      if (hasOtherPetsInHome != $none) #hasOtherPetsInHome: hasOtherPetsInHome,
      if (status != null) #status: status,
      if (pets != null) #pets: pets,
      if (reasonForAdopting != $none) #reasonForAdopting: reasonForAdopting,
      if (willingToVisitShelter != $none)
        #willingToVisitShelter: willingToVisitShelter,
      if (willingToVisitAgain != $none)
        #willingToVisitAgain: willingToVisitAgain,
      if (adoptingForSelf != $none) #adoptingForSelf: adoptingForSelf,
      if (howCanYouGiveFurReverHome != $none)
        #howCanYouGiveFurReverHome: howCanYouGiveFurReverHome,
      if (whereDidYouHearAboutUs != $none)
        #whereDidYouHearAboutUs: whereDidYouHearAboutUs,
    }),
  );
  @override
  Adoption $make(CopyWithData data) => Adoption(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    users: data.get(#users, or: $value.users),
    typeOfResidence: data.get(#typeOfResidence, or: $value.typeOfResidence),
    isRenting: data.get(#isRenting, or: $value.isRenting),
    havePermissionFromLandlord: data.get(
      #havePermissionFromLandlord,
      or: $value.havePermissionFromLandlord,
    ),
    haveOutdoorSpace: data.get(#haveOutdoorSpace, or: $value.haveOutdoorSpace),
    numberOfHouseholdMembers: data.get(
      #numberOfHouseholdMembers,
      or: $value.numberOfHouseholdMembers,
    ),
    hasChildrenInHome: data.get(
      #hasChildrenInHome,
      or: $value.hasChildrenInHome,
    ),
    hasOtherPetsInHome: data.get(
      #hasOtherPetsInHome,
      or: $value.hasOtherPetsInHome,
    ),
    status: data.get(#status, or: $value.status),
    pets: data.get(#pets, or: $value.pets),
    reasonForAdopting: data.get(
      #reasonForAdopting,
      or: $value.reasonForAdopting,
    ),
    willingToVisitShelter: data.get(
      #willingToVisitShelter,
      or: $value.willingToVisitShelter,
    ),
    willingToVisitAgain: data.get(
      #willingToVisitAgain,
      or: $value.willingToVisitAgain,
    ),
    adoptingForSelf: data.get(#adoptingForSelf, or: $value.adoptingForSelf),
    howCanYouGiveFurReverHome: data.get(
      #howCanYouGiveFurReverHome,
      or: $value.howCanYouGiveFurReverHome,
    ),
    whereDidYouHearAboutUs: data.get(
      #whereDidYouHearAboutUs,
      or: $value.whereDidYouHearAboutUs,
    ),
  );

  @override
  AdoptionCopyWith<$R2, Adoption, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AdoptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

