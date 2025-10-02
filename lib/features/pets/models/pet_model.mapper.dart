// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pet_model.dart';

class PetMapper extends ClassMapperBase<Pet> {
  PetMapper._();

  static PetMapper? _instance;
  static PetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PetMapper._());
      PetAdoptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Pet';

  static int _$id(Pet v) => v.id;
  static const Field<Pet, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(Pet v) => v.createdAt;
  static const Field<Pet, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$name(Pet v) => v.name;
  static const Field<Pet, String> _f$name = Field('name', _$name);
  static String _$type(Pet v) => v.type;
  static const Field<Pet, String> _f$type = Field('type', _$type);
  static String _$breed(Pet v) => v.breed;
  static const Field<Pet, String> _f$breed = Field('breed', _$breed);
  static String _$gender(Pet v) => v.gender;
  static const Field<Pet, String> _f$gender = Field('gender', _$gender);
  static int _$age(Pet v) => v.age;
  static const Field<Pet, int> _f$age = Field('age', _$age);
  static DateTime _$dateOfBirth(Pet v) => v.dateOfBirth;
  static const Field<Pet, DateTime> _f$dateOfBirth = Field(
    'dateOfBirth',
    _$dateOfBirth,
    key: r'date_of_birth',
  );
  static String _$size(Pet v) => v.size;
  static const Field<Pet, String> _f$size = Field('size', _$size);
  static String _$weight(Pet v) => v.weight;
  static const Field<Pet, String> _f$weight = Field('weight', _$weight);
  static bool _$isVaccinated(Pet v) => v.isVaccinated;
  static const Field<Pet, bool> _f$isVaccinated = Field(
    'isVaccinated',
    _$isVaccinated,
    key: r'is_vaccinated',
  );
  static bool _$isSpayedOrNeutured(Pet v) => v.isSpayedOrNeutured;
  static const Field<Pet, bool> _f$isSpayedOrNeutured = Field(
    'isSpayedOrNeutured',
    _$isSpayedOrNeutured,
    key: r'is_spayed_or_neutured',
  );
  static String _$healthStatus(Pet v) => v.healthStatus;
  static const Field<Pet, String> _f$healthStatus = Field(
    'healthStatus',
    _$healthStatus,
    key: r'health_status',
  );
  static List<String> _$goodWith(Pet v) => v.goodWith;
  static const Field<Pet, List<String>> _f$goodWith = Field(
    'goodWith',
    _$goodWith,
    key: r'good_with',
  );
  static bool _$isTrained(Pet v) => v.isTrained;
  static const Field<Pet, bool> _f$isTrained = Field(
    'isTrained',
    _$isTrained,
    key: r'is_trained',
  );
  static String _$rescueAddress(Pet v) => v.rescueAddress;
  static const Field<Pet, String> _f$rescueAddress = Field(
    'rescueAddress',
    _$rescueAddress,
    key: r'rescue_address',
  );
  static String _$description(Pet v) => v.description;
  static const Field<Pet, String> _f$description = Field(
    'description',
    _$description,
  );
  static String _$specialNeeds(Pet v) => v.specialNeeds;
  static const Field<Pet, String> _f$specialNeeds = Field(
    'specialNeeds',
    _$specialNeeds,
    key: r'special_needs',
  );
  static String _$addedBy(Pet v) => v.addedBy;
  static const Field<Pet, String> _f$addedBy = Field(
    'addedBy',
    _$addedBy,
    key: r'added_by',
  );
  static String _$requestStatus(Pet v) => v.requestStatus;
  static const Field<Pet, String> _f$requestStatus = Field(
    'requestStatus',
    _$requestStatus,
    key: r'request_status',
  );
  static String _$photo(Pet v) => v.photo;
  static const Field<Pet, String> _f$photo = Field('photo', _$photo);
  static String? _$color(Pet v) => v.color;
  static const Field<Pet, String> _f$color = Field('color', _$color);
  static bool? _$isFavorite(Pet v) => v.isFavorite;
  static const Field<Pet, bool> _f$isFavorite = Field(
    'isFavorite',
    _$isFavorite,
    key: r'is_favorite',
    opt: true,
  );
  static List<PetAdoption>? _$adoption(Pet v) => v.adoption;
  static const Field<Pet, List<PetAdoption>> _f$adoption = Field(
    'adoption',
    _$adoption,
    opt: true,
  );
  static PetAdoption? _$adopted(Pet v) => v.adopted;
  static const Field<Pet, PetAdoption> _f$adopted = Field('adopted', _$adopted);

  @override
  final MappableFields<Pet> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #name: _f$name,
    #type: _f$type,
    #breed: _f$breed,
    #gender: _f$gender,
    #age: _f$age,
    #dateOfBirth: _f$dateOfBirth,
    #size: _f$size,
    #weight: _f$weight,
    #isVaccinated: _f$isVaccinated,
    #isSpayedOrNeutured: _f$isSpayedOrNeutured,
    #healthStatus: _f$healthStatus,
    #goodWith: _f$goodWith,
    #isTrained: _f$isTrained,
    #rescueAddress: _f$rescueAddress,
    #description: _f$description,
    #specialNeeds: _f$specialNeeds,
    #addedBy: _f$addedBy,
    #requestStatus: _f$requestStatus,
    #photo: _f$photo,
    #color: _f$color,
    #isFavorite: _f$isFavorite,
    #adoption: _f$adoption,
    #adopted: _f$adopted,
  };

  static Pet _instantiate(DecodingData data) {
    return Pet(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      name: data.dec(_f$name),
      type: data.dec(_f$type),
      breed: data.dec(_f$breed),
      gender: data.dec(_f$gender),
      age: data.dec(_f$age),
      dateOfBirth: data.dec(_f$dateOfBirth),
      size: data.dec(_f$size),
      weight: data.dec(_f$weight),
      isVaccinated: data.dec(_f$isVaccinated),
      isSpayedOrNeutured: data.dec(_f$isSpayedOrNeutured),
      healthStatus: data.dec(_f$healthStatus),
      goodWith: data.dec(_f$goodWith),
      isTrained: data.dec(_f$isTrained),
      rescueAddress: data.dec(_f$rescueAddress),
      description: data.dec(_f$description),
      specialNeeds: data.dec(_f$specialNeeds),
      addedBy: data.dec(_f$addedBy),
      requestStatus: data.dec(_f$requestStatus),
      photo: data.dec(_f$photo),
      color: data.dec(_f$color),
      isFavorite: data.dec(_f$isFavorite),
      adoption: data.dec(_f$adoption),
      adopted: data.dec(_f$adopted),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Pet fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Pet>(map);
  }

  static Pet fromJson(String json) {
    return ensureInitialized().decodeJson<Pet>(json);
  }
}

mixin PetMappable {
  String toJson() {
    return PetMapper.ensureInitialized().encodeJson<Pet>(this as Pet);
  }

  Map<String, dynamic> toMap() {
    return PetMapper.ensureInitialized().encodeMap<Pet>(this as Pet);
  }

  PetCopyWith<Pet, Pet, Pet> get copyWith =>
      _PetCopyWithImpl<Pet, Pet>(this as Pet, $identity, $identity);
  @override
  String toString() {
    return PetMapper.ensureInitialized().stringifyValue(this as Pet);
  }

  @override
  bool operator ==(Object other) {
    return PetMapper.ensureInitialized().equalsValue(this as Pet, other);
  }

  @override
  int get hashCode {
    return PetMapper.ensureInitialized().hashValue(this as Pet);
  }
}

extension PetValueCopy<$R, $Out> on ObjectCopyWith<$R, Pet, $Out> {
  PetCopyWith<$R, Pet, $Out> get $asPet =>
      $base.as((v, t, t2) => _PetCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PetCopyWith<$R, $In extends Pet, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get goodWith;
  ListCopyWith<
    $R,
    PetAdoption,
    PetAdoptionCopyWith<$R, PetAdoption, PetAdoption>
  >?
  get adoption;
  PetAdoptionCopyWith<$R, PetAdoption, PetAdoption>? get adopted;
  $R call({
    int? id,
    DateTime? createdAt,
    String? name,
    String? type,
    String? breed,
    String? gender,
    int? age,
    DateTime? dateOfBirth,
    String? size,
    String? weight,
    bool? isVaccinated,
    bool? isSpayedOrNeutured,
    String? healthStatus,
    List<String>? goodWith,
    bool? isTrained,
    String? rescueAddress,
    String? description,
    String? specialNeeds,
    String? addedBy,
    String? requestStatus,
    String? photo,
    String? color,
    bool? isFavorite,
    List<PetAdoption>? adoption,
    PetAdoption? adopted,
  });
  PetCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PetCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Pet, $Out>
    implements PetCopyWith<$R, Pet, $Out> {
  _PetCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Pet> $mapper = PetMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get goodWith =>
      ListCopyWith(
        $value.goodWith,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(goodWith: v),
      );
  @override
  ListCopyWith<
    $R,
    PetAdoption,
    PetAdoptionCopyWith<$R, PetAdoption, PetAdoption>
  >?
  get adoption => $value.adoption != null
      ? ListCopyWith(
          $value.adoption!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(adoption: v),
        )
      : null;
  @override
  PetAdoptionCopyWith<$R, PetAdoption, PetAdoption>? get adopted =>
      $value.adopted?.copyWith.$chain((v) => call(adopted: v));
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? name,
    String? type,
    String? breed,
    String? gender,
    int? age,
    DateTime? dateOfBirth,
    String? size,
    String? weight,
    bool? isVaccinated,
    bool? isSpayedOrNeutured,
    String? healthStatus,
    List<String>? goodWith,
    bool? isTrained,
    String? rescueAddress,
    String? description,
    String? specialNeeds,
    String? addedBy,
    String? requestStatus,
    String? photo,
    Object? color = $none,
    Object? isFavorite = $none,
    Object? adoption = $none,
    Object? adopted = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (name != null) #name: name,
      if (type != null) #type: type,
      if (breed != null) #breed: breed,
      if (gender != null) #gender: gender,
      if (age != null) #age: age,
      if (dateOfBirth != null) #dateOfBirth: dateOfBirth,
      if (size != null) #size: size,
      if (weight != null) #weight: weight,
      if (isVaccinated != null) #isVaccinated: isVaccinated,
      if (isSpayedOrNeutured != null) #isSpayedOrNeutured: isSpayedOrNeutured,
      if (healthStatus != null) #healthStatus: healthStatus,
      if (goodWith != null) #goodWith: goodWith,
      if (isTrained != null) #isTrained: isTrained,
      if (rescueAddress != null) #rescueAddress: rescueAddress,
      if (description != null) #description: description,
      if (specialNeeds != null) #specialNeeds: specialNeeds,
      if (addedBy != null) #addedBy: addedBy,
      if (requestStatus != null) #requestStatus: requestStatus,
      if (photo != null) #photo: photo,
      if (color != $none) #color: color,
      if (isFavorite != $none) #isFavorite: isFavorite,
      if (adoption != $none) #adoption: adoption,
      if (adopted != $none) #adopted: adopted,
    }),
  );
  @override
  Pet $make(CopyWithData data) => Pet(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    name: data.get(#name, or: $value.name),
    type: data.get(#type, or: $value.type),
    breed: data.get(#breed, or: $value.breed),
    gender: data.get(#gender, or: $value.gender),
    age: data.get(#age, or: $value.age),
    dateOfBirth: data.get(#dateOfBirth, or: $value.dateOfBirth),
    size: data.get(#size, or: $value.size),
    weight: data.get(#weight, or: $value.weight),
    isVaccinated: data.get(#isVaccinated, or: $value.isVaccinated),
    isSpayedOrNeutured: data.get(
      #isSpayedOrNeutured,
      or: $value.isSpayedOrNeutured,
    ),
    healthStatus: data.get(#healthStatus, or: $value.healthStatus),
    goodWith: data.get(#goodWith, or: $value.goodWith),
    isTrained: data.get(#isTrained, or: $value.isTrained),
    rescueAddress: data.get(#rescueAddress, or: $value.rescueAddress),
    description: data.get(#description, or: $value.description),
    specialNeeds: data.get(#specialNeeds, or: $value.specialNeeds),
    addedBy: data.get(#addedBy, or: $value.addedBy),
    requestStatus: data.get(#requestStatus, or: $value.requestStatus),
    photo: data.get(#photo, or: $value.photo),
    color: data.get(#color, or: $value.color),
    isFavorite: data.get(#isFavorite, or: $value.isFavorite),
    adoption: data.get(#adoption, or: $value.adoption),
    adopted: data.get(#adopted, or: $value.adopted),
  );

  @override
  PetCopyWith<$R2, Pet, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PetCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PetAdoptionMapper extends ClassMapperBase<PetAdoption> {
  PetAdoptionMapper._();

  static PetAdoptionMapper? _instance;
  static PetAdoptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PetAdoptionMapper._());
      UserProfileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PetAdoption';

  static int _$id(PetAdoption v) => v.id;
  static const Field<PetAdoption, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(PetAdoption v) => v.createdAt;
  static const Field<PetAdoption, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static UserProfile _$user(PetAdoption v) => v.user;
  static const Field<PetAdoption, UserProfile> _f$user = Field('user', _$user);
  static String _$status(PetAdoption v) => v.status;
  static const Field<PetAdoption, String> _f$status = Field('status', _$status);

  @override
  final MappableFields<PetAdoption> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #user: _f$user,
    #status: _f$status,
  };

  static PetAdoption _instantiate(DecodingData data) {
    return PetAdoption(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      user: data.dec(_f$user),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PetAdoption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PetAdoption>(map);
  }

  static PetAdoption fromJson(String json) {
    return ensureInitialized().decodeJson<PetAdoption>(json);
  }
}

mixin PetAdoptionMappable {
  String toJson() {
    return PetAdoptionMapper.ensureInitialized().encodeJson<PetAdoption>(
      this as PetAdoption,
    );
  }

  Map<String, dynamic> toMap() {
    return PetAdoptionMapper.ensureInitialized().encodeMap<PetAdoption>(
      this as PetAdoption,
    );
  }

  PetAdoptionCopyWith<PetAdoption, PetAdoption, PetAdoption> get copyWith =>
      _PetAdoptionCopyWithImpl<PetAdoption, PetAdoption>(
        this as PetAdoption,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PetAdoptionMapper.ensureInitialized().stringifyValue(
      this as PetAdoption,
    );
  }

  @override
  bool operator ==(Object other) {
    return PetAdoptionMapper.ensureInitialized().equalsValue(
      this as PetAdoption,
      other,
    );
  }

  @override
  int get hashCode {
    return PetAdoptionMapper.ensureInitialized().hashValue(this as PetAdoption);
  }
}

extension PetAdoptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PetAdoption, $Out> {
  PetAdoptionCopyWith<$R, PetAdoption, $Out> get $asPetAdoption =>
      $base.as((v, t, t2) => _PetAdoptionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PetAdoptionCopyWith<$R, $In extends PetAdoption, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  UserProfileCopyWith<$R, UserProfile, UserProfile> get user;
  $R call({int? id, DateTime? createdAt, UserProfile? user, String? status});
  PetAdoptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PetAdoptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PetAdoption, $Out>
    implements PetAdoptionCopyWith<$R, PetAdoption, $Out> {
  _PetAdoptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PetAdoption> $mapper =
      PetAdoptionMapper.ensureInitialized();
  @override
  UserProfileCopyWith<$R, UserProfile, UserProfile> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  $R call({int? id, DateTime? createdAt, UserProfile? user, String? status}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (createdAt != null) #createdAt: createdAt,
          if (user != null) #user: user,
          if (status != null) #status: status,
        }),
      );
  @override
  PetAdoption $make(CopyWithData data) => PetAdoption(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    user: data.get(#user, or: $value.user),
    status: data.get(#status, or: $value.status),
  );

  @override
  PetAdoptionCopyWith<$R2, PetAdoption, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PetAdoptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

