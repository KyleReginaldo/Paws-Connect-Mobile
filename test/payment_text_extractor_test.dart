import 'package:flutter_test/flutter_test.dart';
import 'package:paws_connect/features/payment/services/payment_text_extractor.dart';

void main() {
  group('PaymentTextExtractor.parseFromRawText', () {
    test('PayMaya bill receipt', () {
      const text = '''
Paid bill
Maya Bank
614652616838
- ₱5,402.58
Completed
Bill amount ₱5,402.58
Biller's fee ₱0.00
Transaction details
Bill reference number 528601566179
''';
      final data = PaymentTextExtractor.parseFromRawText(text);
      expect(data.success, isTrue);
      expect(data.amount, anyOf('5402.58', '5402.58'));
      expect(data.referenceNumber, '528601566179');
    });

    test('GoTyme transfer', () {
      const text = '''
Transfer amount ₱300.00
Fee ₱0.00
Total ₱300.00
Trace ID 228012
Reference No. ITO251017091228012
Date 17 Oct 2025 at 5:12 PM
''';
      final data = PaymentTextExtractor.parseFromRawText(text);
      expect(data.success, isTrue);
      expect(data.amount, '300');
      expect(data.referenceNumber, startsWith('ITO'));
    });

    test('GCash transfer with 13-digit ref', () {
      const text = '''
Amount -600.00
Reference Number 0033415944973
''';
      final data = PaymentTextExtractor.parseFromRawText(text);
      expect(data.success, isTrue);
      expect(data.amount, '600');
      expect(data.referenceNumber, '0033415944973');
    });

    test('GCash load with 9-digit ref', () {
      const text = '''
DATA 50
Paid via GCash
Amount 50.00
Total ₱50.00
Date Oct 17, 2025 5:20 PM
Reference No. 033915917
''';
      final data = PaymentTextExtractor.parseFromRawText(text);
      expect(data.success, isTrue);
      expect(data.amount, anyOf('50', '50.00'));
      expect(data.referenceNumber.endsWith('033915917'), isTrue);
    });
  });
}
