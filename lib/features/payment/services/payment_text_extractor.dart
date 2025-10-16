import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class PaymentTextExtractor {
  static final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Extract text from image and parse payment details from multiple platforms
  static Future<PaymentData> extractPaymentData(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      final extractedText = _combineRecognizedText(recognizedText);
      debugPrint('Extracted text: $extractedText');

      return _parsePaymentData(extractedText);
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return PaymentData(
        referenceNumber: '',
        amount: '',
        extractedText: '',
        success: false,
        error: 'Failed to extract text from image',
      );
    }
  }

  /// Combine all recognized text blocks into a single string
  static String _combineRecognizedText(RecognizedText recognizedText) {
    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
    }
    return buffer.toString();
  }

  /// Parse payment data from extracted text (supports GCash, GoTyme, PayMaya)
  static PaymentData _parsePaymentData(String text) {
    String referenceNumber = '';
    String amount = '';
    bool foundRef = false;
    bool foundAmount = false;

    final lines = text.split('\n');
    debugPrint('Processing ${lines.length} lines for payment data');

    // Look for BOTH reference numbers and amounts in a single pass
    String bestAmount = '';
    int bestAmountScore = 0;
    String bestReference = '';
    int bestReferenceScore = 0;

    for (int i = 0; i < lines.length; i++) {
      final trimmedLine = lines[i].trim();
      if (trimmedLine.isEmpty) continue;

      debugPrint('Checking line $i: "$trimmedLine"');

      // Check for reference number patterns
      if (_isReferenceNumber(trimmedLine)) {
        final extractedRef = _extractReferenceNumber(trimmedLine);
        if (extractedRef.length >= 8) {
          // Allow shorter references (like 9-digit ones)
          final refScore = _getReferenceScore(trimmedLine, extractedRef);
          debugPrint(
            'Found reference candidate: $extractedRef from "$trimmedLine" (score: $refScore)',
          );

          if (refScore > bestReferenceScore || bestReference.isEmpty) {
            bestReference = extractedRef;
            bestReferenceScore = refScore;
            foundRef = true;
          }
        }
      }

      // Check for amount patterns
      final amountMatch = _extractAmount(trimmedLine);
      if (amountMatch.isNotEmpty) {
        // Check context of surrounding lines for better accuracy
        final contextScore = _getAmountContextScore(lines, i);
        final totalScore = contextScore;

        debugPrint('Found amount candidate: $amountMatch (score: $totalScore)');

        if (totalScore > bestAmountScore || bestAmount.isEmpty) {
          bestAmount = amountMatch;
          bestAmountScore = totalScore;
        }
      }
    }

    // Assign the best matches
    if (foundRef) {
      referenceNumber = bestReference;
    }

    if (bestAmount.isNotEmpty) {
      amount = bestAmount;
      foundAmount = true;
      debugPrint('Selected best amount: $amount');
    }

    final success = foundRef || foundAmount;

    debugPrint(
      'Parsing result - Ref: $referenceNumber, Amount: $amount, Success: $success',
    );

    return PaymentData(
      referenceNumber: referenceNumber,
      amount: amount,
      extractedText: text,
      success: success,
      error: success ? null : 'Could not extract payment details from image',
    );
  }

  /// Get context score for amount based on surrounding lines
  static int _getAmountContextScore(List<String> lines, int lineIndex) {
    int score = 5; // Base score

    // Check previous and next lines for context clues
    final contextRange = 2;
    final startIndex = (lineIndex - contextRange).clamp(0, lines.length - 1);
    final endIndex = (lineIndex + contextRange).clamp(0, lines.length - 1);

    for (int i = startIndex; i <= endIndex; i++) {
      if (i == lineIndex) continue;

      final contextLine = lines[i].toLowerCase();

      // Positive context indicators for multiple platforms
      if (contextLine.contains('gcash') ||
          contextLine.contains('gotyme') ||
          contextLine.contains('paymaya') ||
          contextLine.contains('sent') ||
          contextLine.contains('transfer') ||
          contextLine.contains('payment') ||
          contextLine.contains('successful') ||
          contextLine.contains('bill amount') ||
          contextLine.contains('transfer amount')) {
        score += 3;
      }

      // Negative context indicators (avoid false positives)
      if (contextLine.contains('balance') ||
          contextLine.contains('available') ||
          contextLine.contains('limit')) {
        score -= 2;
      }
    }

    return score;
  }

  /// Score reference numbers to prioritize the most important one
  static int _getReferenceScore(String line, String extractedRef) {
    final lowerLine = line.toLowerCase();
    int score = 5; // Base score

    // Higher score for longer reference numbers
    if (extractedRef.length >= 13) score += 5;
    if (extractedRef.length >= 15) score += 3;

    // Higher score for specific reference patterns (GCash)
    if (lowerLine.contains('ref no.') || lowerLine.contains('ref no:')) {
      score += 10; // "Ref No." is typically the main transaction reference
    } else if (lowerLine.contains('reference no') ||
        lowerLine.contains('reference number')) {
      score += 7; // "Reference Number" is also important but lower priority
    } else if (lowerLine.contains('transaction') && lowerLine.contains('id')) {
      score += 8; // Transaction ID is high priority
    } else if (lowerLine.contains('receipt')) {
      score += 6;
    }

    // GoTyme specific patterns
    if (lowerLine.contains('reference no.') &&
        (lowerLine.contains('ito') || extractedRef.startsWith('ITO'))) {
      score += 12; // GoTyme reference pattern "Reference No. ITO13213312"
    }

    // PayMaya specific patterns
    if (lowerLine.contains('bill reference number')) {
      score += 11; // PayMaya "Bill reference number"
    }

    // Platform specific scoring
    if (lowerLine.contains('gcash') ||
        lowerLine.contains('gotyme') ||
        lowerLine.contains('paymaya')) {
      score += 4;
    }

    // If it's a standalone long number, it's likely important
    if (lowerLine.trim() == extractedRef) {
      score += 3;
    }

    debugPrint(
      'Reference score for "$line": $score (length: ${extractedRef.length})',
    );
    return score;
  }

  /// Check if a line contains a reference number
  static bool _isReferenceNumber(String line) {
    // Extract numbers (handling spaced numbers too)
    final numbersOnly = _extractReferenceNumber(line);

    // Must have at least 8 digits to be considered a reference (to catch shorter refs like "033343431")
    if (numbersOnly.length < 8) return false;

    // Common patterns for multiple payment platforms
    final referencePatterns = [
      // Direct number patterns
      RegExp(r'^\s*\d{10,15}\s*$'), // Pure 10-15 digit numbers
      RegExp(r'^\s*\d{13}\s*$'), // 13-digit numbers are very common for GCash
      // GCash reference patterns
      RegExp(
        r'reference\s+number\s+([\d\s]{8,})',
        caseSensitive: false,
      ), // "Reference Number 00334459323121"
      RegExp(
        r'ref\s+no\.?\s+([\d\s]{10,})',
        caseSensitive: false,
      ), // "Ref No. 0033 415 944973" (with spaces)
      // GoTyme reference patterns
      RegExp(
        r'reference\s+no\.?\s+ITO[\d\s]{8,}',
        caseSensitive: false,
      ), // "Reference No. ITO13213312"
      // PayMaya reference patterns
      RegExp(
        r'bill\s+reference\s+number\s+([\d\s]{8,})',
        caseSensitive: false,
      ), // "Bill reference number 323131"
      // More flexible labeled reference patterns (handle spaces in numbers)
      RegExp(
        r'ref(?:erence)?[\s\.:]*(?:no\.?|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),
      RegExp(
        r'transaction[\s\.:]*(?:id|number|ref)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),
      RegExp(
        r'receipt[\s\.:]*(?:no|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),

      // Platform specific patterns
      RegExp(
        r'gcash[\s\.:]*(?:ref|reference|id|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),
      RegExp(
        r'gotyme[\s\.:]*(?:ref|reference|id|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),
      RegExp(
        r'paymaya[\s\.:]*(?:ref|reference|id|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),

      // Transfer/Payment ID patterns
      RegExp(
        r'transfer[\s\.:]*(?:id|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),
      RegExp(
        r'payment[\s\.:]*(?:id|number)?[\s\.:]*[\d\s]{8,}',
        caseSensitive: false,
      ),

      // Time-based references (common format: YYYYMMDDHHMMSS + digits)
      RegExp(r'\d{14,}'), // 14+ digits often indicate timestamped references
      // Lines that are mostly numbers with minimal text (adjust for shorter refs and spaces)
      RegExp(
        r'^\s*[A-Za-z]*\s*[\d\s]{8,}\s*[A-Za-z]*\s*$',
      ), // Allow some letters but mostly numbers and spaces
    ];

    // Check if line matches any reference pattern
    for (final pattern in referencePatterns) {
      if (pattern.hasMatch(line)) {
        // Additional validation: avoid phone numbers, amounts, etc.
        if (!_isLikelyNotReference(line)) {
          debugPrint('Reference pattern matched: $line -> $numbersOnly');
          return true;
        }
      }
    }

    return false;
  }

  /// Check if a line is likely NOT a reference number (avoid false positives)
  static bool _isLikelyNotReference(String line) {
    final lowerLine = line.toLowerCase();

    // Skip if it looks like a phone number
    if (lowerLine.contains('phone') ||
        lowerLine.contains('mobile') ||
        lowerLine.contains('number')) {
      return true;
    }

    // Skip if it contains currency symbols (likely an amount)
    if (lowerLine.contains('₱') ||
        lowerLine.contains('php') ||
        lowerLine.contains('peso')) {
      return true;
    }

    // Skip if it looks like a date/time
    if (lowerLine.contains('/') ||
        lowerLine.contains('-') ||
        lowerLine.contains(':')) {
      final numbers = _extractNumbersOnly(line);
      if (numbers.length <= 8) {
        return true; // Short numbers with separators are likely dates
      }
    }

    return false;
  }

  /// Extract amount from a line
  static String _extractAmount(String line) {
    // More comprehensive patterns for multiple payment platforms
    final amountPatterns = [
      // Direct peso symbol patterns (highest priority)
      RegExp(r'₱\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(
        r'P\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ), // Sometimes shows as "P"
      // PHP patterns
      RegExp(r'php\s*:?\s*([\d,]+\.?\d*)', caseSensitive: false),

      // Handle negative amounts (like "-600.00")
      RegExp(r'amount.*?-?\s*([\d,]+\.?\d*)', caseSensitive: false),

      // GCash Amount/Total patterns with various formats
      RegExp(
        r'total\s+amount\s+sent[\s:]*₱?\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ), // "Total Amount Sent ₱600.00"
      RegExp(r'amount[\s:]*₱?\s*-?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'total[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'paid[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'sent[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),

      // GoTyme specific patterns
      RegExp(
        r'transfer\s+amount[\s:]*₱?\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ), // "Transfer amount ₱32321.00"
      // PayMaya specific patterns
      RegExp(
        r'bill\s+amount[\s:]*₱?\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ), // "Bill amount ₱3232,30.00"
      RegExp(
        r'₱\s*([\d,]+,\d+\.\d{2})',
        caseSensitive: false,
      ), // Handle PayMaya format like "₱3232,30.00" with comma before decimal
      // Generic transaction patterns
      RegExp(r'you\s+sent[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'transferred[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'payment[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'send\s+money[\s:]*₱?\s*([\d,]+\.?\d*)', caseSensitive: false),

      // Pattern for "₱1,500.00" or "P1,500.00" at the beginning of line
      RegExp(r'^[₱P]\s*([\d,]+\.?\d*)', caseSensitive: false),

      // Standalone number patterns (lower priority to avoid false positives)
      RegExp(
        r'^\s*-?\s*([\d,]{3,}\.?\d*)\s*$',
      ), // Numbers with at least 3 digits, including negative
      RegExp(
        r'^\s*-?\s*([\d,]+\.\d{2})\s*$',
      ), // Decimal amounts like -600.00 or 600.00
      // Amount in the middle of line with context
      RegExp(r'of\s+₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'worth\s+₱?\s*([\d,]+\.?\d*)', caseSensitive: false),
    ];

    String bestMatch = '';
    int bestScore = 0;

    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final amount = match.group(1)?.replaceAll(',', '') ?? '';
        if (amount.isNotEmpty) {
          // Score based on pattern type (more specific patterns get higher scores)
          int score = _getAmountPatternScore(pattern, line);
          debugPrint('Amount candidate: $amount from "$line" (score: $score)');

          if (score > bestScore || bestMatch.isEmpty) {
            bestMatch = amount;
            bestScore = score;
          }
        }
      }
    }

    // Validate the extracted amount
    if (bestMatch.isNotEmpty) {
      final numericValue = double.tryParse(bestMatch);
      if (numericValue != null && numericValue >= 1 && numericValue <= 999999) {
        // Format to remove unnecessary decimals
        final formattedAmount = numericValue % 1 == 0
            ? numericValue.toInt().toString()
            : bestMatch;
        debugPrint('Valid amount found: $formattedAmount');
        return formattedAmount;
      }
    }

    return '';
  }

  /// Score amount patterns to prioritize more specific matches
  static int _getAmountPatternScore(RegExp pattern, String line) {
    final patternString = pattern.pattern.toLowerCase();
    final lowerLine = line.toLowerCase();

    // Highest priority: "Total Amount Sent ₱600.00" - this is the final amount (GCash)
    if (patternString.contains('total') &&
        patternString.contains('amount') &&
        patternString.contains('sent')) {
      return 15;
    }

    // GoTyme specific patterns
    if (patternString.contains('transfer') &&
        patternString.contains('amount')) {
      return 14; // "Transfer amount ₱32321.00"
    }

    // PayMaya specific patterns
    if (patternString.contains('bill') && patternString.contains('amount')) {
      return 13; // "Bill amount ₱3232,30.00"
    }

    // Higher scores for more specific patterns
    if (patternString.contains('₱') || patternString.contains('php')) {
      return 10;
    }

    // Prioritize "Total Amount Sent" even without peso sign
    if (lowerLine.contains('total amount sent')) {
      return 12;
    }

    // Platform-specific context scoring
    if (lowerLine.contains('transfer amount')) {
      return 11; // GoTyme
    }
    if (lowerLine.contains('bill amount')) {
      return 10; // PayMaya
    }

    if (patternString.contains('amount') || patternString.contains('total')) {
      return 8;
    }
    if (patternString.contains('sent') || patternString.contains('paid')) {
      return 7;
    }
    if (patternString.contains('transferred') ||
        patternString.contains('payment')) {
      return 6;
    }

    // Lower score for standalone numbers (to avoid false positives)
    return 3;
  }

  /// Extract only numbers from a string
  static String _extractNumbersOnly(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Extract reference number from a line, handling spaced numbers and platform-specific formats
  static String _extractReferenceNumber(String line) {
    // Try to extract reference number with specific patterns first
    final specificPatterns = [
      // GCash patterns
      RegExp(r'reference\s+number\s+([\d\s]+)', caseSensitive: false),
      RegExp(r'ref\s+no\.?\s+([\d\s]+)', caseSensitive: false),

      // GoTyme patterns (includes alphanumeric like "ITO13213312")
      RegExp(r'reference\s+no\.?\s+(ITO[\d\s]+)', caseSensitive: false),

      // PayMaya patterns
      RegExp(r'bill\s+reference\s+number\s+([\d\s]+)', caseSensitive: false),

      // Generic patterns
      RegExp(
        r'ref(?:erence)?[\s\.:]*(?:no\.?|number)?[\s\.:]*([\d\s]+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in specificPatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final extractedText = match.group(1) ?? '';

        // For GoTyme ITO references, keep the ITO prefix
        if (extractedText.toUpperCase().startsWith('ITO')) {
          final cleaned = extractedText.replaceAll(RegExp(r'[^\w]'), '');
          if (cleaned.length >= 8) {
            debugPrint(
              'Extracted GoTyme reference with pattern: $cleaned from "$line"',
            );
            return cleaned;
          }
        } else {
          // For numeric references, extract only numbers
          final extracted = extractedText.replaceAll(RegExp(r'[^\d]'), '');
          if (extracted.length >= 8) {
            debugPrint(
              'Extracted reference with pattern: $extracted from "$line"',
            );
            return extracted;
          }
        }
      }
    }

    // Fallback to extracting all numbers from the line
    return _extractNumbersOnly(line);
  }

  /// Get all potential matches for debugging purposes
  static Map<String, List<String>> getDebugMatches(String text) {
    final lines = text.split('\n');
    final Map<String, List<String>> matches = {
      'reference_candidates': [],
      'amount_candidates': [],
      'all_numbers': [],
    };

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Check for reference patterns
      if (_isReferenceNumber(trimmedLine)) {
        final extractedRef = _extractReferenceNumber(trimmedLine);
        matches['reference_candidates']!.add('$trimmedLine -> $extractedRef');
      }

      // Check for amount patterns
      final amount = _extractAmount(trimmedLine);
      if (amount.isNotEmpty) {
        matches['amount_candidates']!.add('$trimmedLine -> $amount');
      }

      // Extract all numbers for debugging
      final numbers = _extractNumbersOnly(trimmedLine);
      if (numbers.length >= 4) {
        matches['all_numbers']!.add('$trimmedLine -> $numbers');
      }
    }

    return matches;
  }

  /// Test with specific example text (for debugging)
  static void testWithExamples() {
    final gcashExample1 = '''
Amount                                  -600.00
Reference Number                00334459323121
''';

    final gcashExample2 = '''
Amount                                   600.00
-------------------------------------
Total Amount Sent                ₱600.00
                  Ref No. 0033 415 944973
''';

    final gotymeExample = '''
Transfer amount ₱32321.00
Reference No. ITO13213312
''';

    final paymayaExample = '''
Bill amount  pesos value 
₱3232,30.00
Bill reference number 323131
''';

    debugPrint('=== Testing GCash Example 1 ===');
    final result1 = _parsePaymentData(gcashExample1);
    debugPrint('Result 1: $result1');

    debugPrint('=== Testing GCash Example 2 ===');
    final result2 = _parsePaymentData(gcashExample2);
    debugPrint('Result 2: $result2');

    debugPrint('=== Testing GoTyme Example ===');
    final result3 = _parsePaymentData(gotymeExample);
    debugPrint('Result 3: $result3');

    debugPrint('=== Testing PayMaya Example ===');
    final result4 = _parsePaymentData(paymayaExample);
    debugPrint('Result 4: $result4');
  }

  /// Clean up resources
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}

class PaymentData {
  final String referenceNumber;
  final String amount;
  final String extractedText;
  final bool success;
  final String? error;

  PaymentData({
    required this.referenceNumber,
    required this.amount,
    required this.extractedText,
    required this.success,
    this.error,
  });

  /// Get a user-friendly message about what was extracted
  String get extractionMessage {
    if (!success) {
      return error ?? 'Could not extract payment details';
    }

    final parts = <String>[];
    if (referenceNumber.isNotEmpty) {
      parts.add('Reference Number');
    }
    if (amount.isNotEmpty) {
      parts.add('Amount (₱$amount)');
    }

    if (parts.isEmpty) {
      return 'No payment details found';
    }

    return 'Extracted: ${parts.join(' and ')}';
  }

  /// Check if both reference and amount were found
  bool get isComplete => referenceNumber.isNotEmpty && amount.isNotEmpty;

  /// Check if at least one field was found
  bool get hasAnyData => referenceNumber.isNotEmpty || amount.isNotEmpty;

  @override
  String toString() {
    return 'PaymentData(ref: $referenceNumber, amount: $amount, success: $success)';
  }
}
