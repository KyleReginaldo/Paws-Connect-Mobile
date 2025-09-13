// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_method_model.dart';

class PaymentMethodMapper extends ClassMapperBase<PaymentMethod> {
  PaymentMethodMapper._();

  static PaymentMethodMapper? _instance;
  static PaymentMethodMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentMethodMapper._());
      AttributesMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PaymentMethod';

  static String _$id(PaymentMethod v) => v.id;
  static const Field<PaymentMethod, String> _f$id = Field('id', _$id);
  static String _$type(PaymentMethod v) => v.type;
  static const Field<PaymentMethod, String> _f$type = Field('type', _$type);
  static Attributes _$attributes(PaymentMethod v) => v.attributes;
  static const Field<PaymentMethod, Attributes> _f$attributes = Field(
    'attributes',
    _$attributes,
  );

  @override
  final MappableFields<PaymentMethod> fields = const {
    #id: _f$id,
    #type: _f$type,
    #attributes: _f$attributes,
  };

  static PaymentMethod _instantiate(DecodingData data) {
    return PaymentMethod(
      id: data.dec(_f$id),
      type: data.dec(_f$type),
      attributes: data.dec(_f$attributes),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PaymentMethod fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PaymentMethod>(map);
  }

  static PaymentMethod fromJson(String json) {
    return ensureInitialized().decodeJson<PaymentMethod>(json);
  }
}

mixin PaymentMethodMappable {
  String toJson() {
    return PaymentMethodMapper.ensureInitialized().encodeJson<PaymentMethod>(
      this as PaymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return PaymentMethodMapper.ensureInitialized().encodeMap<PaymentMethod>(
      this as PaymentMethod,
    );
  }

  PaymentMethodCopyWith<PaymentMethod, PaymentMethod, PaymentMethod>
  get copyWith => _PaymentMethodCopyWithImpl<PaymentMethod, PaymentMethod>(
    this as PaymentMethod,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PaymentMethodMapper.ensureInitialized().stringifyValue(
      this as PaymentMethod,
    );
  }

  @override
  bool operator ==(Object other) {
    return PaymentMethodMapper.ensureInitialized().equalsValue(
      this as PaymentMethod,
      other,
    );
  }

  @override
  int get hashCode {
    return PaymentMethodMapper.ensureInitialized().hashValue(
      this as PaymentMethod,
    );
  }
}

extension PaymentMethodValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PaymentMethod, $Out> {
  PaymentMethodCopyWith<$R, PaymentMethod, $Out> get $asPaymentMethod =>
      $base.as((v, t, t2) => _PaymentMethodCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PaymentMethodCopyWith<$R, $In extends PaymentMethod, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  AttributesCopyWith<$R, Attributes, Attributes> get attributes;
  $R call({String? id, String? type, Attributes? attributes});
  PaymentMethodCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PaymentMethodCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PaymentMethod, $Out>
    implements PaymentMethodCopyWith<$R, PaymentMethod, $Out> {
  _PaymentMethodCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PaymentMethod> $mapper =
      PaymentMethodMapper.ensureInitialized();
  @override
  AttributesCopyWith<$R, Attributes, Attributes> get attributes =>
      $value.attributes.copyWith.$chain((v) => call(attributes: v));
  @override
  $R call({String? id, String? type, Attributes? attributes}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (type != null) #type: type,
      if (attributes != null) #attributes: attributes,
    }),
  );
  @override
  PaymentMethod $make(CopyWithData data) => PaymentMethod(
    id: data.get(#id, or: $value.id),
    type: data.get(#type, or: $value.type),
    attributes: data.get(#attributes, or: $value.attributes),
  );

  @override
  PaymentMethodCopyWith<$R2, PaymentMethod, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PaymentMethodCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AttributesMapper extends ClassMapperBase<Attributes> {
  AttributesMapper._();

  static AttributesMapper? _instance;
  static AttributesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AttributesMapper._());
      BillingMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Attributes';

  static bool _$livemode(Attributes v) => v.livemode;
  static const Field<Attributes, bool> _f$livemode = Field(
    'livemode',
    _$livemode,
  );
  static String _$type(Attributes v) => v.type;
  static const Field<Attributes, String> _f$type = Field('type', _$type);
  static Billing _$billing(Attributes v) => v.billing;
  static const Field<Attributes, Billing> _f$billing = Field(
    'billing',
    _$billing,
  );
  static int _$createdAt(Attributes v) => v.createdAt;
  static const Field<Attributes, int> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static int _$updatedAt(Attributes v) => v.updatedAt;
  static const Field<Attributes, int> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );
  static dynamic _$details(Attributes v) => v.details;
  static const Field<Attributes, dynamic> _f$details = Field(
    'details',
    _$details,
  );
  static dynamic _$metadata(Attributes v) => v.metadata;
  static const Field<Attributes, dynamic> _f$metadata = Field(
    'metadata',
    _$metadata,
  );

  @override
  final MappableFields<Attributes> fields = const {
    #livemode: _f$livemode,
    #type: _f$type,
    #billing: _f$billing,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #details: _f$details,
    #metadata: _f$metadata,
  };

  static Attributes _instantiate(DecodingData data) {
    return Attributes(
      livemode: data.dec(_f$livemode),
      type: data.dec(_f$type),
      billing: data.dec(_f$billing),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      details: data.dec(_f$details),
      metadata: data.dec(_f$metadata),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Attributes fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Attributes>(map);
  }

  static Attributes fromJson(String json) {
    return ensureInitialized().decodeJson<Attributes>(json);
  }
}

mixin AttributesMappable {
  String toJson() {
    return AttributesMapper.ensureInitialized().encodeJson<Attributes>(
      this as Attributes,
    );
  }

  Map<String, dynamic> toMap() {
    return AttributesMapper.ensureInitialized().encodeMap<Attributes>(
      this as Attributes,
    );
  }

  AttributesCopyWith<Attributes, Attributes, Attributes> get copyWith =>
      _AttributesCopyWithImpl<Attributes, Attributes>(
        this as Attributes,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AttributesMapper.ensureInitialized().stringifyValue(
      this as Attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    return AttributesMapper.ensureInitialized().equalsValue(
      this as Attributes,
      other,
    );
  }

  @override
  int get hashCode {
    return AttributesMapper.ensureInitialized().hashValue(this as Attributes);
  }
}

extension AttributesValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Attributes, $Out> {
  AttributesCopyWith<$R, Attributes, $Out> get $asAttributes =>
      $base.as((v, t, t2) => _AttributesCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AttributesCopyWith<$R, $In extends Attributes, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  BillingCopyWith<$R, Billing, Billing> get billing;
  $R call({
    bool? livemode,
    String? type,
    Billing? billing,
    int? createdAt,
    int? updatedAt,
    dynamic details,
    dynamic metadata,
  });
  AttributesCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AttributesCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Attributes, $Out>
    implements AttributesCopyWith<$R, Attributes, $Out> {
  _AttributesCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Attributes> $mapper =
      AttributesMapper.ensureInitialized();
  @override
  BillingCopyWith<$R, Billing, Billing> get billing =>
      $value.billing.copyWith.$chain((v) => call(billing: v));
  @override
  $R call({
    bool? livemode,
    String? type,
    Billing? billing,
    int? createdAt,
    int? updatedAt,
    Object? details = $none,
    Object? metadata = $none,
  }) => $apply(
    FieldCopyWithData({
      if (livemode != null) #livemode: livemode,
      if (type != null) #type: type,
      if (billing != null) #billing: billing,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
      if (details != $none) #details: details,
      if (metadata != $none) #metadata: metadata,
    }),
  );
  @override
  Attributes $make(CopyWithData data) => Attributes(
    livemode: data.get(#livemode, or: $value.livemode),
    type: data.get(#type, or: $value.type),
    billing: data.get(#billing, or: $value.billing),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    details: data.get(#details, or: $value.details),
    metadata: data.get(#metadata, or: $value.metadata),
  );

  @override
  AttributesCopyWith<$R2, Attributes, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AttributesCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BillingMapper extends ClassMapperBase<Billing> {
  BillingMapper._();

  static BillingMapper? _instance;
  static BillingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BillingMapper._());
      AddressMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Billing';

  static Address _$address(Billing v) => v.address;
  static const Field<Billing, Address> _f$address = Field('address', _$address);
  static String _$email(Billing v) => v.email;
  static const Field<Billing, String> _f$email = Field('email', _$email);
  static String _$name(Billing v) => v.name;
  static const Field<Billing, String> _f$name = Field('name', _$name);
  static String _$phone(Billing v) => v.phone;
  static const Field<Billing, String> _f$phone = Field('phone', _$phone);

  @override
  final MappableFields<Billing> fields = const {
    #address: _f$address,
    #email: _f$email,
    #name: _f$name,
    #phone: _f$phone,
  };

  static Billing _instantiate(DecodingData data) {
    return Billing(
      address: data.dec(_f$address),
      email: data.dec(_f$email),
      name: data.dec(_f$name),
      phone: data.dec(_f$phone),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Billing fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Billing>(map);
  }

  static Billing fromJson(String json) {
    return ensureInitialized().decodeJson<Billing>(json);
  }
}

mixin BillingMappable {
  String toJson() {
    return BillingMapper.ensureInitialized().encodeJson<Billing>(
      this as Billing,
    );
  }

  Map<String, dynamic> toMap() {
    return BillingMapper.ensureInitialized().encodeMap<Billing>(
      this as Billing,
    );
  }

  BillingCopyWith<Billing, Billing, Billing> get copyWith =>
      _BillingCopyWithImpl<Billing, Billing>(
        this as Billing,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BillingMapper.ensureInitialized().stringifyValue(this as Billing);
  }

  @override
  bool operator ==(Object other) {
    return BillingMapper.ensureInitialized().equalsValue(
      this as Billing,
      other,
    );
  }

  @override
  int get hashCode {
    return BillingMapper.ensureInitialized().hashValue(this as Billing);
  }
}

extension BillingValueCopy<$R, $Out> on ObjectCopyWith<$R, Billing, $Out> {
  BillingCopyWith<$R, Billing, $Out> get $asBilling =>
      $base.as((v, t, t2) => _BillingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BillingCopyWith<$R, $In extends Billing, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  AddressCopyWith<$R, Address, Address> get address;
  $R call({Address? address, String? email, String? name, String? phone});
  BillingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BillingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Billing, $Out>
    implements BillingCopyWith<$R, Billing, $Out> {
  _BillingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Billing> $mapper =
      BillingMapper.ensureInitialized();
  @override
  AddressCopyWith<$R, Address, Address> get address =>
      $value.address.copyWith.$chain((v) => call(address: v));
  @override
  $R call({Address? address, String? email, String? name, String? phone}) =>
      $apply(
        FieldCopyWithData({
          if (address != null) #address: address,
          if (email != null) #email: email,
          if (name != null) #name: name,
          if (phone != null) #phone: phone,
        }),
      );
  @override
  Billing $make(CopyWithData data) => Billing(
    address: data.get(#address, or: $value.address),
    email: data.get(#email, or: $value.email),
    name: data.get(#name, or: $value.name),
    phone: data.get(#phone, or: $value.phone),
  );

  @override
  BillingCopyWith<$R2, Billing, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _BillingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

  static dynamic _$city(Address v) => v.city;
  static const Field<Address, dynamic> _f$city = Field('city', _$city);
  static dynamic _$country(Address v) => v.country;
  static const Field<Address, dynamic> _f$country = Field('country', _$country);
  static dynamic _$line1(Address v) => v.line1;
  static const Field<Address, dynamic> _f$line1 = Field('line1', _$line1);
  static dynamic _$line2(Address v) => v.line2;
  static const Field<Address, dynamic> _f$line2 = Field('line2', _$line2);
  static dynamic _$postalCode(Address v) => v.postalCode;
  static const Field<Address, dynamic> _f$postalCode = Field(
    'postalCode',
    _$postalCode,
    key: r'postal_code',
  );
  static dynamic _$state(Address v) => v.state;
  static const Field<Address, dynamic> _f$state = Field('state', _$state);

  @override
  final MappableFields<Address> fields = const {
    #city: _f$city,
    #country: _f$country,
    #line1: _f$line1,
    #line2: _f$line2,
    #postalCode: _f$postalCode,
    #state: _f$state,
  };

  static Address _instantiate(DecodingData data) {
    return Address(
      city: data.dec(_f$city),
      country: data.dec(_f$country),
      line1: data.dec(_f$line1),
      line2: data.dec(_f$line2),
      postalCode: data.dec(_f$postalCode),
      state: data.dec(_f$state),
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
    dynamic city,
    dynamic country,
    dynamic line1,
    dynamic line2,
    dynamic postalCode,
    dynamic state,
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
    Object? city = $none,
    Object? country = $none,
    Object? line1 = $none,
    Object? line2 = $none,
    Object? postalCode = $none,
    Object? state = $none,
  }) => $apply(
    FieldCopyWithData({
      if (city != $none) #city: city,
      if (country != $none) #country: country,
      if (line1 != $none) #line1: line1,
      if (line2 != $none) #line2: line2,
      if (postalCode != $none) #postalCode: postalCode,
      if (state != $none) #state: state,
    }),
  );
  @override
  Address $make(CopyWithData data) => Address(
    city: data.get(#city, or: $value.city),
    country: data.get(#country, or: $value.country),
    line1: data.get(#line1, or: $value.line1),
    line2: data.get(#line2, or: $value.line2),
    postalCode: data.get(#postalCode, or: $value.postalCode),
    state: data.get(#state, or: $value.state),
  );

  @override
  AddressCopyWith<$R2, Address, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddressCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

