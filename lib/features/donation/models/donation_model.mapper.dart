// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'donation_model.dart';

class DonationMapper extends ClassMapperBase<Donation> {
  DonationMapper._();

  static DonationMapper? _instance;
  static DonationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DonationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Donation';

  static int _$id(Donation v) => v.id;
  static const Field<Donation, int> _f$id = Field('id', _$id);
  static DateTime _$donatedAt(Donation v) => v.donatedAt;
  static const Field<Donation, DateTime> _f$donatedAt = Field(
    'donatedAt',
    _$donatedAt,
    key: r'donated_at',
  );
  static String _$fundraising(Donation v) => v.fundraising;
  static const Field<Donation, String> _f$fundraising = Field(
    'fundraising',
    _$fundraising,
  );
  static String _$donor(Donation v) => v.donor;
  static const Field<Donation, String> _f$donor = Field('donor', _$donor);
  static double _$amount(Donation v) => v.amount;
  static const Field<Donation, double> _f$amount = Field('amount', _$amount);
  static String _$message(Donation v) => v.message;
  static const Field<Donation, String> _f$message = Field('message', _$message);
  static bool _$isAnonymous(Donation v) => v.isAnonymous;
  static const Field<Donation, bool> _f$isAnonymous = Field(
    'isAnonymous',
    _$isAnonymous,
    key: r'is_anonymous',
  );

  @override
  final MappableFields<Donation> fields = const {
    #id: _f$id,
    #donatedAt: _f$donatedAt,
    #fundraising: _f$fundraising,
    #donor: _f$donor,
    #amount: _f$amount,
    #message: _f$message,
    #isAnonymous: _f$isAnonymous,
  };

  static Donation _instantiate(DecodingData data) {
    return Donation(
      id: data.dec(_f$id),
      donatedAt: data.dec(_f$donatedAt),
      fundraising: data.dec(_f$fundraising),
      donor: data.dec(_f$donor),
      amount: data.dec(_f$amount),
      message: data.dec(_f$message),
      isAnonymous: data.dec(_f$isAnonymous),
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
  $R call({
    int? id,
    DateTime? donatedAt,
    String? fundraising,
    String? donor,
    double? amount,
    String? message,
    bool? isAnonymous,
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
  $R call({
    int? id,
    DateTime? donatedAt,
    String? fundraising,
    String? donor,
    double? amount,
    String? message,
    bool? isAnonymous,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (donatedAt != null) #donatedAt: donatedAt,
      if (fundraising != null) #fundraising: fundraising,
      if (donor != null) #donor: donor,
      if (amount != null) #amount: amount,
      if (message != null) #message: message,
      if (isAnonymous != null) #isAnonymous: isAnonymous,
    }),
  );
  @override
  Donation $make(CopyWithData data) => Donation(
    id: data.get(#id, or: $value.id),
    donatedAt: data.get(#donatedAt, or: $value.donatedAt),
    fundraising: data.get(#fundraising, or: $value.fundraising),
    donor: data.get(#donor, or: $value.donor),
    amount: data.get(#amount, or: $value.amount),
    message: data.get(#message, or: $value.message),
    isAnonymous: data.get(#isAnonymous, or: $value.isAnonymous),
  );

  @override
  DonationCopyWith<$R2, Donation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DonationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DonorLeaderboardMapper extends ClassMapperBase<DonorLeaderboard> {
  DonorLeaderboardMapper._();

  static DonorLeaderboardMapper? _instance;
  static DonorLeaderboardMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DonorLeaderboardMapper._());
      DonorMapper.ensureInitialized();
      DonorTotalsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DonorLeaderboard';

  static int _$rank(DonorLeaderboard v) => v.rank;
  static const Field<DonorLeaderboard, int> _f$rank = Field('rank', _$rank);
  static Donor _$user(DonorLeaderboard v) => v.user;
  static const Field<DonorLeaderboard, Donor> _f$user = Field('user', _$user);
  static DonorTotals _$totals(DonorLeaderboard v) => v.totals;
  static const Field<DonorLeaderboard, DonorTotals> _f$totals = Field(
    'totals',
    _$totals,
  );

  @override
  final MappableFields<DonorLeaderboard> fields = const {
    #rank: _f$rank,
    #user: _f$user,
    #totals: _f$totals,
  };

  static DonorLeaderboard _instantiate(DecodingData data) {
    return DonorLeaderboard(
      rank: data.dec(_f$rank),
      user: data.dec(_f$user),
      totals: data.dec(_f$totals),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DonorLeaderboard fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DonorLeaderboard>(map);
  }

  static DonorLeaderboard fromJson(String json) {
    return ensureInitialized().decodeJson<DonorLeaderboard>(json);
  }
}

mixin DonorLeaderboardMappable {
  String toJson() {
    return DonorLeaderboardMapper.ensureInitialized()
        .encodeJson<DonorLeaderboard>(this as DonorLeaderboard);
  }

  Map<String, dynamic> toMap() {
    return DonorLeaderboardMapper.ensureInitialized()
        .encodeMap<DonorLeaderboard>(this as DonorLeaderboard);
  }

  DonorLeaderboardCopyWith<DonorLeaderboard, DonorLeaderboard, DonorLeaderboard>
  get copyWith =>
      _DonorLeaderboardCopyWithImpl<DonorLeaderboard, DonorLeaderboard>(
        this as DonorLeaderboard,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DonorLeaderboardMapper.ensureInitialized().stringifyValue(
      this as DonorLeaderboard,
    );
  }

  @override
  bool operator ==(Object other) {
    return DonorLeaderboardMapper.ensureInitialized().equalsValue(
      this as DonorLeaderboard,
      other,
    );
  }

  @override
  int get hashCode {
    return DonorLeaderboardMapper.ensureInitialized().hashValue(
      this as DonorLeaderboard,
    );
  }
}

extension DonorLeaderboardValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DonorLeaderboard, $Out> {
  DonorLeaderboardCopyWith<$R, DonorLeaderboard, $Out>
  get $asDonorLeaderboard =>
      $base.as((v, t, t2) => _DonorLeaderboardCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DonorLeaderboardCopyWith<$R, $In extends DonorLeaderboard, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DonorCopyWith<$R, Donor, Donor> get user;
  DonorTotalsCopyWith<$R, DonorTotals, DonorTotals> get totals;
  $R call({int? rank, Donor? user, DonorTotals? totals});
  DonorLeaderboardCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DonorLeaderboardCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DonorLeaderboard, $Out>
    implements DonorLeaderboardCopyWith<$R, DonorLeaderboard, $Out> {
  _DonorLeaderboardCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DonorLeaderboard> $mapper =
      DonorLeaderboardMapper.ensureInitialized();
  @override
  DonorCopyWith<$R, Donor, Donor> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  DonorTotalsCopyWith<$R, DonorTotals, DonorTotals> get totals =>
      $value.totals.copyWith.$chain((v) => call(totals: v));
  @override
  $R call({int? rank, Donor? user, DonorTotals? totals}) => $apply(
    FieldCopyWithData({
      if (rank != null) #rank: rank,
      if (user != null) #user: user,
      if (totals != null) #totals: totals,
    }),
  );
  @override
  DonorLeaderboard $make(CopyWithData data) => DonorLeaderboard(
    rank: data.get(#rank, or: $value.rank),
    user: data.get(#user, or: $value.user),
    totals: data.get(#totals, or: $value.totals),
  );

  @override
  DonorLeaderboardCopyWith<$R2, DonorLeaderboard, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DonorLeaderboardCopyWithImpl<$R2, $Out2>($value, $cast, t);
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
  static String _$username(Donor v) => v.username;
  static const Field<Donor, String> _f$username = Field('username', _$username);
  static String _$email(Donor v) => v.email;
  static const Field<Donor, String> _f$email = Field('email', _$email);
  static String? _$profileImageLink(Donor v) => v.profileImageLink;
  static const Field<Donor, String> _f$profileImageLink = Field(
    'profileImageLink',
    _$profileImageLink,
    key: r'profile_image_link',
    opt: true,
  );

  @override
  final MappableFields<Donor> fields = const {
    #id: _f$id,
    #username: _f$username,
    #email: _f$email,
    #profileImageLink: _f$profileImageLink,
  };

  static Donor _instantiate(DecodingData data) {
    return Donor(
      id: data.dec(_f$id),
      username: data.dec(_f$username),
      email: data.dec(_f$email),
      profileImageLink: data.dec(_f$profileImageLink),
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
  $R call({
    String? id,
    String? username,
    String? email,
    String? profileImageLink,
  });
  DonorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DonorCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Donor, $Out>
    implements DonorCopyWith<$R, Donor, $Out> {
  _DonorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Donor> $mapper = DonorMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? username,
    String? email,
    Object? profileImageLink = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (username != null) #username: username,
      if (email != null) #email: email,
      if (profileImageLink != $none) #profileImageLink: profileImageLink,
    }),
  );
  @override
  Donor $make(CopyWithData data) => Donor(
    id: data.get(#id, or: $value.id),
    username: data.get(#username, or: $value.username),
    email: data.get(#email, or: $value.email),
    profileImageLink: data.get(#profileImageLink, or: $value.profileImageLink),
  );

  @override
  DonorCopyWith<$R2, Donor, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DonorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DonorTotalsMapper extends ClassMapperBase<DonorTotals> {
  DonorTotalsMapper._();

  static DonorTotalsMapper? _instance;
  static DonorTotalsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DonorTotalsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DonorTotals';

  static double _$amount(DonorTotals v) => v.amount;
  static const Field<DonorTotals, double> _f$amount = Field('amount', _$amount);
  static int _$count(DonorTotals v) => v.count;
  static const Field<DonorTotals, int> _f$count = Field('count', _$count);
  static DateTime _$lastDonatedAt(DonorTotals v) => v.lastDonatedAt;
  static const Field<DonorTotals, DateTime> _f$lastDonatedAt = Field(
    'lastDonatedAt',
    _$lastDonatedAt,
    key: r'last_donated_at',
  );

  @override
  final MappableFields<DonorTotals> fields = const {
    #amount: _f$amount,
    #count: _f$count,
    #lastDonatedAt: _f$lastDonatedAt,
  };

  static DonorTotals _instantiate(DecodingData data) {
    return DonorTotals(
      amount: data.dec(_f$amount),
      count: data.dec(_f$count),
      lastDonatedAt: data.dec(_f$lastDonatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DonorTotals fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DonorTotals>(map);
  }

  static DonorTotals fromJson(String json) {
    return ensureInitialized().decodeJson<DonorTotals>(json);
  }
}

mixin DonorTotalsMappable {
  String toJson() {
    return DonorTotalsMapper.ensureInitialized().encodeJson<DonorTotals>(
      this as DonorTotals,
    );
  }

  Map<String, dynamic> toMap() {
    return DonorTotalsMapper.ensureInitialized().encodeMap<DonorTotals>(
      this as DonorTotals,
    );
  }

  DonorTotalsCopyWith<DonorTotals, DonorTotals, DonorTotals> get copyWith =>
      _DonorTotalsCopyWithImpl<DonorTotals, DonorTotals>(
        this as DonorTotals,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DonorTotalsMapper.ensureInitialized().stringifyValue(
      this as DonorTotals,
    );
  }

  @override
  bool operator ==(Object other) {
    return DonorTotalsMapper.ensureInitialized().equalsValue(
      this as DonorTotals,
      other,
    );
  }

  @override
  int get hashCode {
    return DonorTotalsMapper.ensureInitialized().hashValue(this as DonorTotals);
  }
}

extension DonorTotalsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DonorTotals, $Out> {
  DonorTotalsCopyWith<$R, DonorTotals, $Out> get $asDonorTotals =>
      $base.as((v, t, t2) => _DonorTotalsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DonorTotalsCopyWith<$R, $In extends DonorTotals, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? amount, int? count, DateTime? lastDonatedAt});
  DonorTotalsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DonorTotalsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DonorTotals, $Out>
    implements DonorTotalsCopyWith<$R, DonorTotals, $Out> {
  _DonorTotalsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DonorTotals> $mapper =
      DonorTotalsMapper.ensureInitialized();
  @override
  $R call({double? amount, int? count, DateTime? lastDonatedAt}) => $apply(
    FieldCopyWithData({
      if (amount != null) #amount: amount,
      if (count != null) #count: count,
      if (lastDonatedAt != null) #lastDonatedAt: lastDonatedAt,
    }),
  );
  @override
  DonorTotals $make(CopyWithData data) => DonorTotals(
    amount: data.get(#amount, or: $value.amount),
    count: data.get(#count, or: $value.count),
    lastDonatedAt: data.get(#lastDonatedAt, or: $value.lastDonatedAt),
  );

  @override
  DonorTotalsCopyWith<$R2, DonorTotals, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DonorTotalsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

