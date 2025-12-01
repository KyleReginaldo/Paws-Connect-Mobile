import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class IdExtractionResult {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? address;
  final String? dateOfBirth;
  final String? idNumber;
  final bool isSuccessful;
  final String? error;

  IdExtractionResult({
    this.firstName,
    this.lastName,
    this.middleName,
    this.address,
    this.dateOfBirth,
    this.idNumber,
    required this.isSuccessful,
    this.error,
  });

  @override
  String toString() {
    return 'IdExtractionResult(firstName: $firstName, lastName: $lastName, middleName: $middleName, address: $address, dateOfBirth: $dateOfBirth, idNumber: $idNumber, isSuccessful: $isSuccessful)';
  }
}

class IdTextExtractor {
  static final _textRecognizer = TextRecognizer();

  static Future<IdExtractionResult> extractIdData({
    required XFile imageFile,
    required String idType,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      final String extractedText = recognizedText.text;
      debugPrint('=== ID TEXT EXTRACTION ===');
      debugPrint('ID Type: $idType');
      debugPrint('Extracted Text: $extractedText');
      debugPrint('==========================');

      // Extract data based on ID type
      switch (idType) {
        case 'National ID':
          return _extractNationalIdData(extractedText);
        case 'Driver\'s License':
          return _extractDriversLicenseData(extractedText);
        case 'Barangay ID':
          return _extractBarangayIdData(extractedText);
        case 'Student ID':
          return _extractStudentIdData(extractedText);
        case 'PhilHealth ID':
          return _extractPhilHealthIdData(extractedText);
        default:
          return _extractGenericIdData(extractedText);
      }
    } catch (e) {
      debugPrint('Error extracting ID data: $e');
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Failed to extract text from ID: $e',
      );
    }
  }

  /// Extract data from National ID (PhilID)
  static IdExtractionResult _extractNationalIdData(String text) {
    try {
      String? firstName, lastName, middleName, address, dateOfBirth, idNumber;

      final lines = text.split('\n').map((line) => line.trim()).toList();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toUpperCase();

        // Extract ID Number (format: 2408-3069-8638-9549)
        if (idNumber == null) {
          final idNumMatch = RegExp(
            r'\d{4}-\d{4}-\d{4}-\d{4}',
          ).firstMatch(line);
          if (idNumMatch != null) {
            idNumber = idNumMatch.group(0);
          }
        }

        // Extract Last Name - look for single word after last name labels
        if ((line.contains('APELYIDO') ||
                line.contains('APELLIDO') ||
                line.contains('LAST NAME')) &&
            lastName == null) {
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            if (_isLikelySingleName(nextLine)) {
              lastName = _cleanName(nextLine);
            }
          }
        }

        // Extract First Name - handle multiple given names like "KYLE DENNIS" or "CEDRIQUE FRANCE CHOIE"
        if ((line.contains('PANGALAN') || line.contains('GIVEN NAME')) &&
            firstName == null) {
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            // For National ID, try to get the raw text first, then clean it
            if (nextLine.isNotEmpty && !_isOcrGarbage(nextLine.toUpperCase())) {
              final givenNames = _cleanName(nextLine);
              if (givenNames != null && givenNames.isNotEmpty) {
                // For National ID, all given names are considered first names
                firstName = givenNames;
              } else if (nextLine.length > 2) {
                // If cleaning failed but the line looks reasonable, use it directly
                final cleaned = nextLine
                    .replaceAll(RegExp(r'[^\w\s\-\.]'), ' ')
                    .replaceAll(RegExp(r'\s+'), ' ')
                    .trim()
                    .toUpperCase();
                if (cleaned.isNotEmpty) {
                  firstName = cleaned;
                }
              }
            }
          }
        }

        // Extract Middle Name - look for single word after middle name labels
        if ((line.contains('GITNANG') || line.contains('MIDDLE NAME')) &&
            middleName == null) {
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            if (_isLikelySingleName(nextLine)) {
              middleName = _cleanName(nextLine);
            }
          }
        }

        // Extract Date of Birth
        if ((line.contains('PETSA') ||
                line.contains('DATE OF BIRTH') ||
                line.contains('KAPANGANAKAN')) &&
            dateOfBirth == null) {
          if (i + 1 < lines.length) {
            final dobLine = lines[i + 1];
            // Look for date patterns: "SEPTEMBER 26, 2002" or "26 SEPTEMBER 2002"
            final dobMatch = RegExp(
              r'\b(?:JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+\d{1,2},?\s+\d{4}\b|\b\d{1,2}\s+(?:JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+\d{4}\b',
            ).firstMatch(dobLine);
            if (dobMatch != null) {
              dateOfBirth = dobMatch.group(0);
            }
          }
        }

        // Extract Address - look for long address lines
        if ((line.contains('TIRAHAN') || line.contains('ADDRESS')) &&
            address == null) {
          if (i + 1 < lines.length) {
            final addressLine = lines[i + 1].trim();
            // Look for lines that seem like addresses (contain numbers, commas, city names)
            if (addressLine.length > 10 &&
                (addressLine.contains(',') ||
                    RegExp(r'\d').hasMatch(addressLine))) {
              address = _cleanAddress(addressLine);
            }
          }
        }

        // Also try to find address patterns directly in lines
        if (address == null && line.length > 20 && line.contains(',')) {
          final cleanLine = _cleanAddress(line);
          if (cleanLine != null && cleanLine.length > 10) {
            address = cleanLine;
          }
        }
      }

      return IdExtractionResult(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        address: address,
        dateOfBirth: dateOfBirth,
        idNumber: idNumber,
        isSuccessful: true,
      );
    } catch (e) {
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Error extracting National ID data: $e',
      );
    }
  }

  /// Extract data from Driver's License
  static IdExtractionResult _extractDriversLicenseData(String text) {
    try {
      String? firstName, lastName, middleName, address, dateOfBirth, idNumber;

      final lines = text.split('\n').map((line) => line.trim()).toList();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toUpperCase();

        // Extract License Number (format: D36-24-002632)
        if (idNumber == null) {
          final licenseMatch = RegExp(
            r'[A-Z]\d{2}-\d{2}-\d{6}',
          ).firstMatch(line);
          if (licenseMatch != null) {
            idNumber = licenseMatch.group(0);
          }
        }

        // Look for comma-separated name format: "REGINALDO, KYLE DENNIS SEÑARIS"
        if (line.contains(',') && firstName == null && lastName == null) {
          final nameParts = line.split(',');
          if (nameParts.length >= 2) {
            final lastNamePart = _cleanName(nameParts[0].trim());
            final firstMiddlePart = _cleanName(nameParts[1].trim());

            if (lastNamePart != null && firstMiddlePart != null) {
              lastName = lastNamePart;

              // Use the complex name parser for the first/middle part
              final firstMiddleWords = firstMiddlePart
                  .split(' ')
                  .where((word) => word.isNotEmpty)
                  .toList();

              if (firstMiddleWords.isNotEmpty) {
                // Parse the "KYLE DENNIS SEÑARIS" part using complex name logic
                final nameResult = _parseComplexName(firstMiddleWords);
                if (nameResult != null) {
                  firstName = nameResult['firstName'];
                  // If there's already a middle name from parsing, use it
                  if (nameResult['middleName'] != null) {
                    middleName = nameResult['middleName'];
                  }
                  // If there's a lastName from parsing, it's actually a middle name
                  if (nameResult['lastName'] != null && middleName == null) {
                    middleName = nameResult['lastName'];
                  }
                } else {
                  // Fallback to simple parsing
                  firstName = firstMiddleWords.first;
                  if (firstMiddleWords.length > 1) {
                    middleName = firstMiddleWords.sublist(1).join(' ');
                  }
                }
              }
            }
          }
        }

        // Also check for traditional format after labels
        if (line.contains('LAST NAME') ||
            line.contains('FIRST NAME') ||
            line.contains('MIDDLE NAME')) {
          if (i + 1 < lines.length && firstName == null) {
            final nameLine = lines[i + 1];
            if (nameLine.contains(',')) {
              final nameParts = nameLine.split(',');
              if (nameParts.length >= 2) {
                lastName = _cleanName(nameParts[0].trim());
                final remainingName = nameParts[1].trim();
                final firstMiddle = remainingName
                    .split(' ')
                    .where((word) => word.isNotEmpty)
                    .toList();
                if (firstMiddle.isNotEmpty) {
                  // Use complex name parsing for the first/middle part
                  final nameResult = _parseComplexName(firstMiddle);
                  if (nameResult != null) {
                    firstName = nameResult['firstName'];
                    if (nameResult['middleName'] != null) {
                      middleName = nameResult['middleName'];
                    }
                    if (nameResult['lastName'] != null && middleName == null) {
                      middleName = nameResult['lastName'];
                    }
                  } else {
                    // Fallback
                    firstName = _cleanName(firstMiddle[0]);
                    if (firstMiddle.length > 1) {
                      middleName = _cleanName(firstMiddle.sublist(1).join(' '));
                    }
                  }
                }
              }
            }
          }
        }

        // Extract Date of Birth (format: 2002/09/26)
        if ((line.contains('DATE OF BIRTH') ||
                RegExp(r'\d{4}/\d{2}/\d{2}').hasMatch(line)) &&
            dateOfBirth == null) {
          final dobMatch = RegExp(r'\d{4}/\d{2}/\d{2}').firstMatch(line);
          if (dobMatch != null) {
            dateOfBirth = dobMatch.group(0);
          }
        }

        // Extract Address - look for block/lot patterns or long address lines
        if (line.contains('ADDRESS') ||
            (line.contains('BLOCK') && line.contains('LOT'))) {
          if (line.contains('BLOCK') && line.contains('LOT')) {
            // Direct address line
            address = _cleanAddress(line);
          } else if (i + 1 < lines.length && address == null) {
            // Look for the next few lines that contain address info
            final addressLines = <String>[];
            for (int j = i + 1; j < lines.length && j < i + 3; j++) {
              final addressLine = lines[j];
              if (!addressLine.contains('LICENSE') &&
                  !addressLine.contains('EXPIRATION') &&
                  !addressLine.contains('BLOOD TYPE')) {
                addressLines.add(addressLine);
              }
            }
            if (addressLines.isNotEmpty) {
              address = _cleanAddress(addressLines.join(' ').trim());
            }
          }
        }
      }

      return IdExtractionResult(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        address: address,
        dateOfBirth: dateOfBirth,
        idNumber: idNumber,
        isSuccessful: true,
      );
    } catch (e) {
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Error extracting Driver\'s License data: $e',
      );
    }
  }

  /// Extract data from Barangay ID
  static IdExtractionResult _extractBarangayIdData(String text) {
    try {
      String? firstName, lastName, middleName, address, dateOfBirth, idNumber;

      final lines = text.split('\n').map((line) => line.trim()).toList();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toUpperCase();

        // Extract ID Number
        if (idNumber == null) {
          final idMatch = RegExp(r'\d{2}-\d{2}-\d{3}').firstMatch(line);
          if (idMatch != null) {
            idNumber = idMatch.group(0);
          }
        }

        // Look for name patterns
        if (line.contains('LAST NAME') ||
            line.contains('FIRST NAME') ||
            line.contains('SURNAME') ||
            line.contains('GIVEN NAME')) {
          if (i + 1 < lines.length) {
            final nameLine = lines[i + 1];
            // Handle different name formats
            if (line.contains('LAST') || line.contains('SURNAME')) {
              lastName = _cleanName(nameLine);
            } else if (line.contains('FIRST') || line.contains('GIVEN')) {
              firstName = _cleanName(nameLine);
            }
          }
        }

        // Extract full name if in single line format
        if (_isLikelyFullName(line) && firstName == null && lastName == null) {
          final nameParts = line
              .split(' ')
              .where((part) => part.isNotEmpty)
              .toList();
          if (nameParts.length >= 2) {
            lastName = nameParts.last;
            firstName = nameParts.first;
            if (nameParts.length > 2) {
              middleName = nameParts.sublist(1, nameParts.length - 1).join(' ');
            }
          }
        }

        // Extract address (look for city, province, barangay keywords)
        if (address == null &&
            (line.contains('BARANGAY') ||
                line.contains('CITY') ||
                line.contains('PROVINCE') ||
                line.contains('ADDRESS'))) {
          address = _cleanAddress(line);
        }
      }

      return IdExtractionResult(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        address: address,
        dateOfBirth: dateOfBirth,
        idNumber: idNumber,
        isSuccessful: true,
      );
    } catch (e) {
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Error extracting Barangay ID data: $e',
      );
    }
  }

  /// Extract data from Student ID
  static IdExtractionResult _extractStudentIdData(String text) {
    try {
      String? firstName, lastName, middleName, address, dateOfBirth, idNumber;

      final lines = text.split('\n').map((line) => line.trim()).toList();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toUpperCase();

        // Extract Student Number (format: 2022-100-1152)
        if (idNumber == null) {
          final studentNumMatch = RegExp(r'\d{4}-\d{3}-\d{4}').firstMatch(line);
          if (studentNumMatch != null) {
            idNumber = studentNumMatch.group(0);
          }
        }

        // Look for full name patterns like "KYLE DENNIS S. REGINALDO" (without labels)
        // Student IDs typically display names prominently without "Name:" labels
        if ((_isLikelyFullNameWithInitial(line) || _isLikelyFullName(line)) &&
            firstName == null &&
            lastName == null &&
            !line.contains('UNIVERSITY') &&
            !line.contains('COLLEGE') &&
            !line.contains('CAMPUS') &&
            !line.contains('BACHELOR') &&
            !line.contains('SCIENCE') &&
            !line.contains('TECHNOLOGY')) {
          final cleanedLine = _cleanName(line);
          if (cleanedLine != null) {
            final nameParts = cleanedLine
                .split(' ')
                .where((part) => part.isNotEmpty)
                .toList();

            // Parse different name patterns
            final result = _parseComplexName(nameParts);
            if (result != null) {
              firstName = result['firstName'];
              middleName = result['middleName'];
              lastName = result['lastName'];
            }
          }
        }

        // Extract course/program info which might contain address info
        if (line.contains('CAMPUS') ||
            line.contains('UNIVERSITY') ||
            line.contains('COLLEGE') ||
            line.contains('CITY')) {
          address ??= _cleanAddress(line);
        }
      }

      return IdExtractionResult(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        address: address,
        dateOfBirth: dateOfBirth,
        idNumber: idNumber,
        isSuccessful: true,
      );
    } catch (e) {
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Error extracting Student ID data: $e',
      );
    }
  }

  /// Extract data from PhilHealth ID
  static IdExtractionResult _extractPhilHealthIdData(String text) {
    try {
      String? firstName, lastName, middleName, address, dateOfBirth, idNumber;

      final lines = text.split('\n').map((line) => line.trim()).toList();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toUpperCase();

        // Extract PhilHealth Number
        if (idNumber == null) {
          final philHealthMatch = RegExp(r'\d{2}-\d{9}-\d{1}').firstMatch(line);
          if (philHealthMatch != null) {
            idNumber = philHealthMatch.group(0);
          }
        }

        // Look for name patterns similar to other government IDs
        if (line.contains('MEMBER NAME') ||
            line.contains('NAME') ||
            _isLikelyFullName(line)) {
          if (firstName == null && lastName == null) {
            String nameToProcess = line;
            if (line.contains('NAME')) {
              if (i + 1 < lines.length) {
                nameToProcess = lines[i + 1];
              }
            }

            final nameParts = nameToProcess
                .split(' ')
                .where((part) => part.isNotEmpty)
                .toList();
            if (nameParts.length >= 2) {
              firstName = nameParts.first;
              lastName = nameParts.last;
              if (nameParts.length > 2) {
                middleName = nameParts
                    .sublist(1, nameParts.length - 1)
                    .join(' ');
              }
            }
          }
        }

        // Extract address if present
        if (address == null &&
            (line.contains('ADDRESS') || line.contains('RESIDENCE'))) {
          if (i + 1 < lines.length) {
            address = _cleanAddress(lines[i + 1]);
          }
        }
      }

      return IdExtractionResult(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        address: address,
        dateOfBirth: dateOfBirth,
        idNumber: idNumber,
        isSuccessful: true,
      );
    } catch (e) {
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Error extracting PhilHealth ID data: $e',
      );
    }
  }

  /// Generic extraction for unknown ID types
  static IdExtractionResult _extractGenericIdData(String text) {
    try {
      String? firstName, lastName, middleName, address;

      final lines = text.split('\n').map((line) => line.trim()).toList();

      // Look for likely name patterns
      for (final line in lines) {
        if (_isLikelyFullName(line) && firstName == null && lastName == null) {
          final nameParts = line
              .split(' ')
              .where((part) => part.isNotEmpty)
              .toList();
          if (nameParts.length >= 2) {
            firstName = nameParts.first;
            lastName = nameParts.last;
            if (nameParts.length > 2) {
              middleName = nameParts.sublist(1, nameParts.length - 1).join(' ');
            }
          }
          break;
        }
      }

      return IdExtractionResult(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        address: address,
        isSuccessful: true,
      );
    } catch (e) {
      return IdExtractionResult(
        isSuccessful: false,
        error: 'Error extracting generic ID data: $e',
      );
    }
  }

  /// Helper function to clean extracted names
  static String? _cleanName(String? name) {
    if (name == null) return null;

    // Remove common non-name characters and clean up
    String cleaned = name
        .replaceAll(RegExp(r'[^\w\s\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toUpperCase();

    // Check for OCR garbage patterns
    if (_isOcrGarbage(cleaned)) {
      return null;
    }

    // Filter out common non-name words
    final nonNameWords = {
      'ID',
      'CARD',
      'IDENTIFICATION',
      'GOVERNMENT',
      'PHILIPPINES',
      'REPUBLIC',
      'DEPARTMENT',
      'OFFICE',
      'AGENCY',
      'LICENSE',
      'NUMBER',
      'DATE',
      'BIRTH',
      'ADDRESS',
      'SIGNATURE',
      'VALID',
      'UNTIL',
      'ISSUED',
    };

    final words = cleaned
        .split(' ')
        .where((word) => word.length > 1 && !nonNameWords.contains(word))
        .toList();

    return words.isNotEmpty ? words.join(' ') : null;
  }

  /// Helper function to clean extracted addresses
  static String? _cleanAddress(String? address) {
    if (address == null) return null;

    // Clean up address text
    String cleaned = address
        .replaceAll(RegExp(r'[^\w\s\-\.,#]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned.isNotEmpty ? cleaned : null;
  }

  /// Helper function to determine if a line likely contains a person's name
  static bool _isLikelyFullName(String line) {
    final cleanLine = line.trim().toUpperCase();

    // Check for OCR garbage first
    if (_isOcrGarbage(cleanLine)) return false;

    // Skip if it contains common non-name keywords
    final nonNamePatterns = [
      'REPUBLIC',
      'PHILIPPINES',
      'DEPARTMENT',
      'GOVERNMENT',
      'IDENTIFICATION',
      'LICENSE',
      'CARD',
      'NUMBER',
      'DATE',
      'BIRTH',
      'ADDRESS',
      'SIGNATURE',
      'VALID',
      'UNTIL',
      'ISSUED',
      'AGENCY',
      'OFFICE',
      'UNIVERSITY',
      'COLLEGE',
      'STUDENT',
      'EMPLOYEE',
      'MEMBER',
    ];

    for (final pattern in nonNamePatterns) {
      if (cleanLine.contains(pattern)) return false;
    }

    // Check if it looks like a name (2-4 words, mostly letters)
    final words = cleanLine
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length < 2 || words.length > 4) return false;

    // Check if words contain mostly letters
    for (final word in words) {
      if (word.length < 2 || !RegExp(r'^[A-Z\-\.]+$').hasMatch(word)) {
        return false;
      }
      // Additional check for individual word garbage
      if (_isOcrGarbage(word)) return false;
    }

    return true;
  }

  /// Helper function to check if a line contains a full name with initial (like "KYLE DENNIS S. REGINALDO")
  static bool _isLikelyFullNameWithInitial(String line) {
    final cleanLine = line.trim().toUpperCase();

    // Check for OCR garbage first
    if (_isOcrGarbage(cleanLine)) return false;

    // Skip if it contains common non-name keywords
    final nonNamePatterns = [
      'REPUBLIC',
      'PHILIPPINES',
      'DEPARTMENT',
      'GOVERNMENT',
      'IDENTIFICATION',
      'LICENSE',
      'CARD',
      'NUMBER',
      'DATE',
      'BIRTH',
      'ADDRESS',
      'SIGNATURE',
      'VALID',
      'UNTIL',
      'ISSUED',
      'AGENCY',
      'OFFICE',
      // Reduced restrictions for Student IDs
      // 'UNIVERSITY', 'COLLEGE', 'STUDENT', 'BACHELOR', 'SCIENCE', 'TECHNOLOGY'
    ];

    for (final pattern in nonNamePatterns) {
      if (cleanLine.contains(pattern)) return false;
    }

    // Check if it looks like a name (3-6 words to accommodate multiple first names, mostly letters, may contain initials)
    final words = cleanLine
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length < 3 || words.length > 6) return false;

    // Check if words contain mostly letters, allow for initials
    for (final word in words) {
      if (word.isEmpty) return false;
      // Allow single letters or letters with periods (initials)
      if (word.length <= 2 && RegExp(r'^[A-Z]\.?$').hasMatch(word)) continue;
      // Regular names should be mostly letters
      if (!RegExp(r'^[A-Z\-\.]+$').hasMatch(word)) return false;
      // Additional check for individual word garbage
      if (_isOcrGarbage(word)) return false;
    }

    return true;
  }

  /// Helper function to check if a line contains a single name (for last name or middle name)
  static bool _isLikelySingleName(String line) {
    final cleanLine = line.trim().toUpperCase();

    // Should be a single word, mostly letters
    final words = cleanLine
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length != 1) return false;

    final word = words.first;
    return word.length >= 2 && RegExp(r'^[A-Z\-\.]+$').hasMatch(word);
  }

  /// Helper function to detect OCR garbage or nonsensical text
  static bool _isOcrGarbage(String text) {
    final cleanText = text.trim().toUpperCase();

    // Check for empty or very short text
    if (cleanText.length < 2) return true;

    // Check for too many numbers in what should be a name
    final numberCount = RegExp(r'\d').allMatches(cleanText).length;
    if (numberCount > cleanText.length * 0.3) return true;

    // Check for excessive consonants without vowels (OCR garbage pattern)
    final vowelCount = RegExp(r'[AEIOU]').allMatches(cleanText).length;
    final consonantCount = RegExp(
      r'[BCDFGHJKLMNPQRSTVWXYZ]',
    ).allMatches(cleanText).length;

    // If text is mostly consonants with very few vowels, likely garbage
    if (consonantCount > 6 && vowelCount < 2) return true;

    // Check for suspicious patterns that look like OCR errors
    final suspiciousPatterns = [
      r'\d+[A-Z]+\d+', // Mixed numbers and letters
      r'^[0-9]+[A-Z]*$', // Starting with numbers
      r'[A-Z]{10,}', // Very long strings without spaces
      r'[0-9]{5,}', // Long number sequences in names
    ];

    for (final pattern in suspiciousPatterns) {
      if (RegExp(pattern).hasMatch(cleanText)) return true;
    }

    // Check for reversed or scrambled common words (OCR artifacts)
    final scrambledPatterns = [
      'SREPUCLIKANGR', // Scrambled "REPUBLIKAN"
      'SECNALIPIHP', // Scrambled "PHILIPPINES"
      'TNEMNREVOG', // Scrambled "GOVERNMENT"
      'NOITACIFITNED', // Scrambled "IDENTIFICATION"
    ];

    for (final pattern in scrambledPatterns) {
      if (cleanText.contains(pattern)) return true;
    }

    return false;
  }

  /// Helper function to parse complex name patterns with multiple first names
  static Map<String, String?>? _parseComplexName(List<String> nameParts) {
    if (nameParts.length < 2) return null;

    String? firstName;
    String? middleName;
    String? lastName;

    if (nameParts.length == 2) {
      // Simple: "FIRST LAST" or for Driver's License: "FIRST MIDDLE"
      firstName = nameParts[0];
      lastName =
          nameParts[1]; // This might actually be middle name for Driver's License
    } else if (nameParts.length == 3) {
      // For Driver's License: "KYLE DENNIS SEÑARIS" = firstName="KYLE DENNIS", middleName="SEÑARIS"
      // For others: Could be "FIRST MIDDLE LAST" or "FIRST SECOND LAST"
      final middlePart = nameParts[1];
      if (middlePart.length <= 2 || middlePart.endsWith('.')) {
        // "FIRST M. LAST" or "FIRST M LAST"
        firstName = nameParts[0];
        middleName = middlePart.replaceAll('.', '');
        lastName = nameParts[2];
      } else {
        // For Driver's License format: "KYLE DENNIS SEÑARIS"
        // Assume first two are first names, last one is middle name
        firstName = '${nameParts[0]} ${nameParts[1]}';
        middleName = nameParts[2];
      }
    } else if (nameParts.length == 4) {
      // Could be:
      // 1. "FIRST SECOND M. LAST" (first=FIRST SECOND, middle=M, last=LAST)
      // 2. "FIRST MIDDLE1 MIDDLE2 LAST" (first=FIRST, middle=MIDDLE1 MIDDLE2, last=LAST)
      // 3. For Driver's License: "FIRST SECOND THIRD FOURTH" where last is usually middle
      final thirdPart = nameParts[2];
      if (thirdPart.length <= 2 || thirdPart.endsWith('.')) {
        // Pattern 1: "KYLE DENNIS S. REGINALDO"
        firstName = '${nameParts[0]} ${nameParts[1]}';
        middleName = thirdPart.replaceAll('.', '');
        lastName = nameParts[3];
      } else {
        // For Driver's License: assume first 2-3 parts are first names
        firstName = '${nameParts[0]} ${nameParts[1]}';
        middleName = '${nameParts[2]} ${nameParts[3]}';
      }
    } else if (nameParts.length == 5) {
      // Could be:
      // 1. "FIRST SECOND THIRD M. LAST" (first=FIRST SECOND THIRD, middle=M, last=LAST)
      // 2. "FIRST MIDDLE1 MIDDLE2 MIDDLE3 LAST" (first=FIRST, middle=MIDDLE1 MIDDLE2 MIDDLE3, last=LAST)
      final fourthPart = nameParts[3];
      if (fourthPart.length <= 2 || fourthPart.endsWith('.')) {
        // Pattern 1: "CEDRIQUE FRANCE CHOIE M. SURNAME"
        firstName = '${nameParts[0]} ${nameParts[1]} ${nameParts[2]}';
        middleName = fourthPart.replaceAll('.', '');
        lastName = nameParts[4];
      } else {
        // Pattern 2: Assume first name has 2 parts, middle has 2 parts
        firstName = '${nameParts[0]} ${nameParts[1]}';
        middleName = '${nameParts[2]} ${nameParts[3]}';
        lastName = nameParts[4];
      }
    } else if (nameParts.length >= 6) {
      // For very long names, try to identify initials or split intelligently
      lastName = nameParts.last;

      // Check if second to last is an initial
      final secondToLast = nameParts[nameParts.length - 2];
      if (secondToLast.length <= 2 || secondToLast.endsWith('.')) {
        // Has middle initial: "FIRST ... NAMES M. LAST"
        middleName = secondToLast.replaceAll('.', '');
        firstName = nameParts.sublist(0, nameParts.length - 2).join(' ');
      } else {
        // No clear initial, assume first half are first names
        final splitPoint = (nameParts.length - 1) ~/ 2;
        firstName = nameParts.sublist(0, splitPoint + 1).join(' ');
        if (splitPoint + 1 < nameParts.length - 1) {
          middleName = nameParts
              .sublist(splitPoint + 1, nameParts.length - 1)
              .join(' ');
        }
      }
    }

    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
    };
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
