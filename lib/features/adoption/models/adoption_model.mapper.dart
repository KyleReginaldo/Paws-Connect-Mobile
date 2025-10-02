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
  static String _$user(Adoption v) => v.user;
  static const Field<Adoption, String> _f$user = Field('user', _$user);
  static String _$typeOfResidence(Adoption v) => v.typeOfResidence;
  static const Field<Adoption, String> _f$typeOfResidence = Field(
    'typeOfResidence',
    _$typeOfResidence,
    key: r'type_of_residence',
  );
  static bool _$isRenting(Adoption v) => v.isRenting;
  static const Field<Adoption, bool> _f$isRenting = Field(
    'isRenting',
    _$isRenting,
    key: r'is_renting',
  );
  static bool _$havePermissionFromLandlord(Adoption v) =>
      v.havePermissionFromLandlord;
  static const Field<Adoption, bool> _f$havePermissionFromLandlord = Field(
    'havePermissionFromLandlord',
    _$havePermissionFromLandlord,
    key: r'have_permission_from_landlord',
  );
  static bool _$haveOutdoorSpace(Adoption v) => v.haveOutdoorSpace;
  static const Field<Adoption, bool> _f$haveOutdoorSpace = Field(
    'haveOutdoorSpace',
    _$haveOutdoorSpace,
    key: r'have_outdoor_space',
  );
  static int _$numberOfHouseholdMembers(Adoption v) =>
      v.numberOfHouseholdMembers;
  static const Field<Adoption, int> _f$numberOfHouseholdMembers = Field(
    'numberOfHouseholdMembers',
    _$numberOfHouseholdMembers,
    key: r'number_of_household_members',
  );
  static bool _$hasChildrenInHome(Adoption v) => v.hasChildrenInHome;
  static const Field<Adoption, bool> _f$hasChildrenInHome = Field(
    'hasChildrenInHome',
    _$hasChildrenInHome,
    key: r'has_children_in_home',
  );
  static bool _$hasOtherPetsInHome(Adoption v) => v.hasOtherPetsInHome;
  static const Field<Adoption, bool> _f$hasOtherPetsInHome = Field(
    'hasOtherPetsInHome',
    _$hasOtherPetsInHome,
    key: r'has_other_pets_in_home',
  );
  static String _$status(Adoption v) => v.status;
  static const Field<Adoption, String> _f$status = Field('status', _$status);
  static Pet _$pet(Adoption v) => v.pet;
  static const Field<Adoption, Pet> _f$pet = Field('pet', _$pet);

  @override
  final MappableFields<Adoption> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #user: _f$user,
    #typeOfResidence: _f$typeOfResidence,
    #isRenting: _f$isRenting,
    #havePermissionFromLandlord: _f$havePermissionFromLandlord,
    #haveOutdoorSpace: _f$haveOutdoorSpace,
    #numberOfHouseholdMembers: _f$numberOfHouseholdMembers,
    #hasChildrenInHome: _f$hasChildrenInHome,
    #hasOtherPetsInHome: _f$hasOtherPetsInHome,
    #status: _f$status,
    #pet: _f$pet,
  };

  static Adoption _instantiate(DecodingData data) {
    return Adoption(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      user: data.dec(_f$user),
      typeOfResidence: data.dec(_f$typeOfResidence),
      isRenting: data.dec(_f$isRenting),
      havePermissionFromLandlord: data.dec(_f$havePermissionFromLandlord),
      haveOutdoorSpace: data.dec(_f$haveOutdoorSpace),
      numberOfHouseholdMembers: data.dec(_f$numberOfHouseholdMembers),
      hasChildrenInHome: data.dec(_f$hasChildrenInHome),
      hasOtherPetsInHome: data.dec(_f$hasOtherPetsInHome),
      status: data.dec(_f$status),
      pet: data.dec(_f$pet),
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
  PetCopyWith<$R, Pet, Pet> get pet;
  $R call({
    int? id,
    DateTime? createdAt,
    String? user,
    String? typeOfResidence,
    bool? isRenting,
    bool? havePermissionFromLandlord,
    bool? haveOutdoorSpace,
    int? numberOfHouseholdMembers,
    bool? hasChildrenInHome,
    bool? hasOtherPetsInHome,
    String? status,
    Pet? pet,
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
  PetCopyWith<$R, Pet, Pet> get pet =>
      $value.pet.copyWith.$chain((v) => call(pet: v));
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? user,
    String? typeOfResidence,
    bool? isRenting,
    bool? havePermissionFromLandlord,
    bool? haveOutdoorSpace,
    int? numberOfHouseholdMembers,
    bool? hasChildrenInHome,
    bool? hasOtherPetsInHome,
    String? status,
    Pet? pet,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (user != null) #user: user,
      if (typeOfResidence != null) #typeOfResidence: typeOfResidence,
      if (isRenting != null) #isRenting: isRenting,
      if (havePermissionFromLandlord != null)
        #havePermissionFromLandlord: havePermissionFromLandlord,
      if (haveOutdoorSpace != null) #haveOutdoorSpace: haveOutdoorSpace,
      if (numberOfHouseholdMembers != null)
        #numberOfHouseholdMembers: numberOfHouseholdMembers,
      if (hasChildrenInHome != null) #hasChildrenInHome: hasChildrenInHome,
      if (hasOtherPetsInHome != null) #hasOtherPetsInHome: hasOtherPetsInHome,
      if (status != null) #status: status,
      if (pet != null) #pet: pet,
    }),
  );
  @override
  Adoption $make(CopyWithData data) => Adoption(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    user: data.get(#user, or: $value.user),
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
    pet: data.get(#pet, or: $value.pet),
  );

  @override
  AdoptionCopyWith<$R2, Adoption, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AdoptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

