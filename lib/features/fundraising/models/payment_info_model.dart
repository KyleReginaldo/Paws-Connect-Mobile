import 'package:dart_mappable/dart_mappable.dart';

part 'payment_info_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class PaymentInfo with PaymentInfoMappable {
  final String label;
  final String? qrCode;
  final String accountNumber;

  PaymentInfo({required this.label, this.qrCode, required this.accountNumber});
}
