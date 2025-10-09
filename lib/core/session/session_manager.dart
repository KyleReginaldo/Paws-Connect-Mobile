import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/repository/common_repository.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:paws_connect/features/donation/repository/donation_repository.dart';
import 'package:paws_connect/features/favorite/repository/favorite_repository.dart';
import 'package:paws_connect/features/forum/repository/forum_repository.dart';
import 'package:paws_connect/features/fundraising/repository/fundraising_repository.dart';
import 'package:paws_connect/features/google_map/repository/address_repository.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';

class SessionManager {
  // Call this to fully sign out and clear all in-memory caches
  static Future<void> signOutAndClear() async {
    if (sl.isRegistered<AuthRepository>()) {
      await sl<AuthRepository>().signOut();
    }
    // Ensure OneSignal identity is cleared on sign out
    try {
      await OneSignal.logout();
      // ignore: avoid_print
      print('🔕 OneSignal logout done');
    } catch (e) {
      // ignore: avoid_print
      print('❌ OneSignal logout failed: $e');
    }
    await clearCachesOnly();
    // Preload public data so Home is populated right after sign out
    await bootstrapAfterSignOut(eager: false);
  }

  // Call this if sign-out already happened elsewhere and you just need to clear caches
  static Future<void> clearCachesOnly() async {
    // Clear global/user-scoped IDs
    USER_ID = null;

    // Clear repository caches
    if (sl.isRegistered<PetRepository>()) sl<PetRepository>().reset();
    if (sl.isRegistered<FundraisingRepository>())
      sl<FundraisingRepository>().reset();
    if (sl.isRegistered<AddressRepository>()) sl<AddressRepository>().reset();
    if (sl.isRegistered<ProfileRepository>()) sl<ProfileRepository>().reset();
    if (sl.isRegistered<ForumRepository>()) sl<ForumRepository>().reset();
    if (sl.isRegistered<AdoptionRepository>()) sl<AdoptionRepository>().reset();
    if (sl.isRegistered<DonationRepository>()) sl<DonationRepository>().reset();
    if (sl.isRegistered<FavoriteRepository>()) sl<FavoriteRepository>().reset();
    if (sl.isRegistered<CommonRepository>()) sl<CommonRepository>().clear();
    // Reset common counts if repository exists
    if (sl.isRegistered<CommonRepository>()) {
      // Directly set to null via repository internal fields not exposed; simplest is to reinstantiate if needed.
      // For now we can just fetch counts with no user which will land as null.
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sl<CommonRepository>().notifyListeners();
    }

    // Add more clears here if you introduce local storage (e.g., SharedPreferences/Hive)
  }

  // Preload all user-related repositories after successful sign-in
  static Future<void> bootstrapAfterSignIn({bool eager = false}) async {
    if (USER_ID == null || (USER_ID?.isEmpty ?? true)) return;

    // Ensure OneSignal is logged in with the current USER_ID
    try {
      final current = await OneSignal.User.getExternalId();
      if (current != USER_ID) {
        await OneSignal.login(USER_ID!);
        // ignore: avoid_print
        print('🔔 OneSignal ensured login for ${USER_ID!}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ OneSignal ensure login failed: $e');
    }

    final futures = <Future<void>>[];
    if (sl.isRegistered<ProfileRepository>()) {
      futures.add(sl<ProfileRepository>().fetchUserProfile(USER_ID!));
    }
    if (sl.isRegistered<AddressRepository>()) {
      futures.add(sl<AddressRepository>().fetchDefaultAddress(USER_ID!));
      futures.add(sl<AddressRepository>().fetchAllAddresses(USER_ID!));
    }
    if (sl.isRegistered<PetRepository>()) {
      futures.add(sl<PetRepository>().fetchRecentPets(userId: USER_ID));
    }
    if (sl.isRegistered<FundraisingRepository>()) {
      futures.add(sl<FundraisingRepository>().fetchFundraisings());
    }
    if (sl.isRegistered<FavoriteRepository>()) {
      futures.add(sl<FavoriteRepository>().getFavorites(USER_ID!));
    }
    if (sl.isRegistered<AdoptionRepository>()) {
      futures.add(sl<AdoptionRepository>().fetchUserAdoptions(USER_ID!));
    }
    if (sl.isRegistered<DonationRepository>()) {
      futures.add(sl<DonationRepository>().fetchUserDonations(USER_ID!));
    }
    if (sl.isRegistered<ForumRepository>()) {
      futures.add(sl<ForumRepository>().fetchForums(USER_ID!));
    }

    // Fetch unread message & notification counts early so UI badges update immediately
    if (sl.isRegistered<CommonRepository>()) {
      // Fire-and-forget; repository notifies listeners
      sl<CommonRepository>().getMessageCount(USER_ID!);
      sl<CommonRepository>().getNotificationCount(USER_ID!);
    }

    if (eager) {
      await Future.wait(futures, eagerError: false);
    } else {
      // Fire and forget to avoid blocking UI
      for (final f in futures) {
        // ignore: unawaited_futures
        f.catchError((_) {});
      }
    }
  }

  // Preload public data (non user-specific) after sign-out
  static Future<void> bootstrapAfterSignOut({bool eager = false}) async {
    final futures = <Future<void>>[];
    if (sl.isRegistered<FundraisingRepository>()) {
      futures.add(sl<FundraisingRepository>().fetchFundraisings());
    }
    // fetchPets() returns void; invoke fire-and-forget, and also recent without user
    if (sl.isRegistered<PetRepository>()) {
      sl<PetRepository>().fetchPets();
      futures.add(sl<PetRepository>().fetchRecentPets());
    }

    if (eager) {
      await Future.wait(futures, eagerError: false);
    } else {
      for (final f in futures) {
        // ignore: unawaited_futures
        f.catchError((_) {});
      }
    }
  }
}
