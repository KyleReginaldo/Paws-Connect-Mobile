import 'package:dart_mappable/dart_mappable.dart';

part 'address_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Address with AddressMappable {
  int id;
  DateTime createdAt;
  String street;
  String city;
  String state;
  String country;
  String users;
  bool isDefault;
  String zipCode;
  double? latitude;
  double? longitude;

  Address({
    required this.id,
    required this.createdAt,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.users,
    required this.isDefault,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });
  String get fullAddress {
    return [street, city, state].where((part) => part.isNotEmpty).join(', ');
  }
}
