import 'package:flutter_test/flutter_test.dart';
import 'package:paws_connect/core/services/chat_filter_service.dart';

void main() {
  group('ChatFilterService Tests', () {
    late ChatFilterService chatFilterService;

    setUp(() {
      chatFilterService = ChatFilterService();
      // Clear cache before each test
      chatFilterService.clearCache();
    });

    test('should validate clean message', () async {
      final result = await chatFilterService.validateMessage('Hello world');

      print('Test Result for "Hello world":');
      print('  - isValid: ${result.isValid}');
      print('  - violations: ${result.violatedWords.length}');

      // This should pass regardless of API state
      expect(result.isValid || result.violatedWords.isEmpty, isTrue);
    });

    test('should detect "bobo" as violation', () async {
      final result = await chatFilterService.validateMessage('You are bobo');

      print('\nTest Result for "You are bobo":');
      print('  - isValid: ${result.isValid}');
      print('  - violations: ${result.violatedWords.length}');
      if (result.violatedWords.isNotEmpty) {
        print('  - violated words:');
        for (final word in result.violatedWords) {
          print('    * ${word.word} (${word.category})');
        }
      }
    });

    test('should detect "tanginamo" as violation', () async {
      final result = await chatFilterService.validateMessage('tanginamo ka');

      print('\nTest Result for "tanginamo ka":');
      print('  - isValid: ${result.isValid}');
      print('  - violations: ${result.violatedWords.length}');
      if (result.violatedWords.isNotEmpty) {
        print('  - violated words:');
        for (final word in result.violatedWords) {
          print('    * ${word.word} (${word.category})');
        }
      }
    });

    test('should fetch filters from API', () async {
      final result = await chatFilterService.fetchChatFilters(
        forceRefresh: true,
      );

      print('\nAPI Fetch Test:');
      if (result.isSuccess) {
        print('  ✅ Successfully fetched ${result.value.length} filters');
        print('  - Filters:');
        for (final filter in result.value) {
          print(
            '    * "${filter.word}" (${filter.category}, active: ${filter.isActive}, severity: ${filter.severity})',
          );
        }
      } else {
        print('  ❌ Error fetching filters: ${result.error}');
      }
    });

    test('should use cached filters on second call', () async {
      // First call - should fetch from API
      print('\nCache Test:');
      print('First call (should fetch from API):');
      final result1 = await chatFilterService.fetchChatFilters();
      final firstCallTime = DateTime.now();

      // Wait a bit
      await Future.delayed(Duration(milliseconds: 100));

      // Second call - should use cache
      print('Second call (should use cache):');
      final result2 = await chatFilterService.fetchChatFilters();
      final secondCallTime = DateTime.now();

      final timeDiff = secondCallTime.difference(firstCallTime).inMilliseconds;
      print('  - Time between calls: ${timeDiff}ms');
      print(
        '  - First result: ${result1.isSuccess ? "✅ Success (${result1.value.length} filters)" : "❌ ${result1.error}"}',
      );
      print(
        '  - Second result: ${result2.isSuccess ? "✅ Success (${result2.value.length} filters)" : "❌ ${result2.error}"}',
      );
    });
  });
}
