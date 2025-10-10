// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/core/enum/user.enum.dart';

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
  final bool? isActive; // New field to track active status
  final DateTime? lastActiveAt; // New field to track last active timestamp

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
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserIdentification with UserIdentificationMappable {
  final int id;
  final DateTime createdAt;
  final String idAttachmentUrl;
  final String idName;
  final String? address;
  final String? dateOfBirth;
  final String status;

  UserIdentification(
    this.id,
    this.createdAt,
    this.idAttachmentUrl,
    this.idName,
    this.address,
    this.dateOfBirth,
    this.status,
  );
}
