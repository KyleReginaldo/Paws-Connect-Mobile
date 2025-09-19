// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:paws_connect/features/donation/repository/donation_repository.dart';
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
  final String id;
  const ProfileScreen({super.key, required this.id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<AuthRepository>()),
        ChangeNotifierProvider.value(value: sl<AdoptionRepository>()),
        ChangeNotifierProvider.value(value: sl<DonationRepository>()),
      ],
      child: this,
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  late RealtimeChannel profileChannel;

  void listenToChanges() {
    profileChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.id,
          ),
          callback: (payload) {
            // Instant update without delay
            context.read<ProfileRepository>().fetchVisitedProfile(widget.id);
          },
        )
        .subscribe();
  }

  @override
  void initState() {
    profileChannel = supabase.channel('public:users:id=eq.${widget.id}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ProfileRepository>();
      repo.fetchVisitedProfile(widget.id);
      context.read<AdoptionRepository>().fetchUserAdoptions(widget.id);
      context.read<DonationRepository>().fetchUserDonations(widget.id);
      listenToChanges();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProfileRepository>();
    final visited = repo.visitedProfile;
    final isLoading = context.watch<ProfileRepository>().visitedProfileLoading;
    final adoptions = context.select(
      (AdoptionRepository bloc) => bloc.adoptions,
    );
    final donations = context.select(
      (DonationRepository bloc) => bloc.donations,
    );
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Column(
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
                        child: visited?.profileImageLink == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: PawsColors.primary,
                              )
                            : ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: visited!.profileImageLink!,
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
                            visited?.username ?? 'Loading',
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
                                visited?.status ?? 'ACTIVE',
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: PawsText(
                              visited?.status.toUpperCase() ?? 'ACTIVE',
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(
                                visited?.status ?? "ACTIVE",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Email
                      PawsText(
                        visited?.email ?? "Loading",
                        fontSize: 12,
                        color: PawsColors.textSecondary,
                      ),
                      const SizedBox(height: 12),

                      // Edit Profile Button - positioned under email
                      if (widget.id == USER_ID) ...{
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

                        const SizedBox(height: 12),
                      },
                      // Phone Number
                      _buildInfoRow(
                        icon: LucideIcons.phone,
                        label: 'Phone Number',
                        value: visited?.phoneNumber ?? 'Loading',
                      ),
                      const SizedBox(height: 12),
                      // User Role
                      _buildInfoRow(
                        icon: LucideIcons.idCard,
                        label: 'Role',
                        value: _getRoleText(visited?.role ?? 1),
                      ),
                      const SizedBox(height: 12),
                      // Member Since
                      _buildInfoRow(
                        icon: LucideIcons.calendar,
                        label: 'Member Since',
                        value: _formatDate(
                          visited?.createdAt ?? DateTime.now().toString(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: LucideIcons.history,
                        label: 'Adoption History',
                        value: '${adoptions?.length ?? 0} adoption(s)',
                        onTap: () {
                          context.router.push(AdoptionHistoryRoute());
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: LucideIcons.handHelping,
                        label: 'Donation History',
                        value: '${donations?.length ?? 0} donation(s)',
                        onTap: () {
                          context.router.push(DonationHistoryRoute());
                        },
                      ),
                    ],
                  ),
                  if (widget.id == USER_ID) ...{
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
                            context.read<AuthRepository>().signOut().then((
                              _,
                            ) async {
                              if (!mounted) return;
                              await OneSignal.logout();
                              context.router.replaceAll([MainRoute()]);
                            });
                          },
                          cancelLabel: 'Cancel',
                        );
                      },
                    ),
                  },
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PawsColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: PawsColors.primary),
          ),
          const SizedBox(width: 8),
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
      ),
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
