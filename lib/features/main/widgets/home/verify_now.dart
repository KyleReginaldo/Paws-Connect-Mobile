// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/paws_theme.dart';
import '../../../../core/widgets/button.dart';
import '../../../../core/widgets/text.dart';

class VerifyNow extends StatelessWidget {
  final Function()? onTap;
  const VerifyNow({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PawsText(
                  'Verify your account',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                PawsText(
                  'Tap to complete your profile verification',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                SizedBox(height: 10),
                PawsElevatedButton(
                  label: 'Verify Now',
                  isFullWidth: false,
                  borderRadius: 6,
                  icon: LucideIcons.userCheck,
                  backgroundColor: Colors.white,
                  foregroundColor: PawsColors.primary,
                  size: 14,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
          Image.asset('assets/images/verification.png', height: 128),
        ],
      ),
    );
  }
}
