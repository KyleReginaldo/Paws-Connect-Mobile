// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_profile_model.dart';

class UserProfileMapper extends ClassMapperBase<UserProfile> {
  UserProfileMapper._();

  static UserProfileMapper? _instance;
  static UserProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserProfileMapper._());
      UserStatusMapper.ensureInitialized();
      UserIdentificationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UserProfile';

  static String _$id(UserProfile v) => v.id;
  static const Field<UserProfile, String> _f$id = Field('id', _$id);
  static String _$createdAt(UserProfile v) => v.createdAt;
  static const Field<UserProfile, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$username(UserProfile v) => v.username;
  static const Field<UserProfile, String> _f$username = Field(
    'username',
    _$username,
  );
  static String _$email(UserProfile v) => v.email;
  static const Field<UserProfile, String> _f$email = Field('email', _$email);
  static UserStatus _$status(UserProfile v) => v.status;
  static const Field<UserProfile, UserStatus> _f$status = Field(
    'status',
    _$status,
  );
  static int _$role(UserProfile v) => v.role;
  static const Field<UserProfile, int> _f$role = Field('role', _$role);
  static String _$phoneNumber(UserProfile v) => v.phoneNumber;
  static const Field<UserProfile, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    key: r'phone_number',
  );
  static List<String>? _$houseImages(UserProfile v) => v.houseImages;
  static const Field<UserProfile, List<String>> _f$houseImages = Field(
    'houseImages',
    _$houseImages,
    key: r'house_images',
    opt: true,
  );
  static String? _$paymongoId(UserProfile v) => v.paymongoId;
  static const Field<UserProfile, String> _f$paymongoId = Field(
    'paymongoId',
    _$paymongoId,
    key: r'paymongo_id',
    opt: true,
  );
  static String? _$paymentMethod(UserProfile v) => v.paymentMethod;
  static const Field<UserProfile, String> _f$paymentMethod = Field(
    'paymentMethod',
    _$paymentMethod,
    key: r'payment_method',
    opt: true,
  );
  static String? _$profileImageLink(UserProfile v) => v.profileImageLink;
  static const Field<UserProfile, String> _f$profileImageLink = Field(
    'profileImageLink',
    _$profileImageLink,
    key: r'profile_image_link',
    opt: true,
  );
  static String? _$createdBy(UserProfile v) => v.createdBy;
  static const Field<UserProfile, String> _f$createdBy = Field(
    'createdBy',
    _$createdBy,
    key: r'created_by',
    opt: true,
  );
  static bool? _$passwordChanged(UserProfile v) => v.passwordChanged;
  static const Field<UserProfile, bool> _f$passwordChanged = Field(
    'passwordChanged',
    _$passwordChanged,
    key: r'password_changed',
    opt: true,
  );
  static UserIdentification? _$userIdentification(UserProfile v) =>
      v.userIdentification;
  static const Field<UserProfile, UserIdentification> _f$userIdentification =
      Field(
        'userIdentification',
        _$userIdentification,
        key: r'user_identification',
        opt: true,
      );
  static bool? _$isActive(UserProfile v) => v.isActive;
  static const Field<UserProfile, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    key: r'is_active',
    opt: true,
  );
  static DateTime? _$lastActiveAt(UserProfile v) => v.lastActiveAt;
  static const Field<UserProfile, DateTime> _f$lastActiveAt = Field(
    'lastActiveAt',
    _$lastActiveAt,
    key: r'last_active_at',
    opt: true,
  );
  static List<String>? _$violations(UserProfile v) => v.violations;
  static const Field<UserProfile, List<String>> _f$violations = Field(
    'violations',
    _$violations,
    opt: true,
  );
  static bool _$onboarded(UserProfile v) => v.onboarded;
  static const Field<UserProfile, bool> _f$onboarded = Field(
    'onboarded',
    _$onboarded,
  );
  static String? _$transformedIdAttachmentUrl(UserProfile v) =>
      v.transformedIdAttachmentUrl;
  static const Field<UserProfile, String> _f$transformedIdAttachmentUrl = Field(
    'transformedIdAttachmentUrl',
    _$transformedIdAttachmentUrl,
    key: r'transformed_id_attachment_url',
    mode: FieldMode.member,
  );
  static List<String>? _$transformedHouseImages(UserProfile v) =>
      v.transformedHouseImages;
  static const Field<UserProfile, List<String>> _f$transformedHouseImages =
      Field(
        'transformedHouseImages',
        _$transformedHouseImages,
        key: r'transformed_house_images',
        mode: FieldMode.member,
      );

  @override
  final MappableFields<UserProfile> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #username: _f$username,
    #email: _f$email,
    #status: _f$status,
    #role: _f$role,
    #phoneNumber: _f$phoneNumber,
    #houseImages: _f$houseImages,
    #paymongoId: _f$paymongoId,
    #paymentMethod: _f$paymentMethod,
    #profileImageLink: _f$profileImageLink,
    #createdBy: _f$createdBy,
    #passwordChanged: _f$passwordChanged,
    #userIdentification: _f$userIdentification,
    #isActive: _f$isActive,
    #lastActiveAt: _f$lastActiveAt,
    #violations: _f$violations,
    #onboarded: _f$onboarded,
    #transformedIdAttachmentUrl: _f$transformedIdAttachmentUrl,
    #transformedHouseImages: _f$transformedHouseImages,
  };

  static UserProfile _instantiate(DecodingData data) {
    return UserProfile(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      username: data.dec(_f$username),
      email: data.dec(_f$email),
      status: data.dec(_f$status),
      role: data.dec(_f$role),
      phoneNumber: data.dec(_f$phoneNumber),
      houseImages: data.dec(_f$houseImages),
      paymongoId: data.dec(_f$paymongoId),
      paymentMethod: data.dec(_f$paymentMethod),
      profileImageLink: data.dec(_f$profileImageLink),
      createdBy: data.dec(_f$createdBy),
      passwordChanged: data.dec(_f$passwordChanged),
      userIdentification: data.dec(_f$userIdentification),
      isActive: data.dec(_f$isActive),
      lastActiveAt: data.dec(_f$lastActiveAt),
      violations: data.dec(_f$violations),
      onboarded: data.dec(_f$onboarded),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserProfile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserProfile>(map);
  }

  static UserProfile fromJson(String json) {
    return ensureInitialized().decodeJson<UserProfile>(json);
  }
}

mixin UserProfileMappable {
  String toJson() {
    return UserProfileMapper.ensureInitialized().encodeJson<UserProfile>(
      this as UserProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return UserProfileMapper.ensureInitialized().encodeMap<UserProfile>(
      this as UserProfile,
    );
  }

  UserProfileCopyWith<UserProfile, UserProfile, UserProfile> get copyWith =>
      _UserProfileCopyWithImpl<UserProfile, UserProfile>(
        this as UserProfile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserProfileMapper.ensureInitialized().stringifyValue(
      this as UserProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    return UserProfileMapper.ensureInitialized().equalsValue(
      this as UserProfile,
      other,
    );
  }

  @override
  int get hashCode {
    return UserProfileMapper.ensureInitialized().hashValue(this as UserProfile);
  }
}

extension UserProfileValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserProfile, $Out> {
  UserProfileCopyWith<$R, UserProfile, $Out> get $asUserProfile =>
      $base.as((v, t, t2) => _UserProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserProfileCopyWith<$R, $In extends UserProfile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get houseImages;
  UserIdentificationCopyWith<$R, UserIdentification, UserIdentification>?
  get userIdentification;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get violations;
  $R call({
    String? id,
    String? createdAt,
    String? username,
    String? email,
    UserStatus? status,
    int? role,
    String? phoneNumber,
    List<String>? houseImages,
    String? paymongoId,
    String? paymentMethod,
    String? profileImageLink,
    String? createdBy,
    bool? passwordChanged,
    UserIdentification? userIdentification,
    bool? isActive,
    DateTime? lastActiveAt,
    List<String>? violations,
    bool? onboarded,
  });
  UserProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserProfile, $Out>
    implements UserProfileCopyWith<$R, UserProfile, $Out> {
  _UserProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserProfile> $mapper =
      UserProfileMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get houseImages => $value.houseImages != null
      ? ListCopyWith(
          $value.houseImages!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(houseImages: v),
        )
      : null;
  @override
  UserIdentificationCopyWith<$R, UserIdentification, UserIdentification>?
  get userIdentification => $value.userIdentification?.copyWith.$chain(
    (v) => call(userIdentification: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get violations => $value.violations != null
      ? ListCopyWith(
          $value.violations!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(violations: v),
        )
      : null;
  @override
  $R call({
    String? id,
    String? createdAt,
    String? username,
    String? email,
    UserStatus? status,
    int? role,
    String? phoneNumber,
    Object? houseImages = $none,
    Object? paymongoId = $none,
    Object? paymentMethod = $none,
    Object? profileImageLink = $none,
    Object? createdBy = $none,
    Object? passwordChanged = $none,
    Object? userIdentification = $none,
    Object? isActive = $none,
    Object? lastActiveAt = $none,
    Object? violations = $none,
    bool? onboarded,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (username != null) #username: username,
      if (email != null) #email: email,
      if (status != null) #status: status,
      if (role != null) #role: role,
      if (phoneNumber != null) #phoneNumber: phoneNumber,
      if (houseImages != $none) #houseImages: houseImages,
      if (paymongoId != $none) #paymongoId: paymongoId,
      if (paymentMethod != $none) #paymentMethod: paymentMethod,
      if (profileImageLink != $none) #profileImageLink: profileImageLink,
      if (createdBy != $none) #createdBy: createdBy,
      if (passwordChanged != $none) #passwordChanged: passwordChanged,
      if (userIdentification != $none) #userIdentification: userIdentification,
      if (isActive != $none) #isActive: isActive,
      if (lastActiveAt != $none) #lastActiveAt: lastActiveAt,
      if (violations != $none) #violations: violations,
      if (onboarded != null) #onboarded: onboarded,
    }),
  );
  @override
  UserProfile $make(CopyWithData data) => UserProfile(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    username: data.get(#username, or: $value.username),
    email: data.get(#email, or: $value.email),
    status: data.get(#status, or: $value.status),
    role: data.get(#role, or: $value.role),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
    houseImages: data.get(#houseImages, or: $value.houseImages),
    paymongoId: data.get(#paymongoId, or: $value.paymongoId),
    paymentMethod: data.get(#paymentMethod, or: $value.paymentMethod),
    profileImageLink: data.get(#profileImageLink, or: $value.profileImageLink),
    createdBy: data.get(#createdBy, or: $value.createdBy),
    passwordChanged: data.get(#passwordChanged, or: $value.passwordChanged),
    userIdentification: data.get(
      #userIdentification,
      or: $value.userIdentification,
    ),
    isActive: data.get(#isActive, or: $value.isActive),
    lastActiveAt: data.get(#lastActiveAt, or: $value.lastActiveAt),
    violations: data.get(#violations, or: $value.violations),
    onboarded: data.get(#onboarded, or: $value.onboarded),
  );

  @override
  UserProfileCopyWith<$R2, UserProfile, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UserIdentificationMapper extends ClassMapperBase<UserIdentification> {
  UserIdentificationMapper._();

  static UserIdentificationMapper? _instance;
  static UserIdentificationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserIdentificationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserIdentification';

  static int _$id(UserIdentification v) => v.id;
  static const Field<UserIdentification, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(UserIdentification v) => v.createdAt;
  static const Field<UserIdentification, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$idAttachmentUrl(UserIdentification v) => v.idAttachmentUrl;
  static const Field<UserIdentification, String> _f$idAttachmentUrl = Field(
    'idAttachmentUrl',
    _$idAttachmentUrl,
    key: r'id_attachment_url',
  );
  static String _$firstName(UserIdentification v) => v.firstName;
  static const Field<UserIdentification, String> _f$firstName = Field(
    'firstName',
    _$firstName,
    key: r'first_name',
  );
  static String _$lastName(UserIdentification v) => v.lastName;
  static const Field<UserIdentification, String> _f$lastName = Field(
    'lastName',
    _$lastName,
    key: r'last_name',
  );
  static String? _$middleInitial(UserIdentification v) => v.middleInitial;
  static const Field<UserIdentification, String> _f$middleInitial = Field(
    'middleInitial',
    _$middleInitial,
    key: r'middle_initial',
  );
  static String? _$address(UserIdentification v) => v.address;
  static const Field<UserIdentification, String> _f$address = Field(
    'address',
    _$address,
  );
  static String? _$dateOfBirth(UserIdentification v) => v.dateOfBirth;
  static const Field<UserIdentification, String> _f$dateOfBirth = Field(
    'dateOfBirth',
    _$dateOfBirth,
    key: r'date_of_birth',
  );
  static String? _$idType(UserIdentification v) => v.idType;
  static const Field<UserIdentification, String> _f$idType = Field(
    'idType',
    _$idType,
    key: r'id_type',
  );
  static String _$status(UserIdentification v) => v.status;
  static const Field<UserIdentification, String> _f$status = Field(
    'status',
    _$status,
  );
  static String _$transformedIdAttachmentUrl(UserIdentification v) =>
      v.transformedIdAttachmentUrl;
  static const Field<UserIdentification, String> _f$transformedIdAttachmentUrl =
      Field(
        'transformedIdAttachmentUrl',
        _$transformedIdAttachmentUrl,
        key: r'transformed_id_attachment_url',
        mode: FieldMode.member,
      );

  @override
  final MappableFields<UserIdentification> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #idAttachmentUrl: _f$idAttachmentUrl,
    #firstName: _f$firstName,
    #lastName: _f$lastName,
    #middleInitial: _f$middleInitial,
    #address: _f$address,
    #dateOfBirth: _f$dateOfBirth,
    #idType: _f$idType,
    #status: _f$status,
    #transformedIdAttachmentUrl: _f$transformedIdAttachmentUrl,
  };

  static UserIdentification _instantiate(DecodingData data) {
    return UserIdentification(
      data.dec(_f$id),
      data.dec(_f$createdAt),
      data.dec(_f$idAttachmentUrl),
      data.dec(_f$firstName),
      data.dec(_f$lastName),
      data.dec(_f$middleInitial),
      data.dec(_f$address),
      data.dec(_f$dateOfBirth),
      data.dec(_f$idType),
      data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserIdentification fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserIdentification>(map);
  }

  static UserIdentification fromJson(String json) {
    return ensureInitialized().decodeJson<UserIdentification>(json);
  }
}

mixin UserIdentificationMappable {
  String toJson() {
    return UserIdentificationMapper.ensureInitialized()
        .encodeJson<UserIdentification>(this as UserIdentification);
  }

  Map<String, dynamic> toMap() {
    return UserIdentificationMapper.ensureInitialized()
        .encodeMap<UserIdentification>(this as UserIdentification);
  }

  UserIdentificationCopyWith<
    UserIdentification,
    UserIdentification,
    UserIdentification
  >
  get copyWith =>
      _UserIdentificationCopyWithImpl<UserIdentification, UserIdentification>(
        this as UserIdentification,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserIdentificationMapper.ensureInitialized().stringifyValue(
      this as UserIdentification,
    );
  }

  @override
  bool operator ==(Object other) {
    return UserIdentificationMapper.ensureInitialized().equalsValue(
      this as UserIdentification,
      other,
    );
  }

  @override
  int get hashCode {
    return UserIdentificationMapper.ensureInitialized().hashValue(
      this as UserIdentification,
    );
  }
}

extension UserIdentificationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserIdentification, $Out> {
  UserIdentificationCopyWith<$R, UserIdentification, $Out>
  get $asUserIdentification => $base.as(
    (v, t, t2) => _UserIdentificationCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UserIdentificationCopyWith<
  $R,
  $In extends UserIdentification,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    DateTime? createdAt,
    String? idAttachmentUrl,
    String? firstName,
    String? lastName,
    String? middleInitial,
    String? address,
    String? dateOfBirth,
    String? idType,
    String? status,
  });
  UserIdentificationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UserIdentificationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserIdentification, $Out>
    implements UserIdentificationCopyWith<$R, UserIdentification, $Out> {
  _UserIdentificationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserIdentification> $mapper =
      UserIdentificationMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? idAttachmentUrl,
    String? firstName,
    String? lastName,
    Object? middleInitial = $none,
    Object? address = $none,
    Object? dateOfBirth = $none,
    Object? idType = $none,
    String? status,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (idAttachmentUrl != null) #idAttachmentUrl: idAttachmentUrl,
      if (firstName != null) #firstName: firstName,
      if (lastName != null) #lastName: lastName,
      if (middleInitial != $none) #middleInitial: middleInitial,
      if (address != $none) #address: address,
      if (dateOfBirth != $none) #dateOfBirth: dateOfBirth,
      if (idType != $none) #idType: idType,
      if (status != null) #status: status,
    }),
  );
  @override
  UserIdentification $make(CopyWithData data) => UserIdentification(
    data.get(#id, or: $value.id),
    data.get(#createdAt, or: $value.createdAt),
    data.get(#idAttachmentUrl, or: $value.idAttachmentUrl),
    data.get(#firstName, or: $value.firstName),
    data.get(#lastName, or: $value.lastName),
    data.get(#middleInitial, or: $value.middleInitial),
    data.get(#address, or: $value.address),
    data.get(#dateOfBirth, or: $value.dateOfBirth),
    data.get(#idType, or: $value.idType),
    data.get(#status, or: $value.status),
  );

  @override
  UserIdentificationCopyWith<$R2, UserIdentification, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserIdentificationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

