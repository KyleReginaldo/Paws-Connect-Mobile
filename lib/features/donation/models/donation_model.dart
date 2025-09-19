import 'package:dart_mappable/dart_mappable.dart';

part 'donation_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Donation with DonationMappable {
  final int id;
  final DateTime donatedAt;
  final String fundraising;
  final String donor;
  final double amount;
  final String message;

  Donation({
    required this.id,
    required this.donatedAt,
    required this.fundraising,
    required this.donor,
    required this.amount,
    required this.message,
  });
}
