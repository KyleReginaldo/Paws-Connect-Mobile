import 'package:dart_mappable/dart_mappable.dart';

part 'id_type.enum.mapper.dart';

@MappableEnum(mode: ValuesMode.named)
enum IdType {
  BARANGAY_ID,
  NATIONAL_ID,
  DRIVERS_LICENSE,
  PHILHEALTH,
  STUDENT_ID;

  /// Human friendly label for UI.
  String get label {
    switch (this) {
      case IdType.BARANGAY_ID:
        return 'Barangay ID';
      case IdType.NATIONAL_ID:
        return 'National ID';
      case IdType.DRIVERS_LICENSE:
        return "Driver's License";
      case IdType.PHILHEALTH:
        return 'PhilHealth ID';
      case IdType.STUDENT_ID:
        return 'Student ID';
    }
  }

  /// Get all available ID types as a list of labels
  static List<String> get allLabels {
    return IdType.values.map((idType) => idType.label).toList();
  }

  /// Get IdType from label string
  static IdType? fromLabel(String label) {
    for (final idType in IdType.values) {
      if (idType.label == label) {
        return idType;
      }
    }
    return null;
  }
}
