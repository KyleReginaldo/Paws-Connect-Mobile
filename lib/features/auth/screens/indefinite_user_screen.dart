import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/session/session_manager.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';

@RoutePage()
class IndefiniteUserScreen extends StatefulWidget {
  const IndefiniteUserScreen({super.key});

  @override
  State<IndefiniteUserScreen> createState() => _IndefiniteUserScreenState();
}

class _IndefiniteUserScreenState extends State<IndefiniteUserScreen> {
  late RealtimeChannel userChannel;

  void listenToStatus() {
    if (USER_ID == null) {
      context.router.replaceAll([SignInRoute()]);
      return;
    }
    userChannel = supabase.channel('public:users:id=eq.$USER_ID');
    userChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: USER_ID,
          ),
          callback: (value) {
            String status = value.newRecord['status'];
            if (!mounted) return;
            if (status != 'INDEFINITE') {
              context.router.replaceAll([MainRoute()]);
            }
          },
        )
        .subscribe();
  }

  @override
  void initState() {
    super.initState();
    listenToStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large warning icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: PawsColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PawsColors.error.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  LucideIcons.userX,
                  size: 60,
                  color: PawsColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              PawsText(
                'Account Suspended',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: PawsColors.error,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              PawsText(
                'Your account has been indefinitely suspended and you cannot access the application at this time.',
                fontSize: 16,
                color: PawsColors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Additional info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PawsColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PawsColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.info,
                          size: 20,
                          color: PawsColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            'If you believe this is an error, please contact our support team for assistance.',
                            fontSize: 14,
                            color: PawsColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Sign out button
              SizedBox(
                width: double.infinity,
                child: PawsElevatedButton(
                  label: 'Sign Out',
                  backgroundColor: PawsColors.error,
                  onPressed: () async {
                    await SessionManager.signOutAndClear();
                    if (context.mounted) {
                      context.router.replaceAll([SignInRoute()]);
                    }
                  },
                  borderRadius: 12,
                ),
              ),

              const SizedBox(height: 16),

              // Contact support button
              SizedBox(
                width: double.infinity,
                child: PawsOutlinedButton(
                  label: 'Contact Support',
                  borderColor: PawsColors.error,
                  onPressed: () {
                    context.router.push(ContactSupportRoute());
                  },
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
