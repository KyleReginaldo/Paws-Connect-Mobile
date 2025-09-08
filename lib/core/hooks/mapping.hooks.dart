import 'package:dart_mappable/dart_mappable.dart';

class IntToDoubleHook extends MappingHook {
  const IntToDoubleHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is int) return value.toDouble();
    return value;
  }
}
