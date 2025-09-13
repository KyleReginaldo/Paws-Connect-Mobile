import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/global_confirm_dialog.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
import '../../auth/repository/auth_repository.dart';
import '../../internet/internet.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<AuthRepository>()),
      ],
      child: this,
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  RealtimeChannel profileChannel = supabase.channel(
    'public:users:id=eq.$USER_ID',
  );

  void listenToChanges() {
    profileChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: USER_ID,
          ),
          callback: (payload) {
            // Instant update without delay
            context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
          },
        )
        .subscribe();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ProfileRepository>();
      repo.fetchUserProfile(USER_ID ?? "");
      listenToChanges();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProfileRepository>();
    final user = repo.userProfile;
    final isLoading = user == null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const PawsText(
          'Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(PawsColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: PawsColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PawsColors.primary.withValues(alpha: 0.2),
                              width: 3,
                            ),
                          ),
                          child: user.profileImageLink == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: PawsColors.primary,
                                )
                              : ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.profileImageLink!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,

                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                PawsColors.primary,
                                              ),
                                        ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 50,
                                      color: PawsColors.primary,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Username
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            PawsText(
                              user.username,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: PawsColors.textPrimary,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  user.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: PawsText(
                                user.status.toUpperCase(),
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(user.status),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Email
                        PawsText(
                          user.email,
                          fontSize: 12,
                          color: PawsColors.textSecondary,
                        ),
                        const SizedBox(height: 12),

                        // Edit Profile Button - positioned under email
                        PawsElevatedButton(
                          label: 'Edit Profile',
                          icon: LucideIcons.pencil,
                          onPressed: () {
                            context.router.push(EditProfileRoute());
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          size: 12,
                          backgroundColor: PawsColors.textPrimary,
                          isFullWidth: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // User Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PawsText(
                          'Account Information',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PawsColors.textPrimary,
                        ),
                        const SizedBox(height: 12),
                        // Phone Number
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: user.phoneNumber,
                        ),
                        const SizedBox(height: 12),
                        // User Role
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Role',
                          value: _getRoleText(user.role),
                        ),
                        const SizedBox(height: 12),
                        // Member Since
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Member Since',
                          value: _formatDate(user.createdAt),
                        ),

                        if (user.paymentMethod != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.payment_outlined,
                            label: 'Payment Method',
                            value: user.paymentMethod!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // House Images Section (if available)
                  if (user.houseImages != null &&
                      user.houseImages!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PawsText(
                            'House Images',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PawsColors.textPrimary,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: user.houseImages!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 80,
                                  margin: EdgeInsets.only(
                                    right: index != user.houseImages!.length - 1
                                        ? 12
                                        : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        user.houseImages![index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  PawsTextButton(
                    label: 'Sign Out',
                    foregroundColor: PawsColors.error,
                    onPressed: () async {
                      await showGlobalConfirmDialog(
                        context,
                        title: 'Sign Out',
                        message: 'Are you sure you want to sign out?',
                        confirmLabel: 'Sign Out',
                        onConfirm: () async {
                          final isConnected = context
                              .read<InternetProvider>()
                              .isConnected;
                          if (!isConnected) {
                            Navigator.pop(context);
                            EasyLoading.showToast(
                              'You currently are offline',
                              toastPosition: EasyLoadingToastPosition.top,
                            );
                            return;
                          }

                          Navigator.pop(context);
                          context.read<AuthRepository>().signOut();
                          await OneSignal.logout();
                          context.router.replacePath('/');
                        },
                        cancelLabel: 'Cancel',
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PawsColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: PawsColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PawsText(
                label,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PawsColors.textSecondary,
              ),
              const SizedBox(height: 2),
              PawsText(
                value,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return PawsColors.primary;
    }
  }

  String _getRoleText(int role) {
    switch (role) {
      case 1:
        return 'Administrator';
      case 2:
        return 'Staff';
      case 3:
        return 'Regular User';
      case 4:
        return 'Volunteer';
      default:
        return 'User';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
