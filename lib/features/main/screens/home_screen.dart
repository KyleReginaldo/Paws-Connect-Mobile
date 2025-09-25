import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:paws_connect/features/google_map/repository/address_repository.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/provider/common_provider.dart';
import '../../../core/services/shopee_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
import '../../fundraising/repository/fundraising_repository.dart';
import '../../internet/internet.dart';
import '../../profile/repository/profile_repository.dart';
import '../widgets/app_bar.dart';
import '../widgets/fundraising_container.dart';
import '../widgets/home/promotion_container.dart';
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
      ],
      child: this,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final petChannel = supabase.channel('public:pets');
  final fundraisingChannel = supabase.channel('public:fundraising');
  late final WebViewController webviewController;
  late RealtimeChannel addressChannel;
  void handleDeleteAddress(int addressId) async {
    final isConnected = context.read<InternetProvider>().isConnected;
    if (!isConnected) {
      EasyLoading.showToast(
        'You currently are offline',
        toastPosition: EasyLoadingToastPosition.top,
      );
      return;
    }

    EasyLoading.show(
      indicator: LottieBuilder.asset(
        'assets/json/paw_loader.json',
        height: 32,
        width: 32,
      ),
      status: 'Deleting address...',
      dismissOnTap: false,
    );
    final result = await CommonProvider().deleteAddress(addressId);
    EasyLoading.dismiss();
    if (result.isSuccess) {
      EasyLoading.showSuccess('Address deleted successfully');
      if (mounted) {
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
        context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
      }
    } else {
      EasyLoading.showError('Failed to delete address');
    }
  }

  void handleSetDefaultAddress(int addressId) async {
    final isConnected = context.read<InternetProvider>().isConnected;
    if (!isConnected) {
      EasyLoading.showToast(
        'You currently are offline',
        toastPosition: EasyLoadingToastPosition.top,
      );
      return;
    }

    EasyLoading.show(
      indicator: LottieBuilder.asset(
        'assets/json/paw_loader.json',
        height: 32,
        width: 32,
      ),
      status: 'Setting default address...',
      dismissOnTap: false,
    );
    final result = await CommonProvider().setDefaultAddress(
      USER_ID ?? '',
      addressId,
    );
    EasyLoading.dismiss();
    if (result.isSuccess) {
      EasyLoading.showSuccess('Address set as default successfully');
      if (mounted) {
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
        context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
      }
    } else {
      EasyLoading.showError('Failed to set default address');
    }
  }

  void initializeChannels() {
    addressChannel = supabase.channel('public:address:users=eq.$USER_ID');
  }

  void handleListeners() {
    debugPrint('USER ID: $USER_ID');
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

  void testFetchShopee() async {
    final result = await scrapeProductImageWithHeadless(
      'https://shopee.ph/Pet-Comb-Cat-Comb-Grooming-Dog-Comb-Grooming-Hair-i.416734455.13759810215',
    );
    debugPrint('shopee result: $result');
  }

  @override
  void initState() {
    initializeChannels();
    handleListeners();
    testFetchShopee();

    // Defer initial data fetches until after the first frame to avoid
    // calling notifyListeners during the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PetRepository>().fetchRecentPets(userId: USER_ID);
        context.read<FundraisingRepository>().fetchFundraisings();
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
        context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
        context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
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
    // final pets = context.select((PetRepository bloc) => bloc.pets);
    final recentPets = context.select((PetRepository bloc) => bloc.recentPets);
    final petError = context.select((PetRepository bloc) => bloc.errorMessage);
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
    final user = context.watch<ProfileRepository>().userProfile;
    final isConnected = context.watch<InternetProvider>().isConnected;
    // Removed debug print to prevent console spam
    return Scaffold(
      key: scaffoldKey,

      appBar: HomeAppBar(
        onProfileTap: user != null
            ? () {
                context.router.push(ProfileRoute(id: user.id));
              }
            : null,
        address: defaultAddress,
        profile: user,
        onOpenCurrentLocation: isConnected
            ? () {
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
                                                color: PawsColors.error
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
            : () {
                EasyLoading.showToast(
                  'You currently are offline',
                  toastPosition: EasyLoadingToastPosition.top,
                );
              },
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          final isConnected = context.read<InternetProvider>().isConnected;
          if (!isConnected) {
            EasyLoading.showToast(
              'You currently are offline',
              toastPosition: EasyLoadingToastPosition.top,
            );
            return;
          }

          context.read<PetRepository>().fetchRecentPets(userId: USER_ID);
          context.read<FundraisingRepository>().fetchFundraisings();
          context.read<AddressRepository>().fetchDefaultAddress(USER_ID ?? '');
          context.read<AddressRepository>().fetchAllAddresses(USER_ID ?? '');
          context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PawsSearchBar(hintText: 'Search for pets...'),
              PromotionContainer(),
              // PawsText('Category', fontSize: 16, fontWeight: FontWeight.w500),
              // CategoriesList(),
              // Show address error if there is one
              if (addressError != null)
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
                      Icon(Icons.location_off, color: Colors.orange, size: 20),
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

              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade100,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.grey.shade200),
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         height: 72,
              //         width: 72,
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(8),
              //           border: Border.all(color: Colors.grey.shade300),
              //         ),
              //         child: const Icon(Icons.shopping_cart_outlined, size: 36),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             PawsText(
              //               'Visit our Shopee Store(test)',
              //               fontSize: 16,
              //               fontWeight: FontWeight.w600,
              //             ),
              //             const SizedBox(height: 6),
              //             PawsText(
              //               'Tap the button to open shop in full screen',
              //               color: Colors.grey,
              //               fontSize: 13,
              //             ),
              //           ],
              //         ),
              //       ),
              //       ElevatedButton(
              //         onPressed: () {
              //           Navigator.of(context).push(
              //             MaterialPageRoute(
              //               builder: (_) => const ShopeeScreen(
              //                 initialUrl:
              //                     'https://shopee.ph/Pet-Comb-Cat-Comb-Grooming-Dog-Comb-Grooming-Hair-i.416734455.13759810215',
              //               ),
              //             ),
              //           );
              //         },
              //         child: const Text('Open(test)'),
              //       ),
              //     ],
              //   ),
              // ),
              if (recentPets != null)
                PawsText(
                  'Recently added',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 10,
                          children: List.generate(
                            recentPets.length,
                            (index) => PetContainer(pet: recentPets[index]),
                          ), // Empty when there's an error (error is shown above)
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
                              : [], // Empty when there's an error (error is shown above)
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
