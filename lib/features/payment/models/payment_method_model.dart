import 'package:dart_mappable/dart_mappable.dart';

part 'payment_method_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class PaymentMethod with PaymentMethodMappable {
  final String id;
  final String type;
  final Attributes attributes;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.attributes,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Attributes with AttributesMappable {
  final bool livemode;
  final String type;
  final Billing billing;
  final int createdAt;
  final int updatedAt;
  final dynamic details;
  final dynamic metadata;

  Attributes({
    required this.livemode,
    required this.type,
    required this.billing,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
    required this.metadata,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Billing with BillingMappable {
  final Address address;
  final String email;
  final String name;
  final String phone;

  Billing({
    required this.address,
    required this.email,
    required this.name,
    required this.phone,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Address with AddressMappable {
  final dynamic city;
  final dynamic country;
  final dynamic line1;
  final dynamic line2;
  final dynamic postalCode;
  final dynamic state;

  Address({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });
}
