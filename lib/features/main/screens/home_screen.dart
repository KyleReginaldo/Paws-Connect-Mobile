// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/enum/user.enum.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:paws_connect/features/donation/repository/donation_repository.dart';
import 'package:paws_connect/features/events/repository/event_repository.dart';
import 'package:paws_connect/features/google_map/repository/address_repository.dart';
import 'package:paws_connect/features/main/screens/search_delegate.dart';
import 'package:paws_connect/features/main/widgets/home/adoption_overview.dart';
import 'package:paws_connect/features/main/widgets/home/event_post_list.dart';
import 'package:paws_connect/features/main/widgets/home/verify_now.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/mixins/tutorial_target_mixin.dart';
import '../../../core/provider/common_provider.dart';
import '../../../core/repository/common_repository.dart';
import '../../../core/services/loading_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/tutorial_service.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
import '../../favorite/repository/favorite_repository.dart';
import '../../fundraising/repository/fundraising_repository.dart';
import '../../notifications/repository/notification_repository.dart';
import '../../profile/repository/profile_repository.dart';
import '../widgets/app_bar.dart';
import '../widgets/fundraising_container.dart';
import '../widgets/pet_container.dart';

@RoutePage()
class HomeScreen extends StatefulWidget implements AutoRouteWrapper {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<PetRepository>()),
        ChangeNotifierProvider.value(value: sl<AuthRepository>()),
        ChangeNotifierProvider.value(value: sl<FundraisingRepository>()),
        ChangeNotifierProvider.value(value: sl<AddressRepository>()),
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<FavoriteRepository>()),
        ChangeNotifierProvider.value(value: sl<NotificationRepository>()),
        ChangeNotifierProvider.value(value: sl<AdoptionRepository>()),
        ChangeNotifierProvider.value(value: sl<DonationRepository>()),

        ChangeNotifierProvider.value(value: sl<EventRepository>()),
        ChangeNotifierProvider.value(value: sl<CommonRepository>()),
      ],
      child: this,
    );
  }
}

class _TopDonorChip extends StatelessWidget {
  const _TopDonorChip({
    required this.username,
    required this.rank,
    required this.id,
    this.profileImageLink,
  });

  final String username;
  final int rank;
  final String id;
  final String? profileImageLink;

  Color _rankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade500;
      default:
        return PawsColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rankColor(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: PawsText(
              '$rank',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          profileImageLink != null
              ? ClipOval(
                  child: NetworkImageView(
                    profileImageLink!,
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(LucideIcons.crown, size: 16, color: color),
          SizedBox(width: 6),
          PawsText(
            username,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> with TutorialTargetMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final petChannel = supabase.channel('public:pets');
  final userIdentificationChannel = supabase.channel(
    'public:user_identification:user=eq.$USER_ID',
  );
  final userChannel = supabase.channel('public:users');
  final eventChannel = supabase.channel('public:events');
  final commentChannel = supabase.channel('public:event_comments');
  final memberChannel = supabase.channel('public:event_members');

  final OverlayPortalController overlayController = OverlayPortalController();
  final fundraisingChannel = supabase.channel('public:fundraising');
  late RealtimeChannel addressChannel;
  bool _onboardingScheduled = false;
  void handleDeleteAddress(int addressId) async {
    try {
      await LoadingService.showWhileExecuting(
        context,
        _deleteAddressOperation(addressId),
        message: 'Deleting address...',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete address')),
        );
      }
    }
  }

  Future<void> _deleteAddressOperation(int addressId) async {
    final result = await CommonProvider().deleteAddress(addressId);
    if (!result.isSuccess) {
      throw Exception('Failed to delete address');
    }
    if (mounted) {
      context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
      context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
    }
  }

  Future<void> _setDefaultAddressOperation(int addressId) async {
    final result = await CommonProvider().setDefaultAddress(
      USER_ID ?? '',
      addressId,
    );
    if (!result.isSuccess) {
      throw Exception('Failed to set default address');
    }
    if (mounted) {
      context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
      context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
    }
  }

  void handleSetDefaultAddress(int addressId) async {
    try {
      await LoadingService.showWhileExecuting(
        context,
        _setDefaultAddressOperation(addressId),
        message: 'Setting default address...',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address set as default successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set default address')),
        );
      }
    }
  }

  void initializeChannels() {
    addressChannel = supabase.channel('public:address:users=eq.$USER_ID');
  }

  void handleListeners() {
    debugPrint('USER ID: $USER_ID');
    final notificationsChannel = supabase.channel('public:notifications');
    notificationsChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user',
            value: USER_ID,
          ),
          callback: (payload) {
            if (USER_ID != null) {
              context.read<NotificationRepository>().fetchNotifications(
                USER_ID!,
              );
            }
          },
        )
        .subscribe();
    userIdentificationChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_identification',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user',
            value: USER_ID,
          ),
          callback: (payload) {
            if (USER_ID != null) {
              context.read<ProfileRepository>().fetchUserProfile(USER_ID!);
            }
          },
        )
        .subscribe();
    userChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            if (USER_ID != null) {
              context.read<ProfileRepository>().fetchUserProfile(USER_ID!);
            }
          },
        )
        .subscribe();
    petChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pets',
          callback: (payload) {
            context.read<PetRepository>().fetchPets(userId: USER_ID);
          },
        )
        .subscribe();
    fundraisingChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'fundraising',
          callback: (payload) {
            context.read<FundraisingRepository>().fetchFundraisings();
          },
        )
        .subscribe();
    eventChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'events',
          callback: (payload) {
            context.read<EventRepository>().fetchEvents();
          },
        )
        .subscribe();
    commentChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'event_comments',
          callback: (payload) {
            context.read<EventRepository>().fetchEvents();
          },
        )
        .subscribe();
    memberChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'event_members',
          callback: (payload) {
            context.read<EventRepository>().fetchEvents();
          },
        )
        .subscribe();
    addressChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'address',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'users',
            value: USER_ID,
          ),
          callback: (payload) {
            context.read<AddressRepository>().fetchDefaultAddress(
              USER_ID ?? '',
            );
            context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
          },
        )
        .subscribe();
  }

  void _toggleFavorite(int petId, bool isCurrentlyFavorite) async {
    if (USER_ID == null || (USER_ID?.isEmpty ?? true)) {
      if (!mounted) return;
      context.router.push(
        SignInRoute(
          onResult: (success) async {
            if (!success) return;
            await SessionManager.bootstrapAfterSignIn(eager: false);
            if (!mounted) return;
            context.read<PetRepository>().refetchRecentPets(userId: USER_ID);
          },
        ),
      );
      return;
    }

    final petRepo = context.read<PetRepository>();
    try {
      await sl<FavoriteRepository>().toggleFavorite(petId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
        ),
      );
    } catch (e) {
      petRepo.updatePetFavorite(petId, isCurrentlyFavorite);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite')),
      );
    }
  }

  @override
  void initState() {
    initializeChannels();
    handleListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PetRepository>().fetchRecentPets(userId: USER_ID);
        context.read<FundraisingRepository>().fetchFundraisings();
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
        context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
        context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
        context.read<AdoptionRepository>().fetchUserAdoptions(USER_ID ?? '');
        context.read<EventRepository>().fetchEvents();
        context.read<DonationRepository>().fetchDonorLeaderboard();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    petChannel.unsubscribe();
    fundraisingChannel.unsubscribe();
    addressChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentPets = context.watch<PetRepository>().recentPets;
    final petError = context.select((PetRepository bloc) => bloc.errorMessage);
    final adoptions = context.select(
      (AdoptionRepository bloc) => bloc.adoptions,
    );
    final fundraisings = context.select(
      (FundraisingRepository bloc) => bloc.fundraisings,
    );
    final fundraisingError = context.select(
      (FundraisingRepository bloc) => bloc.errorMessage,
    );
    final fundraisingLoading = context.select(
      (FundraisingRepository bloc) => bloc.isLoading,
    );
    final petLoading = context.select((PetRepository bloc) => bloc.isLoading);
    final defaultAddress = context.select(
      (AddressRepository bloc) => bloc.defaultAddress,
    );
    final addressError = context.select(
      (AddressRepository bloc) => bloc.errorMessage,
    );
    final addresses = context.select(
      (AddressRepository bloc) => bloc.addresses,
    );
    final topDonors = context.watch<DonationRepository>().leaderboard;
    final user = context.watch<ProfileRepository>().userProfile;
    final events = context.watch<EventRepository>().events;
    // Launch onboarding tutorial once for users who are not onboarded yet
    if (user != null && user.onboarded == false && !_onboardingScheduled) {
      _onboardingScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        // Small delay to ensure targets are laid out
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        final keys = getTutorialKeys();
        TutorialService.startTutorial(
          context,
          targetKeys: keys,
          onComplete: () {
            // TutorialService internally sets onboarded=true
          },
          onSkip: () {
            // No-op
          },
        );
      });
    }
    debugPrint('may laman ba yung events: ${events?.length}');
    return Scaffold(
      key: scaffoldKey,
      appBar: HomeAppBar(
        onProfileTap: () {
          if (USER_ID == null || (USER_ID?.isEmpty ?? true)) {
            context.router.push(
              SignInRoute(
                onResult: (success) async {
                  if (!success) return;
                  await SessionManager.bootstrapAfterSignIn(eager: false);
                  if (context.mounted &&
                      USER_ID != null &&
                      USER_ID!.isNotEmpty) {
                    context.router.push(ProfileRoute(id: USER_ID!));
                  }
                },
              ),
            );
          } else {
            context.router.push(ProfileRoute(id: USER_ID!));
          }
        },
        address: defaultAddress,
        profile: user,
        locationButtonKey: locationButtonKey,
        notificationsButtonKey: notificationsButtonKey,
        profileButtonKey: profileButtonKey,
        onOpenCurrentLocation: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white),
                width: MediaQuery.sizeOf(context).width,
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PawsText(
                        'Select Address',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 10),
                      if (addresses != null)
                        Column(
                          spacing: 8,
                          children: addresses.map((e) {
                            return ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  handleSetDefaultAddress(e.id);
                                },
                                child: Container(
                                  height: 18,
                                  width: 18,
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color: PawsColors.primary,
                                    ),
                                  ),
                                  child: e.isDefault
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: PawsColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              title: PawsText(e.fullAddress),
                              trailing: e.isDefault
                                  ? null
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        handleDeleteAddress(e.id);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: PawsColors.error.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: PawsText(
                                          'Delete',
                                          fontSize: 12,
                                          color: PawsColors.error,
                                        ),
                                      ),
                                    ),
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 10),

                      PawsTextButton(
                        label: 'Add New Address',
                        icon: LucideIcons.mapPlus,
                        onPressed: () {
                          Navigator.pop(context);
                          context.router.push(MapRoute());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      body: RefreshTrigger(
        onRefresh: () async {
          context.read<PetRepository>().fetchRecentPets(userId: USER_ID);
          context.read<FundraisingRepository>().fetchFundraisings();
          context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
          context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
          context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
          context.read<AdoptionRepository>().fetchUserAdoptions(USER_ID ?? "");
          context.read<EventRepository>().fetchEvents();
        },
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user?.userIdentification != null &&
                    user!.userIdentification?.status == 'PENDING') ...{
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            'Your verification is currently pending. We will notify you once it is approved.',
                            color: Colors.blueAccent.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                },
                if (user?.houseImages == null ||
                    user!.houseImages!.isEmpty) ...{
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PawsColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: PawsColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PawsText(
                                'Adding house images can increase your chances of successful adoptions. Please consider uploading some photos of your home.',
                                color: PawsColors.primary,
                                fontSize: 13,
                              ),
                              PawsElevatedButton(
                                label: 'Add Now',
                                isFullWidth: false,
                                size: 14,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                borderRadius: 4,
                                textStyle: TextStyle()
                                  ..copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                icon: LucideIcons.housePlus,
                                onPressed: () {
                                  context.router.push(UserHouseRoute());
                                },
                              ),
                            ],
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/svg/houses.svg',
                          height: 100,
                          width: 100,
                        ),
                      ],
                    ),
                  ),
                },
                if (user?.status == UserStatus.PENDING &&
                    user?.userIdentification == null)
                  VerifyNow(
                    onTap: () {
                      context.router.push(SetUpVerificationRoute());
                    },
                  ),
                if (topDonors != null && topDonors.isNotEmpty) ...{
                  // Section header
                  Row(
                    children: [
                      Icon(
                        LucideIcons.crown,
                        size: 18,
                        color: Colors.amber.shade700,
                      ),
                      SizedBox(width: 6),
                      PawsText(
                        'Top Donors',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: 6),
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 6,
                      //     vertical: 2,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.amber.withValues(alpha: 0.15),
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.favorite,
                      //         size: 12,
                      //         color: Colors.amber.shade700,
                      //       ),
                      //       SizedBox(width: 4),
                      //       PawsText(
                      //         'Thank you',
                      //         fontSize: 10,
                      //         color: Colors.amber.shade800,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: topDonors.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final donor = topDonors[index];
                        return _TopDonorChip(
                          username: donor.user.username,
                          rank: donor.rank,
                          id: donor.user.id,
                          profileImageLink: donor.user.profileImageLink,
                        );
                      },
                    ),
                  ),
                },
                PawsSearchBar(
                  key: searchFieldKey,
                  hintText: 'Search for pets...',
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: PetSearchDelegate(repo: sl<PetRepository>()),
                    );
                  },
                ),
                if (events != null && events.isNotEmpty) ...{
                  EventPostList(
                    overlayController: overlayController,
                    events: events,
                  ),
                },

                if (addressError != null) ...{
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_off,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            'Please set a default address to enable location features.',
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                },

                if (user?.status != UserStatus.INDEFINITE &&
                    user?.status != UserStatus.PENDING &&
                    adoptions != null &&
                    adoptions.isNotEmpty) ...{
                  AdoptionOverview(
                    key: adoptionOverviewKey,
                    adoptions: adoptions,
                  ),
                },
                if (recentPets != null) ...{
                  PawsText(
                    'Recently added',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                },

                if (petError != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            petError,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  petLoading
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 10,
                            children: List.generate(3, (_) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade300,
                                ),
                                height: 120,
                                width: MediaQuery.sizeOf(context).width * 0.30,
                                margin: EdgeInsets.only(bottom: 10),
                              );
                            }),
                          ),
                        )
                      : recentPets != null
                      ? SingleChildScrollView(
                          key: recentPetsKey,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 10,
                            children: List.generate(
                              recentPets.length,
                              (index) => PetContainer(
                                pet: recentPets[index],
                                onFavoriteToggle: (petId) {
                                  _toggleFavorite(
                                    petId,
                                    !(recentPets[index].isFavorite ?? false),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                if (!fundraisingLoading &&
                    (fundraisings != null || fundraisingError != null))
                  PawsText(
                    'Active Fundraising',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                if (fundraisingError != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            fundraisingError,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  fundraisingLoading
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade300,
                          ),
                          height: 120,
                          width: MediaQuery.sizeOf(context).width * 0.90,
                          margin: EdgeInsets.only(bottom: 10),
                        )
                      : SingleChildScrollView(
                          key: fundraisingListKey,
                          physics: PageScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children:
                                fundraisings == null && fundraisingError == null
                                ? [
                                    Center(
                                      child: PawsText('No fundraisings found'),
                                    ),
                                  ]
                                : fundraisings != null
                                ? List.generate(
                                    fundraisings.length,
                                    (index) => FundraisingContainer(
                                      fundraising: fundraisings[index],
                                    ),
                                  )
                                : [],
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
