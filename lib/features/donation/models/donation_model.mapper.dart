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

  @override
  final MappableFields<Donation> fields = const {
    #id: _f$id,
    #donatedAt: _f$donatedAt,
    #fundraising: _f$fundraising,
    #donor: _f$donor,
    #amount: _f$amount,
    #message: _f$message,
  };

  static Donation _instantiate(DecodingData data) {
    return Donation(
      id: data.dec(_f$id),
      donatedAt: data.dec(_f$donatedAt),
      fundraising: data.dec(_f$fundraising),
      donor: data.dec(_f$donor),
      amount: data.dec(_f$amount),
      message: data.dec(_f$message),
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
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (donatedAt != null) #donatedAt: donatedAt,
      if (fundraising != null) #fundraising: fundraising,
      if (donor != null) #donor: donor,
      if (amount != null) #amount: amount,
      if (message != null) #message: message,
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
  );

  @override
  DonationCopyWith<$R2, Donation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DonationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

