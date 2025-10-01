// Enum representing a user's verification status.
// Added names mapping to ensure stable (de)serialization even if enum order changes.
// If backend sends lowercase/snake_case strings, dart_mappable can map via these names.
import 'package:dart_mappable/dart_mappable.dart';

part 'user.enum.mapper.dart';

@MappableEnum(mode: ValuesMode.named)
enum UserStatus {
  PENDING,
  SEMI_VERIFIED,
  FULLY_VERIFIED,
  INDEFINITE;

  /// Human friendly label for UI.
  String get label {
    switch (this) {
      case UserStatus.PENDING:
        return 'Pending Verification';
      case UserStatus.SEMI_VERIFIED:
        return 'Semi Verified';
      case UserStatus.FULLY_VERIFIED:
        return 'Fully Verified';
      case UserStatus.INDEFINITE:
        return 'Indefinite Suspension';
    }
  }

  /// Color semantic key (UI layer can map to actual colors if desired)
  String get severityKey {
    switch (this) {
      case UserStatus.PENDING:
        return 'warning';
      case UserStatus.SEMI_VERIFIED:
        return 'info';
      case UserStatus.FULLY_VERIFIED:
        return 'success';
      case UserStatus.INDEFINITE:
        return 'error';
    }
  }
}
