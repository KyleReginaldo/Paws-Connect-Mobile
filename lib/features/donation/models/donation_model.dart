// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  final bool isAnonymous;

  Donation({
    required this.id,
    required this.donatedAt,
    required this.fundraising,
    required this.donor,
    required this.amount,
    required this.message,
    required this.isAnonymous,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class DonorLeaderboard with DonorLeaderboardMappable {
  final int rank;
  final Donor user;
  final DonorTotals totals;

  DonorLeaderboard({
    required this.rank,
    required this.user,
    required this.totals,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Donor with DonorMappable {
  final String id;
  final String username;
  final String email;
  final String? profileImageLink;

  Donor({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageLink,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class DonorTotals with DonorTotalsMappable {
  final double amount;
  final int count;
  final DateTime lastDonatedAt;

  DonorTotals({
    required this.amount,
    required this.count,
    required this.lastDonatedAt,
  });
}
