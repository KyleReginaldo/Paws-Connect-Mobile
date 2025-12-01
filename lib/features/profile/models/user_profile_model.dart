// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/core/enum/user.enum.dart';
import 'package:paws_connect/core/extension/ext.dart';

import '../../../flavors/flavor_config.dart';

part 'user_profile_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserProfile with UserProfileMappable {
  final String id;
  final String createdAt;
  final String username;
  final String email;
  final UserStatus status;
  final int role;
  final String phoneNumber;
  final List<String>? houseImages;
  final String? paymongoId;
  final String? paymentMethod;
  final String? profileImageLink;
  final String? createdBy;
  final bool? passwordChanged;
  final UserIdentification? userIdentification;
  final bool? isActive;
  final DateTime? lastActiveAt;
  final List<String>? violations;
  final bool onboarded;

  UserProfile({
    required this.id,
    required this.createdAt,
    required this.username,
    required this.email,
    required this.status,
    required this.role,
    required this.phoneNumber,
    this.houseImages,
    this.paymongoId,
    this.paymentMethod,
    this.profileImageLink,
    this.createdBy,
    this.passwordChanged,
    this.userIdentification,
    this.isActive,
    this.lastActiveAt,
    this.violations,
    required this.onboarded,
  });
  String? get transformedIdAttachmentUrl {
    if (FlavorConfig.isDevelopment()) {
      return profileImageLink?.transformedUrl;
    } else {
      return profileImageLink;
    }
  }

  List<String>? get transformedHouseImages {
    if (FlavorConfig.isDevelopment()) {
      return houseImages?.map((image) => image.transformedUrl).toList();
    } else {
      return houseImages;
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserIdentification with UserIdentificationMappable {
  final int id;
  final DateTime createdAt;
  final String idAttachmentUrl;
  final String firstName;
  final String lastName;
  final String? middleInitial;
  final String? address;
  final String? dateOfBirth;
  final String? idType;
  final String status;

  UserIdentification(
    this.id,
    this.createdAt,
    this.idAttachmentUrl,
    this.firstName,
    this.lastName,
    this.middleInitial,
    this.address,
    this.dateOfBirth,
    this.idType,
    this.status,
  );
  String get transformedIdAttachmentUrl {
    if (FlavorConfig.isDevelopment()) {
      return idAttachmentUrl.transformedUrl;
    } else {
      return idAttachmentUrl;
    }
  }
}
