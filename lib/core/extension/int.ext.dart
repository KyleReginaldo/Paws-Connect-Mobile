import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DoubleExt on double {
  double progress(double targetAmount) {
    if (targetAmount <= 0) return 0.0; // avoid division by zero
    final result = this / targetAmount;
    if (result.isNaN || result.isInfinite) return 0.0; // avoid NaN/Infinity
    return result.clamp(0.0, 1.0);
  }

  int get percentage {
    if (isNaN || isInfinite) return 0; // avoid NaN/Infinity
    return (this * 100).round();
  }

  String get fee {
    if (isNaN || isInfinite) return '0.00'; // avoid NaN/Infinity
    return (this * 0.025).toStringAsFixed(2);
  }

  String get totalWithFee {
    if (isNaN || isInfinite) return '0.00'; // avoid NaN/Infinity
    return (this + (this * 0.025)).toStringAsFixed(2);
  }

  String displayMoney() {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }
}

extension StringExt on String {
  int get toPaymongoAmount {
    if (!contains('.')) {
      '$this.00';
    }
    final parsed = double.tryParse(this) ?? 0.0;
    if (parsed.isNaN || parsed.isInfinite) return 0; // avoid NaN/Infinity
    return (parsed * 100).round();
  }

  String get firstName => split(' ').first;
  String get lastName => split(' ').length > 1 ? split(' ').last : '';
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  Color get color {
    switch (this) {
      case 'PENDING':
        return Colors.orange;
      case 'ONGOING':
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey.shade600;
    }
  }
}

extension IntExt on int {
  double get toRealAmount => this / 100;
}

extension DateTimeExt on DateTime {
  String daysLeftText() {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) {
      return "Expired";
    } else if (difference.inDays == 0) {
      return "Today";
    } else {
      return "${difference.inDays} days left";
    }
  }
}
