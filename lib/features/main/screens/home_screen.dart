// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/enum/user.enum.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:paws_connect/features/donation/repository/donation_repository.dart';
import 'package:paws_connect/features/events/repository/event_repository.dart';
import 'package:paws_connect/features/google_map/models/address_model.dart';
import 'package:paws_connect/features/google_map/repository/address_repository.dart';
import 'package:paws_connect/features/main/repository/home_repository.dart';
import 'package:paws_connect/features/main/repository/position_repository.dart';
import 'package:paws_connect/features/main/screens/search_delegate.dart';
import 'package:paws_connect/features/main/widgets/home/adoption_overview.dart';
import 'package:paws_connect/features/main/widgets/home/event_post_list.dart';
import 'package:paws_connect/features/main/widgets/home/verify_now.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/mixins/tutorial_target_mixin.dart';
import '../../../core/provider/common_provider.dart';
import '../../../core/repository/common_repository.dart';
import '../../../core/services/loading_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/tutorial_service.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/transfer_object/address.dto.dart';
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
        // Persist stateful repos across hot reloads using DI singletons
        ChangeNotifierProvider.value(value: sl<PositionRepository>()),
        ChangeNotifierProvider.value(value: sl<HomeRepository>()),
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
  final donationChannel = supabase.channel('public:donations');

  late RealtimeChannel addressChannel;
  bool _onboardingScheduled = false;

  // Current location variables
  // Position? _currentPosition;
  String? _currentLocationAddress;
  bool _isLoadingLocation = false;
  String? _locationError;

  // Simplified: single method to apply current location (reuse or create)
  Future<void> _applyCurrentLocation() async {
    if (_isLoadingLocation) return;
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    try {
      // Services & permission
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services disabled.';
          _isLoadingLocation = false;
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission denied.';
          _isLoadingLocation = false;
        });
        return;
      }
      // Position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      // Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String resolvedAddress = 'Current location';
      Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;
      if (place != null) {
        final parts = [
          place.street,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.country,
        ].whereType<String>().where((s) => s.isNotEmpty).toList();
        if (parts.isNotEmpty) {
          resolvedAddress = parts.join(', ');
        }
      }
      // Reuse or create
      if (USER_ID != null && USER_ID!.isNotEmpty) {
        final repo = context.read<AddressRepository>();
        final list = repo.addresses ?? [];
        Address? near;
        for (final a in list) {
          if (a.latitude != null && a.longitude != null) {
            final d = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              a.latitude!,
              a.longitude!,
            );
            if (d <= 50) {
              near = a;
              break;
            }
          }
        }
        if (near != null && mounted) {
          debugPrint('Setting default address to: ${near.id}');

          // Set existing as default if not already
          if (!near.isDefault) {
            await LoadingService.showWhileExecuting(
              context,
              _setDefaultAddressOperation(near.id),
              message: 'Setting default address...',
            );
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Used nearby saved address.')),
              );
            }
          } else {
            if (mounted) {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Already using nearby address.')),
              );
            }
          }
        } else {
          await LoadingService.showWhileExecuting(
            context,
            CommonProvider().addAddress(
              AddAddressDTO(
                street: place?.street ?? '',
                city: place?.locality ?? place?.subAdministrativeArea ?? '',
                state: place?.administrativeArea ?? '',
                zipCode: place?.postalCode ?? '',
                latitude: position.latitude,
                longitude: position.longitude,
                user: USER_ID!,
                isDefault: repo.defaultAddress == null, // first becomes default
              ),
            ),
            message: 'Saving address...',
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Location saved.')));
          }
        }
        // Refresh repository after changes
        await repo.fetchDefaultAddress(USER_ID!);
        await repo.fetchAllAddresses(USER_ID!);
      }
      setState(() {
        _currentLocationAddress = resolvedAddress;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location.';
        _isLoadingLocation = false;
      });
    }
  }

  void _listenOnCurrentPosition() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      debugPrint(
        'Current Position: ${position.latitude}, ${position.longitude}',
      );
      debugPrint('Current Position JSON: ${position.toJson()}');
      if (mounted) {
        context.read<PositionRepository>().setCurrentPosition(position);
      }
    });
  }

  void _showLocationOptions() {
    final parentContext = context;
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(color: Colors.white),
          width: MediaQuery.sizeOf(context).width,
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const PawsText(
                  'Location Options',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),

                // Current Location Option
                if (USER_ID != null) ...[
                  const SizedBox(height: 16),

                  StatefulBuilder(
                    builder: (context, setModalState) {
                      return ListTile(
                        leading: _isLoadingLocation
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                LucideIcons.crosshair,
                                color: PawsColors.primary,
                              ),
                        title: const PawsText('Use Current Location'),
                        subtitle: _currentLocationAddress != null
                            ? PawsText(
                                _currentLocationAddress!,
                                fontSize: 12,
                                color: PawsColors.textSecondary,
                              )
                            : _locationError != null
                            ? PawsText(
                                _locationError!,
                                fontSize: 12,
                                color: PawsColors.error,
                              )
                            : const PawsText(
                                'Get your current location',
                                fontSize: 12,
                                color: PawsColors.textSecondary,
                              ),
                        onTap: _isLoadingLocation
                            ? null
                            : () async {
                                await _applyCurrentLocation();
                                setModalState(() {});
                                // Keep sheet open to allow selecting another saved address.
                              },
                      );
                    },
                  ),

                  const Divider(),
                  const PawsText(
                    'Saved Address',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                ],

                // Saved Addresses Section

                // Existing saved addresses logic
                if (context.watch<AddressRepository>().addresses != null)
                  ...context.watch<AddressRepository>().addresses!.map((e) {
                    final livePos = context
                        .watch<PositionRepository>()
                        .currentPositionLive;
                    bool isHere = false;
                    if (livePos != null &&
                        e.latitude != null &&
                        e.longitude != null) {
                      final distanceMeters = Geolocator.distanceBetween(
                        livePos.latitude,
                        livePos.longitude,
                        e.latitude!,
                        e.longitude!,
                      );
                      // Consider user "at" address if within 50 meters
                      isHere = distanceMeters <= 50;
                    }
                    return ListTile(
                      onTap: () async {
                        await handleSetDefaultAddress(e.id);
                        if (mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      leading: Container(
                        height: 18,
                        width: 18,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: PawsColors.primary,
                          ),
                        ),
                        child: e.isDefault
                            ? Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: PawsColors.primary,
                                ),
                              )
                            : null,
                      ),
                      title: PawsText(e.fullAddress),
                      subtitle: isHere
                          ? const PawsText(
                              'Current Location',
                              fontSize: 12,
                              color: PawsColors.success,
                            )
                          : null,
                      trailing: e.isDefault
                          ? null
                          : GestureDetector(
                              onTap: () async {
                                await handleDeleteAddress(e.id);
                                if (mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: PawsColors.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const PawsText(
                                  'Delete',
                                  fontSize: 12,
                                  color: PawsColors.error,
                                ),
                              ),
                            ),
                    );
                  }),

                const SizedBox(height: 16),
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
  }

  Future<void> handleDeleteAddress(int addressId) async {
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
      await context.read<AddressRepository>().fetchDefaultAddress(
        USER_ID ?? '',
      );
    }
    if (mounted) {
      await context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
    }
  }

  Future<void> _setDefaultAddressOperation(int addressId) async {
    debugPrint('Setting default address to: $addressId');
    final result = await CommonProvider().setDefaultAddress(
      USER_ID ?? '',
      addressId,
    );
    if (!result.isSuccess) {
      throw Exception('Failed to set default address');
    }
    if (mounted) {
      await context.read<AddressRepository>().fetchDefaultAddress(
        USER_ID ?? '',
      );
    }
    if (mounted) {
      await context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
    }
  }

  Future<void> handleSetDefaultAddress(int addressId) async {
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
            context.read<FundraisingRepository>().fetchActiveFundraisings();
          },
        )
        .subscribe();
    donationChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'donations',
          callback: (payload) {
            context.read<FundraisingRepository>().fetchFundraisings();
            context.read<FundraisingRepository>().fetchActiveFundraisings();
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

  @override
  void initState() {
    initializeChannels();
    handleListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PetRepository>().fetchRecentPets(userId: USER_ID);
        context.read<FundraisingRepository>().fetchActiveFundraisings();
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
        context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
        context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
        context.read<AdoptionRepository>().fetchUserAdoptions(USER_ID ?? '');
        context.read<EventRepository>().fetchEvents();
        context.read<DonationRepository>().fetchDonorLeaderboard();
        context.read<HomeRepository>().fetchCapstoneLinks();
      }
      if (USER_ID != null) {
        _listenOnCurrentPosition();
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
    final allPets = context.watch<PetRepository>().pets;
    final petError = context.select((PetRepository bloc) => bloc.errorMessage);
    final adoptions = context.select(
      (AdoptionRepository bloc) => bloc.adoptions,
    );
    final activeFundraisings = context.select(
      (FundraisingRepository bloc) => bloc.activeFundraisings,
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
    debugPrint('default address in home screen: $defaultAddress');

    final topDonors = context.watch<DonationRepository>().leaderboard;
    final user = context.watch<ProfileRepository>().userProfile;
    final events = context.watch<EventRepository>().events;
    final capstoneLinks = context.watch<HomeRepository>().capstoneLinks;
    debugPrint('capstone links: $capstoneLinks');
    debugPrint('user data: ${user?.toJson()}');
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
        onOpenCurrentLocation: _showLocationOptions,
        currentLocationAddress: _currentLocationAddress,
        isLoadingLocation: _isLoadingLocation,
      ),
      body: RefreshTrigger(
        onRefresh: () async {
          context.read<PetRepository>().fetchRecentPets(userId: USER_ID);
          context.read<FundraisingRepository>().fetchFundraisings();
          context.read<FundraisingRepository>().fetchActiveFundraisings();

          context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
          context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
          context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
          context.read<AdoptionRepository>().fetchUserAdoptions(USER_ID ?? "");
          context.read<EventRepository>().fetchEvents();
          context.read<HomeRepository>().fetchCapstoneLinks();
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
                if (capstoneLinks.isNotEmpty) ...{
                  Column(
                    spacing: 8,
                    children: capstoneLinks.map((e) {
                      debugPrint(e.imageLink!.transformedUrl);
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: e.imageLink != null
                                ? NetworkImage(e.imageLink!.transformedUrl)
                                : AssetImage('assets/images/form.jpg')
                                      as ImageProvider,
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PawsColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            PawsText(e.title, color: Colors.white),
                            PawsText(
                              e.description ??
                                  'Using this link you can help us improve PawsConnect by providing feedback through a quick evaluation form.',
                              fontSize: 13,
                              color: Colors.white,
                            ),

                            InkWell(
                              onTap: () {
                                launchUrl(Uri.parse(e.link));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: PawsColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: PawsText(
                                  e.buttonLabel ?? 'Visit Link',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                },
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
                if (user != null &&
                    (user.houseImages == null ||
                        user.houseImages!.isEmpty)) ...{
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
                    onTap: () async {
                      bool? result = await context.router.push(
                        SetUpVerificationRoute(),
                      );
                      if (result == true && mounted) {
                        context.read<ProfileRepository>().fetchUserProfile(
                          USER_ID!,
                        );
                      }
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

                if (user?.status != UserStatus.INDEFINITE &&
                    user?.status != UserStatus.PENDING &&
                    adoptions != null &&
                    adoptions.isNotEmpty) ...{
                  AdoptionOverview(
                    key: adoptionOverviewKey,
                    adoptions: adoptions,
                  ),
                },
                if (allPets != null) ...{
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
                      : allPets != null
                      ? Consumer<PetRepository>(
                          builder: (context, repo, _) {
                            final pets = repo.pets
                                ?.where(
                                  (e) => e.createdAt.isAfter(
                                    DateTime.now().subtract(Duration(days: 7)),
                                  ),
                                )
                                .toList();
                            if (pets == null) return SizedBox.shrink();
                            return SingleChildScrollView(
                              key: recentPetsKey,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 10,
                                children: List.generate(
                                  pets.length,
                                  (index) => PetContainer(
                                    pet: pets[index],
                                    isFavorite: context
                                        .watch<PetRepository>()
                                        .isFavorite(pets[index].id),
                                    onFavoriteToggle: (petId) {
                                      repo.togglePetFavorite(petId);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox.shrink(),
                if (activeFundraisings != null && activeFundraisings.isNotEmpty)
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
                                activeFundraisings == null &&
                                    fundraisingError == null
                                ? [
                                    Center(
                                      child: PawsText('No fundraisings found'),
                                    ),
                                  ]
                                : activeFundraisings != null
                                ? List.generate(
                                    activeFundraisings.length,
                                    (index) => FundraisingContainer(
                                      fundraising: activeFundraisings[index],
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
