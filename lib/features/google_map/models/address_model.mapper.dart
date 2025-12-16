// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'address_model.dart';

class AddressMapper extends ClassMapperBase<Address> {
  AddressMapper._();

  static AddressMapper? _instance;
  static AddressMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddressMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Address';

  static int _$id(Address v) => v.id;
  static const Field<Address, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(Address v) => v.createdAt;
  static const Field<Address, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$street(Address v) => v.street;
  static const Field<Address, String> _f$street = Field('street', _$street);
  static String _$city(Address v) => v.city;
  static const Field<Address, String> _f$city = Field('city', _$city);
  static String _$state(Address v) => v.state;
  static const Field<Address, String> _f$state = Field('state', _$state);
  static String _$country(Address v) => v.country;
  static const Field<Address, String> _f$country = Field('country', _$country);
  static String _$users(Address v) => v.users;
  static const Field<Address, String> _f$users = Field('users', _$users);
  static bool _$isDefault(Address v) => v.isDefault;
  static const Field<Address, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    key: r'is_default',
  );
  static String _$zipCode(Address v) => v.zipCode;
  static const Field<Address, String> _f$zipCode = Field(
    'zipCode',
    _$zipCode,
    key: r'zip_code',
  );
  static double? _$latitude(Address v) => v.latitude;
  static const Field<Address, double> _f$latitude = Field(
    'latitude',
    _$latitude,
  );
  static double? _$longitude(Address v) => v.longitude;
  static const Field<Address, double> _f$longitude = Field(
    'longitude',
    _$longitude,
  );

  @override
  final MappableFields<Address> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #street: _f$street,
    #city: _f$city,
    #state: _f$state,
    #country: _f$country,
    #users: _f$users,
    #isDefault: _f$isDefault,
    #zipCode: _f$zipCode,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
  };

  static Address _instantiate(DecodingData data) {
    return Address(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      street: data.dec(_f$street),
      city: data.dec(_f$city),
      state: data.dec(_f$state),
      country: data.dec(_f$country),
      users: data.dec(_f$users),
      isDefault: data.dec(_f$isDefault),
      zipCode: data.dec(_f$zipCode),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Address fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Address>(map);
  }

  static Address fromJson(String json) {
    return ensureInitialized().decodeJson<Address>(json);
  }
}

mixin AddressMappable {
  String toJson() {
    return AddressMapper.ensureInitialized().encodeJson<Address>(
      this as Address,
    );
  }

  Map<String, dynamic> toMap() {
    return AddressMapper.ensureInitialized().encodeMap<Address>(
      this as Address,
    );
  }

  AddressCopyWith<Address, Address, Address> get copyWith =>
      _AddressCopyWithImpl<Address, Address>(
        this as Address,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AddressMapper.ensureInitialized().stringifyValue(this as Address);
  }

  @override
  bool operator ==(Object other) {
    return AddressMapper.ensureInitialized().equalsValue(
      this as Address,
      other,
    );
  }

  @override
  int get hashCode {
    return AddressMapper.ensureInitialized().hashValue(this as Address);
  }
}

extension AddressValueCopy<$R, $Out> on ObjectCopyWith<$R, Address, $Out> {
  AddressCopyWith<$R, Address, $Out> get $asAddress =>
      $base.as((v, t, t2) => _AddressCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AddressCopyWith<$R, $In extends Address, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    DateTime? createdAt,
    String? street,
    String? city,
    String? state,
    String? country,
    String? users,
    bool? isDefault,
    String? zipCode,
    double? latitude,
    double? longitude,
  });
  AddressCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AddressCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Address, $Out>
    implements AddressCopyWith<$R, Address, $Out> {
  _AddressCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Address> $mapper =
      AddressMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? street,
    String? city,
    String? state,
    String? country,
    String? users,
    bool? isDefault,
    String? zipCode,
    Object? latitude = $none,
    Object? longitude = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (street != null) #street: street,
      if (city != null) #city: city,
      if (state != null) #state: state,
      if (country != null) #country: country,
      if (users != null) #users: users,
      if (isDefault != null) #isDefault: isDefault,
      if (zipCode != null) #zipCode: zipCode,
      if (latitude != $none) #latitude: latitude,
      if (longitude != $none) #longitude: longitude,
    }),
  );
  @override
  Address $make(CopyWithData data) => Address(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    street: data.get(#street, or: $value.street),
    city: data.get(#city, or: $value.city),
    state: data.get(#state, or: $value.state),
    country: data.get(#country, or: $value.country),
    users: data.get(#users, or: $value.users),
    isDefault: data.get(#isDefault, or: $value.isDefault),
    zipCode: data.get(#zipCode, or: $value.zipCode),
    latitude: data.get(#latitude, or: $value.latitude),
    longitude: data.get(#longitude, or: $value.longitude),
  );

  @override
  AddressCopyWith<$R2, Address, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddressCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

