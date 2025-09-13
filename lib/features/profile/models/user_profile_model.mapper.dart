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
  static String _$status(UserProfile v) => v.status;
  static const Field<UserProfile, String> _f$status = Field('status', _$status);
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
  $R call({
    String? id,
    String? createdAt,
    String? username,
    String? email,
    String? status,
    int? role,
    String? phoneNumber,
    List<String>? houseImages,
    String? paymongoId,
    String? paymentMethod,
    String? profileImageLink,
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
  $R call({
    String? id,
    String? createdAt,
    String? username,
    String? email,
    String? status,
    int? role,
    String? phoneNumber,
    Object? houseImages = $none,
    Object? paymongoId = $none,
    Object? paymentMethod = $none,
    Object? profileImageLink = $none,
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
  );

  @override
  UserProfileCopyWith<$R2, UserProfile, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

