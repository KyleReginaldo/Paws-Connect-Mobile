import 'package:flutter_test/flutter_test.dart';
import 'package:paws_connect/features/verification/services/id_text_extractor.dart';

void main() {
  group('IdTextExtractor Tests', () {
    test('should create IdExtractionResult successfully', () {
      final result = IdExtractionResult(
        firstName: 'John',
        lastName: 'Doe',
        middleName: 'Michael',
        address: '123 Main Street',
        dateOfBirth: 'January 1, 1990',
        idNumber: '1234-5678-9012-3456',
        isSuccessful: true,
      );

      expect(result.isSuccessful, true);
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
      expect(result.middleName, 'Michael');
      expect(result.address, '123 Main Street');
      expect(result.dateOfBirth, 'January 1, 1990');
      expect(result.idNumber, '1234-5678-9012-3456');
    });

    test('should create error result', () {
      final result = IdExtractionResult(
        isSuccessful: false,
        error: 'Failed to extract data',
      );

      expect(result.isSuccessful, false);
      expect(result.error, 'Failed to extract data');
      expect(result.firstName, null);
      expect(result.lastName, null);
    });

    test('should format toString correctly', () {
      final result = IdExtractionResult(
        firstName: 'John',
        lastName: 'Doe',
        isSuccessful: true,
      );

      final stringRepresentation = result.toString();
      expect(stringRepresentation.contains('firstName: John'), true);
      expect(stringRepresentation.contains('lastName: Doe'), true);
      expect(stringRepresentation.contains('isSuccessful: true'), true);
    });
  });
}
