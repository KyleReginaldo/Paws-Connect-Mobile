class AddAddressDTO {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final String user;
  final bool? isDefault;

  AddAddressDTO({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.user,
    this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'country': 'Philippines',
      'users': user,
      'is_default': isDefault ?? false,
    };
  }
}
