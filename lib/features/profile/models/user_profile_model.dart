import 'package:dart_mappable/dart_mappable.dart';

part 'user_profile_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserProfile with UserProfileMappable {
  String id;
  String createdAt;
  String username;
  String email;
  String status;
  int role;
  String phoneNumber;
  List<String>? houseImages;

  UserProfile({
    required this.id,
    required this.createdAt,
    required this.username,
    required this.email,
    required this.status,
    required this.role,
    required this.phoneNumber,
    this.houseImages,
  });
}
