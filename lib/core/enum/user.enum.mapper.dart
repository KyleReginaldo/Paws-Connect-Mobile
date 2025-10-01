// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user.enum.dart';

class UserStatusMapper extends EnumMapper<UserStatus> {
  UserStatusMapper._();

  static UserStatusMapper? _instance;
  static UserStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserStatusMapper._());
    }
    return _instance!;
  }

  static UserStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  UserStatus decode(dynamic value) {
    switch (value) {
      case r'PENDING':
        return UserStatus.PENDING;
      case r'SEMI_VERIFIED':
        return UserStatus.SEMI_VERIFIED;
      case r'FULLY_VERIFIED':
        return UserStatus.FULLY_VERIFIED;
      case r'INDEFINITE':
        return UserStatus.INDEFINITE;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(UserStatus self) {
    switch (self) {
      case UserStatus.PENDING:
        return r'PENDING';
      case UserStatus.SEMI_VERIFIED:
        return r'SEMI_VERIFIED';
      case UserStatus.FULLY_VERIFIED:
        return r'FULLY_VERIFIED';
      case UserStatus.INDEFINITE:
        return r'INDEFINITE';
    }
  }
}

extension UserStatusMapperExtension on UserStatus {
  String toValue() {
    UserStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<UserStatus>(this) as String;
  }
}

