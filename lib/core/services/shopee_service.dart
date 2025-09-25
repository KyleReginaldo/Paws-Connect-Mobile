import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<String?> scrapeProductImageWithHeadless(String url) async {
  Completer<String?> completer = Completer<String?>();
  HeadlessInAppWebView headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(url)),
    onWebViewCreated: (controller) {
      // You can inject JavaScript here if needed
    },
    onLoadStop: (controller, url) async {
      // Wait a moment for dynamic content to load
      await Future.delayed(const Duration(seconds: 3));

      // Extract the product image using JavaScript
      String? imageUrl =
          await controller.evaluateJavascript(
                source:
                    'document.querySelector(\'img[data-testid="product-image"]\')?.src;',
              )
              as String?;
      debugPrint('Extracted image URL: $imageUrl');
      if (!completer.isCompleted) {
        completer.complete(imageUrl);
      }
    },
    onConsoleMessage: (controller, consoleMessage) {
      print(consoleMessage.message);
    },
  );

  await headlessWebView.run();

  return completer.future;
}
