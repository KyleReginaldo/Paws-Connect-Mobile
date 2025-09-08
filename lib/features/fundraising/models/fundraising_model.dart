import 'package:dart_mappable/dart_mappable.dart';

import '../../../core/hooks/mapping.hooks.dart';

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
  List<String> images;
  CreatedByUser createdByUser;
  List<DonationsCount> donationsCount;

  Fundraising({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.raisedAmount,
    required this.createdBy,
    required this.status,
    required this.images,
    required this.createdByUser,
    required this.donationsCount,
  });
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
