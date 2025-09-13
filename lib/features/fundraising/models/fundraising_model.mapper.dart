// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'fundraising_model.dart';

class FundraisingMapper extends ClassMapperBase<Fundraising> {
  FundraisingMapper._();

  static FundraisingMapper? _instance;
  static FundraisingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FundraisingMapper._());
      CreatedByUserMapper.ensureInitialized();
      DonationsCountMapper.ensureInitialized();
      DonationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Fundraising';

  static int _$id(Fundraising v) => v.id;
  static const Field<Fundraising, int> _f$id = Field('id', _$id);
  static DateTime _$createdAt(Fundraising v) => v.createdAt;
  static const Field<Fundraising, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$title(Fundraising v) => v.title;
  static const Field<Fundraising, String> _f$title = Field('title', _$title);
  static String _$description(Fundraising v) => v.description;
  static const Field<Fundraising, String> _f$description = Field(
    'description',
    _$description,
  );
  static double _$targetAmount(Fundraising v) => v.targetAmount;
  static const Field<Fundraising, double> _f$targetAmount = Field(
    'targetAmount',
    _$targetAmount,
    key: r'target_amount',
    hook: IntToDoubleHook(),
  );
  static double _$raisedAmount(Fundraising v) => v.raisedAmount;
  static const Field<Fundraising, double> _f$raisedAmount = Field(
    'raisedAmount',
    _$raisedAmount,
    key: r'raised_amount',
    hook: IntToDoubleHook(),
  );
  static String _$createdBy(Fundraising v) => v.createdBy;
  static const Field<Fundraising, String> _f$createdBy = Field(
    'createdBy',
    _$createdBy,
    key: r'created_by',
  );
  static String _$status(Fundraising v) => v.status;
  static const Field<Fundraising, String> _f$status = Field('status', _$status);
  static List<String>? _$images(Fundraising v) => v.images;
  static const Field<Fundraising, List<String>> _f$images = Field(
    'images',
    _$images,
    opt: true,
  );
  static CreatedByUser _$createdByUser(Fundraising v) => v.createdByUser;
  static const Field<Fundraising, CreatedByUser> _f$createdByUser = Field(
    'createdByUser',
    _$createdByUser,
    key: r'created_by_user',
  );
  static List<DonationsCount>? _$donationsCount(Fundraising v) =>
      v.donationsCount;
  static const Field<Fundraising, List<DonationsCount>> _f$donationsCount =
      Field(
        'donationsCount',
        _$donationsCount,
        key: r'donations_count',
        opt: true,
      );
  static List<Donation>? _$donations(Fundraising v) => v.donations;
  static const Field<Fundraising, List<Donation>> _f$donations = Field(
    'donations',
    _$donations,
    opt: true,
  );
  static DateTime _$endDate(Fundraising v) => v.endDate;
  static const Field<Fundraising, DateTime> _f$endDate = Field(
    'endDate',
    _$endDate,
    key: r'end_date',
  );
  static String? _$facebookLink(Fundraising v) => v.facebookLink;
  static const Field<Fundraising, String> _f$facebookLink = Field(
    'facebookLink',
    _$facebookLink,
    key: r'facebook_link',
    opt: true,
  );

  @override
  final MappableFields<Fundraising> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #title: _f$title,
    #description: _f$description,
    #targetAmount: _f$targetAmount,
    #raisedAmount: _f$raisedAmount,
    #createdBy: _f$createdBy,
    #status: _f$status,
    #images: _f$images,
    #createdByUser: _f$createdByUser,
    #donationsCount: _f$donationsCount,
    #donations: _f$donations,
    #endDate: _f$endDate,
    #facebookLink: _f$facebookLink,
  };

  static Fundraising _instantiate(DecodingData data) {
    return Fundraising(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      targetAmount: data.dec(_f$targetAmount),
      raisedAmount: data.dec(_f$raisedAmount),
      createdBy: data.dec(_f$createdBy),
      status: data.dec(_f$status),
      images: data.dec(_f$images),
      createdByUser: data.dec(_f$createdByUser),
      donationsCount: data.dec(_f$donationsCount),
      donations: data.dec(_f$donations),
      endDate: data.dec(_f$endDate),
      facebookLink: data.dec(_f$facebookLink),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Fundraising fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Fundraising>(map);
  }

  static Fundraising fromJson(String json) {
    return ensureInitialized().decodeJson<Fundraising>(json);
  }
}

mixin FundraisingMappable {
  String toJson() {
    return FundraisingMapper.ensureInitialized().encodeJson<Fundraising>(
      this as Fundraising,
    );
  }

  Map<String, dynamic> toMap() {
    return FundraisingMapper.ensureInitialized().encodeMap<Fundraising>(
      this as Fundraising,
    );
  }

  FundraisingCopyWith<Fundraising, Fundraising, Fundraising> get copyWith =>
      _FundraisingCopyWithImpl<Fundraising, Fundraising>(
        this as Fundraising,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FundraisingMapper.ensureInitialized().stringifyValue(
      this as Fundraising,
    );
  }

  @override
  bool operator ==(Object other) {
    return FundraisingMapper.ensureInitialized().equalsValue(
      this as Fundraising,
      other,
    );
  }

  @override
  int get hashCode {
    return FundraisingMapper.ensureInitialized().hashValue(this as Fundraising);
  }
}

extension FundraisingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Fundraising, $Out> {
  FundraisingCopyWith<$R, Fundraising, $Out> get $asFundraising =>
      $base.as((v, t, t2) => _FundraisingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FundraisingCopyWith<$R, $In extends Fundraising, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get images;
  CreatedByUserCopyWith<$R, CreatedByUser, CreatedByUser> get createdByUser;
  ListCopyWith<
    $R,
    DonationsCount,
    DonationsCountCopyWith<$R, DonationsCount, DonationsCount>
  >?
  get donationsCount;
  ListCopyWith<$R, Donation, DonationCopyWith<$R, Donation, Donation>>?
  get donations;
  $R call({
    int? id,
    DateTime? createdAt,
    String? title,
    String? description,
    double? targetAmount,
    double? raisedAmount,
    String? createdBy,
    String? status,
    List<String>? images,
    CreatedByUser? createdByUser,
    List<DonationsCount>? donationsCount,
    List<Donation>? donations,
    DateTime? endDate,
    String? facebookLink,
  });
  FundraisingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FundraisingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Fundraising, $Out>
    implements FundraisingCopyWith<$R, Fundraising, $Out> {
  _FundraisingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Fundraising> $mapper =
      FundraisingMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get images =>
      $value.images != null
      ? ListCopyWith(
          $value.images!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(images: v),
        )
      : null;
  @override
  CreatedByUserCopyWith<$R, CreatedByUser, CreatedByUser> get createdByUser =>
      $value.createdByUser.copyWith.$chain((v) => call(createdByUser: v));
  @override
  ListCopyWith<
    $R,
    DonationsCount,
    DonationsCountCopyWith<$R, DonationsCount, DonationsCount>
  >?
  get donationsCount => $value.donationsCount != null
      ? ListCopyWith(
          $value.donationsCount!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(donationsCount: v),
        )
      : null;
  @override
  ListCopyWith<$R, Donation, DonationCopyWith<$R, Donation, Donation>>?
  get donations => $value.donations != null
      ? ListCopyWith(
          $value.donations!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(donations: v),
        )
      : null;
  @override
  $R call({
    int? id,
    DateTime? createdAt,
    String? title,
    String? description,
    double? targetAmount,
    double? raisedAmount,
    String? createdBy,
    String? status,
    Object? images = $none,
    CreatedByUser? createdByUser,
    Object? donationsCount = $none,
    Object? donations = $none,
    DateTime? endDate,
    Object? facebookLink = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (targetAmount != null) #targetAmount: targetAmount,
      if (raisedAmount != null) #raisedAmount: raisedAmount,
      if (createdBy != null) #createdBy: createdBy,
      if (status != null) #status: status,
      if (images != $none) #images: images,
      if (createdByUser != null) #createdByUser: createdByUser,
      if (donationsCount != $none) #donationsCount: donationsCount,
      if (donations != $none) #donations: donations,
      if (endDate != null) #endDate: endDate,
      if (facebookLink != $none) #facebookLink: facebookLink,
    }),
  );
  @override
  Fundraising $make(CopyWithData data) => Fundraising(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    targetAmount: data.get(#targetAmount, or: $value.targetAmount),
    raisedAmount: data.get(#raisedAmount, or: $value.raisedAmount),
    createdBy: data.get(#createdBy, or: $value.createdBy),
    status: data.get(#status, or: $value.status),
    images: data.get(#images, or: $value.images),
    createdByUser: data.get(#createdByUser, or: $value.createdByUser),
    donationsCount: data.get(#donationsCount, or: $value.donationsCount),
    donations: data.get(#donations, or: $value.donations),
    endDate: data.get(#endDate, or: $value.endDate),
    facebookLink: data.get(#facebookLink, or: $value.facebookLink),
  );

  @override
  FundraisingCopyWith<$R2, Fundraising, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FundraisingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreatedByUserMapper extends ClassMapperBase<CreatedByUser> {
  CreatedByUserMapper._();

  static CreatedByUserMapper? _instance;
  static CreatedByUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CreatedByUserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CreatedByUser';

  static String _$email(CreatedByUser v) => v.email;
  static const Field<CreatedByUser, String> _f$email = Field('email', _$email);
  static String _$username(CreatedByUser v) => v.username;
  static const Field<CreatedByUser, String> _f$username = Field(
    'username',
    _$username,
  );

  @override
  final MappableFields<CreatedByUser> fields = const {
    #email: _f$email,
    #username: _f$username,
  };

  static CreatedByUser _instantiate(DecodingData data) {
    return CreatedByUser(
      email: data.dec(_f$email),
      username: data.dec(_f$username),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreatedByUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreatedByUser>(map);
  }

  static CreatedByUser fromJson(String json) {
    return ensureInitialized().decodeJson<CreatedByUser>(json);
  }
}

mixin CreatedByUserMappable {
  String toJson() {
    return CreatedByUserMapper.ensureInitialized().encodeJson<CreatedByUser>(
      this as CreatedByUser,
    );
  }

  Map<String, dynamic> toMap() {
    return CreatedByUserMapper.ensureInitialized().encodeMap<CreatedByUser>(
      this as CreatedByUser,
    );
  }

  CreatedByUserCopyWith<CreatedByUser, CreatedByUser, CreatedByUser>
  get copyWith => _CreatedByUserCopyWithImpl<CreatedByUser, CreatedByUser>(
    this as CreatedByUser,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CreatedByUserMapper.ensureInitialized().stringifyValue(
      this as CreatedByUser,
    );
  }

  @override
  bool operator ==(Object other) {
    return CreatedByUserMapper.ensureInitialized().equalsValue(
      this as CreatedByUser,
      other,
    );
  }

  @override
  int get hashCode {
    return CreatedByUserMapper.ensureInitialized().hashValue(
      this as CreatedByUser,
    );
  }
}

extension CreatedByUserValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreatedByUser, $Out> {
  CreatedByUserCopyWith<$R, CreatedByUser, $Out> get $asCreatedByUser =>
      $base.as((v, t, t2) => _CreatedByUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CreatedByUserCopyWith<$R, $In extends CreatedByUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? email, String? username});
  CreatedByUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CreatedByUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreatedByUser, $Out>
    implements CreatedByUserCopyWith<$R, CreatedByUser, $Out> {
  _CreatedByUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CreatedByUser> $mapper =
      CreatedByUserMapper.ensureInitialized();
  @override
  $R call({String? email, String? username}) => $apply(
    FieldCopyWithData({
      if (email != null) #email: email,
      if (username != null) #username: username,
    }),
  );
  @override
  CreatedByUser $make(CopyWithData data) => CreatedByUser(
    email: data.get(#email, or: $value.email),
    username: data.get(#username, or: $value.username),
  );

  @override
  CreatedByUserCopyWith<$R2, CreatedByUser, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CreatedByUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DonationsCountMapper extends ClassMapperBase<DonationsCount> {
  DonationsCountMapper._();

  static DonationsCountMapper? _instance;
  static DonationsCountMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DonationsCountMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DonationsCount';

  static int _$count(DonationsCount v) => v.count;
  static const Field<DonationsCount, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<DonationsCount> fields = const {#count: _f$count};

  static DonationsCount _instantiate(DecodingData data) {
    return DonationsCount(count: data.dec(_f$count));
  }

  @override
  final Function instantiate = _instantiate;

  static DonationsCount fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DonationsCount>(map);
  }

  static DonationsCount fromJson(String json) {
    return ensureInitialized().decodeJson<DonationsCount>(json);
  }
}

mixin DonationsCountMappable {
  String toJson() {
    return DonationsCountMapper.ensureInitialized().encodeJson<DonationsCount>(
      this as DonationsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return DonationsCountMapper.ensureInitialized().encodeMap<DonationsCount>(
      this as DonationsCount,
    );
  }

  DonationsCountCopyWith<DonationsCount, DonationsCount, DonationsCount>
  get copyWith => _DonationsCountCopyWithImpl<DonationsCount, DonationsCount>(
    this as DonationsCount,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return DonationsCountMapper.ensureInitialized().stringifyValue(
      this as DonationsCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return DonationsCountMapper.ensureInitialized().equalsValue(
      this as DonationsCount,
      other,
    );
  }

  @override
  int get hashCode {
    return DonationsCountMapper.ensureInitialized().hashValue(
      this as DonationsCount,
    );
  }
}

extension DonationsCountValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DonationsCount, $Out> {
  DonationsCountCopyWith<$R, DonationsCount, $Out> get $asDonationsCount =>
      $base.as((v, t, t2) => _DonationsCountCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DonationsCountCopyWith<$R, $In extends DonationsCount, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? count});
  DonationsCountCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DonationsCountCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DonationsCount, $Out>
    implements DonationsCountCopyWith<$R, DonationsCount, $Out> {
  _DonationsCountCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DonationsCount> $mapper =
      DonationsCountMapper.ensureInitialized();
  @override
  $R call({int? count}) =>
      $apply(FieldCopyWithData({if (count != null) #count: count}));
  @override
  DonationsCount $make(CopyWithData data) =>
      DonationsCount(count: data.get(#count, or: $value.count));

  @override
  DonationsCountCopyWith<$R2, DonationsCount, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DonationsCountCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DonationMapper extends ClassMapperBase<Donation> {
  DonationMapper._();

  static DonationMapper? _instance;
  static DonationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DonationMapper._());
      DonorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Donation';

  static int _$id(Donation v) => v.id;
  static const Field<Donation, int> _f$id = Field('id', _$id);
  static Donor _$donor(Donation v) => v.donor;
  static const Field<Donation, Donor> _f$donor = Field('donor', _$donor);
  static int _$amount(Donation v) => v.amount;
  static const Field<Donation, int> _f$amount = Field('amount', _$amount);
  static String _$message(Donation v) => v.message;
  static const Field<Donation, String> _f$message = Field('message', _$message);
  static DateTime _$donatedAt(Donation v) => v.donatedAt;
  static const Field<Donation, DateTime> _f$donatedAt = Field(
    'donatedAt',
    _$donatedAt,
    key: r'donated_at',
  );

  @override
  final MappableFields<Donation> fields = const {
    #id: _f$id,
    #donor: _f$donor,
    #amount: _f$amount,
    #message: _f$message,
    #donatedAt: _f$donatedAt,
  };

  static Donation _instantiate(DecodingData data) {
    return Donation(
      id: data.dec(_f$id),
      donor: data.dec(_f$donor),
      amount: data.dec(_f$amount),
      message: data.dec(_f$message),
      donatedAt: data.dec(_f$donatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Donation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Donation>(map);
  }

  static Donation fromJson(String json) {
    return ensureInitialized().decodeJson<Donation>(json);
  }
}

mixin DonationMappable {
  String toJson() {
    return DonationMapper.ensureInitialized().encodeJson<Donation>(
      this as Donation,
    );
  }

  Map<String, dynamic> toMap() {
    return DonationMapper.ensureInitialized().encodeMap<Donation>(
      this as Donation,
    );
  }

  DonationCopyWith<Donation, Donation, Donation> get copyWith =>
      _DonationCopyWithImpl<Donation, Donation>(
        this as Donation,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DonationMapper.ensureInitialized().stringifyValue(this as Donation);
  }

  @override
  bool operator ==(Object other) {
    return DonationMapper.ensureInitialized().equalsValue(
      this as Donation,
      other,
    );
  }

  @override
  int get hashCode {
    return DonationMapper.ensureInitialized().hashValue(this as Donation);
  }
}

extension DonationValueCopy<$R, $Out> on ObjectCopyWith<$R, Donation, $Out> {
  DonationCopyWith<$R, Donation, $Out> get $asDonation =>
      $base.as((v, t, t2) => _DonationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DonationCopyWith<$R, $In extends Donation, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DonorCopyWith<$R, Donor, Donor> get donor;
  $R call({
    int? id,
    Donor? donor,
    int? amount,
    String? message,
    DateTime? donatedAt,
  });
  DonationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DonationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Donation, $Out>
    implements DonationCopyWith<$R, Donation, $Out> {
  _DonationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Donation> $mapper =
      DonationMapper.ensureInitialized();
  @override
  DonorCopyWith<$R, Donor, Donor> get donor =>
      $value.donor.copyWith.$chain((v) => call(donor: v));
  @override
  $R call({
    int? id,
    Donor? donor,
    int? amount,
    String? message,
    DateTime? donatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (donor != null) #donor: donor,
      if (amount != null) #amount: amount,
      if (message != null) #message: message,
      if (donatedAt != null) #donatedAt: donatedAt,
    }),
  );
  @override
  Donation $make(CopyWithData data) => Donation(
    id: data.get(#id, or: $value.id),
    donor: data.get(#donor, or: $value.donor),
    amount: data.get(#amount, or: $value.amount),
    message: data.get(#message, or: $value.message),
    donatedAt: data.get(#donatedAt, or: $value.donatedAt),
  );

  @override
  DonationCopyWith<$R2, Donation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DonationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DonorMapper extends ClassMapperBase<Donor> {
  DonorMapper._();

  static DonorMapper? _instance;
  static DonorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DonorMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Donor';

  static String _$id(Donor v) => v.id;
  static const Field<Donor, String> _f$id = Field('id', _$id);
  static String _$email(Donor v) => v.email;
  static const Field<Donor, String> _f$email = Field('email', _$email);
  static String _$username(Donor v) => v.username;
  static const Field<Donor, String> _f$username = Field('username', _$username);

  @override
  final MappableFields<Donor> fields = const {
    #id: _f$id,
    #email: _f$email,
    #username: _f$username,
  };

  static Donor _instantiate(DecodingData data) {
    return Donor(
      id: data.dec(_f$id),
      email: data.dec(_f$email),
      username: data.dec(_f$username),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Donor fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Donor>(map);
  }

  static Donor fromJson(String json) {
    return ensureInitialized().decodeJson<Donor>(json);
  }
}

mixin DonorMappable {
  String toJson() {
    return DonorMapper.ensureInitialized().encodeJson<Donor>(this as Donor);
  }

  Map<String, dynamic> toMap() {
    return DonorMapper.ensureInitialized().encodeMap<Donor>(this as Donor);
  }

  DonorCopyWith<Donor, Donor, Donor> get copyWith =>
      _DonorCopyWithImpl<Donor, Donor>(this as Donor, $identity, $identity);
  @override
  String toString() {
    return DonorMapper.ensureInitialized().stringifyValue(this as Donor);
  }

  @override
  bool operator ==(Object other) {
    return DonorMapper.ensureInitialized().equalsValue(this as Donor, other);
  }

  @override
  int get hashCode {
    return DonorMapper.ensureInitialized().hashValue(this as Donor);
  }
}

extension DonorValueCopy<$R, $Out> on ObjectCopyWith<$R, Donor, $Out> {
  DonorCopyWith<$R, Donor, $Out> get $asDonor =>
      $base.as((v, t, t2) => _DonorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DonorCopyWith<$R, $In extends Donor, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? email, String? username});
  DonorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DonorCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Donor, $Out>
    implements DonorCopyWith<$R, Donor, $Out> {
  _DonorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Donor> $mapper = DonorMapper.ensureInitialized();
  @override
  $R call({String? id, String? email, String? username}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (email != null) #email: email,
      if (username != null) #username: username,
    }),
  );
  @override
  Donor $make(CopyWithData data) => Donor(
    id: data.get(#id, or: $value.id),
    email: data.get(#email, or: $value.email),
    username: data.get(#username, or: $value.username),
  );

  @override
  DonorCopyWith<$R2, Donor, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DonorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

