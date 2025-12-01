// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';
import 'package:paws_connect/core/extension/ext.dart';

import '../../../core/hooks/mapping.hooks.dart';
import '../../../flavors/flavor_config.dart';
import 'payment_info_model.dart';

part 'fundraising_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Fundraising with FundraisingMappable {
  int id;
  DateTime createdAt;
  String title;
  String description;
  @MappableField(hook: IntToDoubleHook())
  double targetAmount;
  @MappableField(hook: IntToDoubleHook())
  double raisedAmount;
  String createdBy;
  String status;
  List<String>? images;
  CreatedByUser createdByUser;
  final List<DonationsCount>? donationsCount;
  final List<Donation>? donations;
  final DateTime endDate;
  final String? facebookLink;
  final String? qrCode;
  final String? gcashNumber;
  final List<PaymentInfo>? bankAccounts;
  final List<PaymentInfo>? eWallets;

  Fundraising({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.raisedAmount,
    required this.createdBy,
    required this.status,
    this.images,
    required this.createdByUser,
    this.donationsCount,
    this.donations,
    required this.endDate,
    this.facebookLink,
    this.qrCode,
    this.gcashNumber,
    this.bankAccounts,
    this.eWallets,
  });
  String? get transformedQrCode {
    if (FlavorConfig.isDevelopment()) {
      return qrCode?.transformedUrl;
    } else {
      return qrCode;
    }
  }

  List<String>? get transformedImages {
    if (FlavorConfig.isDevelopment()) {
      return images?.map((image) => image.transformedUrl).toList();
    } else {
      return images;
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CreatedByUser with CreatedByUserMappable {
  String email;
  String username;

  CreatedByUser({required this.email, required this.username});
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class DonationsCount with DonationsCountMappable {
  int count;
  DonationsCount({required this.count});
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Donation with DonationMappable {
  final int id;
  final Donor donor;
  final int amount;
  final String message;
  final DateTime donatedAt;
  final bool isAnonymous;

  Donation({
    required this.id,
    required this.donor,
    required this.amount,
    required this.message,
    required this.donatedAt,
    required this.isAnonymous,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Donor with DonorMappable {
  final String id;
  final String email;
  final String username;

  Donor({required this.id, required this.email, required this.username});
}
