import 'dart:io';

import 'package:http/http.dart' as http;

class NetworkUtils {
  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection reset by peer')) {
      return 'Network connection lost. Please check your internet connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('socketexception')) {
      return 'Network error. Please check your connection.';
    } else if (errorString.contains('handshake')) {
      return 'Secure connection failed. Please try again.';
    } else if (errorString.contains('network is unreachable')) {
      return 'Network is unreachable. Please check your internet connection.';
    } else if (errorString.contains('host lookup failed')) {
      return 'Cannot reach server. Please check your internet connection.';
    } else {
      return 'Network error occurred. Please try again.';
    }
  }

  /// Check if error is a network-related error that should trigger retry
  static bool isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    return errorString.contains('connection reset by peer') ||
        errorString.contains('timeout') ||
        errorString.contains('socketexception') ||
        errorString.contains('handshake') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('host lookup failed');
  }

  /// Make HTTP request with retry logic
  static Future<http.Response> makeRequestWithRetry({
    required Future<http.Response> Function() request,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await request();
      } catch (e) {
        if (attempt == maxRetries - 1 || !isRetryableError(e)) {
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(retryDelay * (attempt + 1));
      }
    }

    throw Exception('Request failed after $maxRetries attempts');
  }

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Get optimized headers for mobile connections
  static Map<String, String> getMobileOptimizedHeaders() {
    return {
      'Connection': 'keep-alive',
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip, deflate',
      'Cache-Control': 'no-cache',
      'User-Agent': 'PawsConnect/1.0 (Mobile)',
      // Mobile-specific optimizations
      'Keep-Alive': '300',
      'Accept-Language': 'en-US,en;q=0.5',
    };
  }

  /// Make optimized request for mobile data connections
  static Future<http.Response> makeMobileOptimizedRequest({
    required Uri uri,
    int maxRetries = 2, // Reduced retries for mobile
    Duration timeout = const Duration(
      seconds: 20,
    ), // Shorter timeout for mobile
  }) async {
    return makeRequestWithRetry(
      request: () => http
          .get(uri, headers: getMobileOptimizedHeaders())
          .timeout(
            timeout,
            onTimeout: () => throw Exception('Request timeout'),
          ),
      maxRetries: maxRetries,
      retryDelay: const Duration(milliseconds: 1500), // Faster retry for mobile
    );
  }

  /// Test network speed/quality (useful for debugging mobile data issues)
  static Future<NetworkQuality> testNetworkQuality() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Test with a small, reliable endpoint
      final response = await http
          .get(
            Uri.parse('https://httpbin.org/json'),
            headers: getMobileOptimizedHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200 && latency < 1000) {
        return NetworkQuality.good;
      } else if (latency < 3000) {
        return NetworkQuality.moderate;
      } else {
        return NetworkQuality.poor;
      }
    } catch (e) {
      return NetworkQuality.offline;
    }
  }
}

enum NetworkQuality { good, moderate, poor, offline }
