// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/widgets/button.dart';

import '../../../core/theme/paws_theme.dart';

@RoutePage()
class PaymentSuccessScreen extends StatelessWidget {
  final int id;
  const PaymentSuccessScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsColors.background,
      body: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.85,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: PawsColors.success, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for your donation. Your support helps us make a difference!',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PawsElevatedButton(
                label: 'Go to Home',
                isFullWidth: false,
                icon: LucideIcons.house,
                borderRadius: 8,
                onPressed: () => context.router.popUntilRoot(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
