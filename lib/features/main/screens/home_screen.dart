import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/features/google_map/repository/address_repository.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/provider/common_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/global_confirm_dialog.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
import '../../fundraising/repository/fundraising_repository.dart';
import '../../profile/repository/profile_repository.dart';
import '../widgets/app_bar.dart';
import '../widgets/fundraising_container.dart';
import '../widgets/home/categories_list.dart';
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
        ChangeNotifierProvider(
          create: (context) => sl<PetRepository>()..fetchPets(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<FundraisingRepository>()..fetchFundraisings(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<AddressRepository>()
            ..fetchDefaultAddress(USER_ID)
            ..fetchAllAddresses(USER_ID),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              sl<ProfileRepository>()..fetchUserProfile(USER_ID),
        ),
      ],
      child: this,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final petChannel = supabase.channel('public:pets');
  final fundraisingChannel = supabase.channel('public:fundraising');
  late RealtimeChannel addressChannel;
  void handleDeleteAddress(int addressId) async {
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
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID);
        context.read<AddressRepository>().fetchAllAddresses(USER_ID);
      }
    } else {
      EasyLoading.showError('Failed to delete address');
    }
  }

  void handleSetDefaultAddress(int addressId) async {
    EasyLoading.show(
      indicator: LottieBuilder.asset(
        'assets/json/paw_loader.json',
        height: 32,
        width: 32,
      ),
      status: 'Setting default address...',
      dismissOnTap: false,
    );
    final result = await CommonProvider().setDefaultAddress(USER_ID, addressId);
    EasyLoading.dismiss();
    if (result.isSuccess) {
      EasyLoading.showSuccess('Address set as default successfully');
      if (mounted) {
        context.read<AddressRepository>().fetchDefaultAddress(USER_ID);
        context.read<AddressRepository>().fetchAllAddresses(USER_ID);
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
            context.read<PetRepository>().fetchPets();
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
            context.read<AddressRepository>().fetchDefaultAddress(USER_ID);
            context.read<AddressRepository>().fetchAllAddresses(USER_ID);
          },
        )
        .subscribe();
  }

  @override
  void initState() {
    initializeChannels();
    handleListeners();
    super.initState();
  }

  @override
  void dispose() {
    petChannel.unsubscribe();
    fundraisingChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetRepository>().pets;
    final fundraisings = context.watch<FundraisingRepository>().fundraisings;
    final fundraisingLoading = context.watch<FundraisingRepository>().isLoading;
    final petLoading = context.watch<PetRepository>().isLoading;
    final defaultAddress = context.watch<AddressRepository>().defaultAddress;
    final addresses = context.watch<AddressRepository>().addresses;
    final user = context.watch<ProfileRepository>().userProfile;
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(),
        child: Column(
          children: [
            if (user != null)
              DrawerHeader(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PawsColors.primaryDark.withValues(alpha: 1),
                      PawsColors.primaryDark.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                margin: EdgeInsets.zero,
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset('assets/images/user.png', height: 64),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 2,
                      children: [
                        PawsText(
                          user.username,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        PawsText(user.email, fontSize: 14, color: Colors.white),
                        PawsText(
                          user.phoneNumber,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ListTile(
              leading: Icon(
                LucideIcons.calendar,
                color: PawsColors.textSecondary,
              ),
              title: PawsText(
                'Adoption History',
                color: PawsColors.textSecondary,
              ),
            ),
            ListTile(
              leading: Icon(
                LucideIcons.bookmark,
                color: PawsColors.textSecondary,
              ),
              title: PawsText(
                'Recent Donations',
                color: PawsColors.textSecondary,
              ),
            ),
            Spacer(),
            ListTile(
              iconColor: Colors.redAccent,
              leading: Icon(LucideIcons.logOut),
              title: PawsText('Log Out', color: Colors.redAccent),
              onTap: () async {
                // close drawer first so dialog is shown on top of main scaffold
                Navigator.pop(context);
                final should = await showGlobalConfirmDialog(
                  context,
                  title: 'Log Out',
                  message: 'Are you sure you want to log out?',
                  confirmLabel: 'Log Out',
                  cancelLabel: 'Cancel',
                );
                if (should == true) {
                  await supabase.auth.signOut();
                  await OneSignal.logout();
                  if (!mounted) return;
                  context.router.replacePath('/');
                }
              },
            ),
          ],
        ),
      ),
      appBar: HomeAppBar(
        onOpenDrawer: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
        address: defaultAddress,
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
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          context.read<PetRepository>().fetchPets();
          context.read<FundraisingRepository>().fetchFundraisings();
          context.read<AddressRepository>().fetchDefaultAddress(USER_ID);
          context.read<AddressRepository>().fetchAllAddresses(USER_ID);
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
              PawsText('Category', fontSize: 16, fontWeight: FontWeight.w500),
              CategoriesList(),
              // PawsDivider(thickness: 2),
              PawsText(
                'Recently added',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 10,
                        children: pets == null
                            ? [Center(child: PawsText('No pets found'))]
                            : List.generate(
                                pets.length,
                                (index) => PetContainer(pet: pets[index]),
                              ),
                      ),
                    ),
              if (!fundraisingLoading)
                PawsText(
                  'Fundraising',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
                        spacing: 10,
                        children: fundraisings == null
                            ? [Center(child: PawsText('No fundraisings found'))]
                            : List.generate(
                                fundraisings.length,
                                (index) => FundraisingContainer(
                                  fundraising: fundraisings[index],
                                ),
                              ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
