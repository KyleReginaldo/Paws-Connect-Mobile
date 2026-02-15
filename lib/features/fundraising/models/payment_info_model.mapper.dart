// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_info_model.dart';

class PaymentInfoMapper extends ClassMapperBase<PaymentInfo> {
  PaymentInfoMapper._();

  static PaymentInfoMapper? _instance;
  static PaymentInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PaymentInfo';

  static String _$label(PaymentInfo v) => v.label;
  static const Field<PaymentInfo, String> _f$label = Field('label', _$label);
  static String? _$qrCode(PaymentInfo v) => v.qrCode;
  static const Field<PaymentInfo, String> _f$qrCode = Field(
    'qrCode',
    _$qrCode,
    key: r'qr_code',
    opt: true,
  );
  static String _$accountNumber(PaymentInfo v) => v.accountNumber;
  static const Field<PaymentInfo, String> _f$accountNumber = Field(
    'accountNumber',
    _$accountNumber,
    key: r'account_number',
  );

  @override
  final MappableFields<PaymentInfo> fields = const {
    #label: _f$label,
    #qrCode: _f$qrCode,
    #accountNumber: _f$accountNumber,
  };

  static PaymentInfo _instantiate(DecodingData data) {
    return PaymentInfo(
      label: data.dec(_f$label),
      qrCode: data.dec(_f$qrCode),
      accountNumber: data.dec(_f$accountNumber),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PaymentInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PaymentInfo>(map);
  }

  static PaymentInfo fromJson(String json) {
    return ensureInitialized().decodeJson<PaymentInfo>(json);
  }
}

mixin PaymentInfoMappable {
  String toJson() {
    return PaymentInfoMapper.ensureInitialized().encodeJson<PaymentInfo>(
      this as PaymentInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return PaymentInfoMapper.ensureInitialized().encodeMap<PaymentInfo>(
      this as PaymentInfo,
    );
  }

  PaymentInfoCopyWith<PaymentInfo, PaymentInfo, PaymentInfo> get copyWith =>
      _PaymentInfoCopyWithImpl<PaymentInfo, PaymentInfo>(
        this as PaymentInfo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PaymentInfoMapper.ensureInitialized().stringifyValue(
      this as PaymentInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return PaymentInfoMapper.ensureInitialized().equalsValue(
      this as PaymentInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return PaymentInfoMapper.ensureInitialized().hashValue(this as PaymentInfo);
  }
}

extension PaymentInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PaymentInfo, $Out> {
  PaymentInfoCopyWith<$R, PaymentInfo, $Out> get $asPaymentInfo =>
      $base.as((v, t, t2) => _PaymentInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PaymentInfoCopyWith<$R, $In extends PaymentInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? label, String? qrCode, String? accountNumber});
  PaymentInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PaymentInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PaymentInfo, $Out>
    implements PaymentInfoCopyWith<$R, PaymentInfo, $Out> {
  _PaymentInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PaymentInfo> $mapper =
      PaymentInfoMapper.ensureInitialized();
  @override
  $R call({String? label, Object? qrCode = $none, String? accountNumber}) =>
      $apply(
        FieldCopyWithData({
          if (label != null) #label: label,
          if (qrCode != $none) #qrCode: qrCode,
          if (accountNumber != null) #accountNumber: accountNumber,
        }),
      );
  @override
  PaymentInfo $make(CopyWithData data) => PaymentInfo(
    label: data.get(#label, or: $value.label),
    qrCode: data.get(#qrCode, or: $value.qrCode),
    accountNumber: data.get(#accountNumber, or: $value.accountNumber),
  );

  @override
  PaymentInfoCopyWith<$R2, PaymentInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PaymentInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

