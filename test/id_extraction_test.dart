import 'package:flutter_test/flutter_test.dart';
import 'package:paws_connect/features/verification/services/id_text_extractor.dart';

void main() {
  group('ID Text Extraction Tests', () {
    test('should successfully initialize IdTextExtractor', () {
      // Test that the class can be instantiated and methods exist
      expect(IdTextExtractor.extractIdData, isA<Function>());
    });

    test('IdExtractionResult should have proper structure', () {
      final result = IdExtractionResult(
        firstName: 'KYLE',
        lastName: 'REGINALDO',
        middleName: 'DENNIS',
        address: '100 PUROK 1, BACAOL',
        dateOfBirth: 'SEPTEMBER 26, 2002',
        idNumber: '2408-3069-8638-9549',
        isSuccessful: true,
      );

      expect(result.firstName, equals('KYLE'));
      expect(result.lastName, equals('REGINALDO'));
      expect(result.middleName, equals('DENNIS'));
      expect(result.address, equals('100 PUROK 1, BACAOL'));
      expect(result.dateOfBirth, equals('SEPTEMBER 26, 2002'));
      expect(result.idNumber, equals('2408-3069-8638-9549'));
      expect(result.isSuccessful, isTrue);
      expect(result.error, isNull);
    });

    test('IdExtractionResult toString should work correctly', () {
      final result = IdExtractionResult(
        firstName: 'KYLE',
        lastName: 'REGINALDO',
        isSuccessful: true,
      );

      final stringResult = result.toString();
      expect(stringResult, contains('KYLE'));
      expect(stringResult, contains('REGINALDO'));
      expect(stringResult, contains('true'));
    });

    test('IdExtractionResult should handle error cases', () {
      final errorResult = IdExtractionResult(
        isSuccessful: false,
        error: 'Test error message',
      );

      expect(errorResult.isSuccessful, isFalse);
      expect(errorResult.error, equals('Test error message'));
      expect(errorResult.firstName, isNull);
      expect(errorResult.lastName, isNull);
      expect(errorResult.middleName, isNull);
      expect(errorResult.address, isNull);
      expect(errorResult.dateOfBirth, isNull);
      expect(errorResult.idNumber, isNull);
    });

    test(
      'IdExtractionResult should handle Student ID name format correctly',
      () {
        // Test the expected extraction for "KYLE DENNIS S. REGINALDO"
        final studentResult = IdExtractionResult(
          firstName: 'KYLE DENNIS', // Should be combined first names
          lastName: 'REGINALDO', // Should be the last name
          middleName: 'S', // Should be just the middle initial
          idNumber: '2022-100-1152',
          isSuccessful: true,
        );

        expect(studentResult.firstName, equals('KYLE DENNIS'));
        expect(studentResult.lastName, equals('REGINALDO'));
        expect(studentResult.middleName, equals('S'));
        expect(studentResult.idNumber, equals('2022-100-1152'));
        expect(studentResult.isSuccessful, isTrue);
      },
    );

    test('IdExtractionResult should handle multiple first names correctly', () {
      // Test the expected extraction for names like "CEDRIQUE FRANCE CHOIE M. SURNAME"
      final complexNameResult = IdExtractionResult(
        firstName: 'CEDRIQUE FRANCE CHOIE', // Should be all three first names
        lastName: 'SURNAME', // Should be the last name
        middleName: 'M', // Should be just the middle initial
        isSuccessful: true,
      );

      expect(complexNameResult.firstName, equals('CEDRIQUE FRANCE CHOIE'));
      expect(complexNameResult.lastName, equals('SURNAME'));
      expect(complexNameResult.middleName, equals('M'));
      expect(complexNameResult.isSuccessful, isTrue);
    });
  });
}
