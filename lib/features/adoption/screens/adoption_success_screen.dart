import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';

import '../../../core/router/app_route.gr.dart';

/// Success screen shown after adoption application is submitted
@RoutePage()
class AdoptionSuccessScreen extends StatelessWidget {
  final String? petName;
  final String? applicationId;

  const AdoptionSuccessScreen({super.key, this.petName, this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Success Animation Area
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon with Animation
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade500,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Success Title
                      const PawsText(
                        'Application Submitted!',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: PawsColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Success Message
                      PawsText(
                        petName != null
                            ? 'Your adoption application for $petName has been successfully submitted!'
                            : 'Your adoption application has been successfully submitted!',
                        fontSize: 16,
                        color: PawsColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Information Cards
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Next Steps Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: PawsColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: PawsColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                color: PawsColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const PawsText(
                                'What happens next?',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: PawsColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const PawsText(
                            '• We\'ll review your application within 24-48 hours\n'
                            '• You\'ll receive updates via email and notifications\n'
                            '• If approved, we\'ll contact you to arrange a meet & greet',
                            fontSize: 14,
                            color: PawsColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PawsElevatedButton(
                      label: 'View My Applications',
                      onPressed: () {
                        // Navigate to profile screen
                        context.router.push(const AdoptionHistoryRoute());
                      },
                      icon: LucideIcons.fileText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: PawsOutlinedButton(
                      label: 'Back to Home',
                      onPressed: () {
                        // Navigate back to home by popping all screens
                        context.router.maybePop();
                      },
                      icon: LucideIcons.house,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
