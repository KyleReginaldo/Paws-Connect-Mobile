import 'package:flutter/material.dart';

import '../components/loading/dog_loading.dart';

class LoadingService {
  static bool _isShowing = false;

  /// Shows the dog loading dialog
  ///
  /// [context] - The build context to show the dialog in
  /// [message] - Optional custom message to display (defaults to "Walking the dog...")
  /// [barrierDismissible] - Whether the dialog can be dismissed by tapping outside (defaults to false)
  static Future<void> show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) async {
    if (_isShowing) return;

    _isShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,

      builder: (BuildContext context) {
        return PopScope(
          canPop: barrierDismissible,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(
                    // vertical: 8,
                    left: 10,
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicWidth(
                    child: DogLoading(message: message, showContainer: false),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _isShowing = false;
  }

  /// Dismisses the loading dialog
  ///
  /// [context] - The build context to dismiss the dialog from
  static void dismiss(BuildContext context) {
    if (_isShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isShowing = false;
    }
  }

  /// Checks if the loading dialog is currently showing
  static bool get isShowing => _isShowing;

  /// Shows loading dialog and executes an async operation
  /// Automatically dismisses the dialog when the operation completes
  ///
  /// [context] - The build context
  /// [operation] - The async operation to perform
  /// [message] - Optional custom loading message
  /// [barrierDismissible] - Whether the dialog can be dismissed by tapping outside
  ///
  /// Returns the result of the operation
  static Future<T> showWhileExecuting<T>(
    BuildContext context,
    Future<T> operation, {
    String? message,
    bool barrierDismissible = false,
  }) async {
    try {
      // Show loading
      unawaited(
        show(context, message: message, barrierDismissible: barrierDismissible),
      );

      // Execute operation
      final result = await operation;

      // Dismiss loading
      if (context.mounted) {
        dismiss(context);
      }

      return result;
    } catch (error) {
      // Dismiss loading even if operation fails
      if (context.mounted) {
        dismiss(context);
      }
      rethrow;
    } finally {
      if (context.mounted) {
        dismiss(context);
      }
    }
  }

  /// Helper method to avoid "unawaited_futures" warning
  static void unawaited(Future<void> future) {}
}
