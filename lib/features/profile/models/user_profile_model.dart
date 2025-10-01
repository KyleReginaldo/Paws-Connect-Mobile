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
  });
}
