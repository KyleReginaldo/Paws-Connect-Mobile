// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'id_type.enum.dart';

class IdTypeMapper extends EnumMapper<IdType> {
  IdTypeMapper._();

  static IdTypeMapper? _instance;
  static IdTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IdTypeMapper._());
    }
    return _instance!;
  }

  static IdType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  IdType decode(dynamic value) {
    switch (value) {
      case r'BARANGAY_ID':
        return IdType.BARANGAY_ID;
      case r'NATIONAL_ID':
        return IdType.NATIONAL_ID;
      case r'DRIVERS_LICENSE':
        return IdType.DRIVERS_LICENSE;
      case r'PHILHEALTH':
        return IdType.PHILHEALTH;
      case r'STUDENT_ID':
        return IdType.STUDENT_ID;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(IdType self) {
    switch (self) {
      case IdType.BARANGAY_ID:
        return r'BARANGAY_ID';
      case IdType.NATIONAL_ID:
        return r'NATIONAL_ID';
      case IdType.DRIVERS_LICENSE:
        return r'DRIVERS_LICENSE';
      case IdType.PHILHEALTH:
        return r'PHILHEALTH';
      case IdType.STUDENT_ID:
        return r'STUDENT_ID';
    }
  }
}

extension IdTypeMapperExtension on IdType {
  String toValue() {
    IdTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<IdType>(this) as String;
  }
}

