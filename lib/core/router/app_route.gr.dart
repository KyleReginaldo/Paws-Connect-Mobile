// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i29;
import 'package:flutter/material.dart' as _i30;
import 'package:paws_connect/features/adoption/screens/adoption_history_screen.dart'
    as _i3;
import 'package:paws_connect/features/adoption/screens/create_adoption_screen.dart'
    as _i5;
import 'package:paws_connect/features/auth/screens/auth_screen.dart' as _i28;
import 'package:paws_connect/features/auth/screens/change_password_screen.dart'
    as _i4;
import 'package:paws_connect/features/auth/screens/onboarding_screen.dart'
    as _i20;
import 'package:paws_connect/features/donation/screens/donation_history_screen.dart'
    as _i6;
import 'package:paws_connect/features/favorite/screens/favorite_screen.dart'
    as _i8;
import 'package:paws_connect/features/forum/screens/add_forum_member_screen.dart'
    as _i1;
import 'package:paws_connect/features/forum/screens/add_forum_screen.dart'
    as _i2;
import 'package:paws_connect/features/forum/screens/forum_chat_screen.dart'
    as _i9;
import 'package:paws_connect/features/forum/screens/forum_screen.dart' as _i10;
import 'package:paws_connect/features/forum/screens/forum_settings_screen.dart'
    as _i11;
import 'package:paws_connect/features/fundraising/screens/fundraising_detail_screen.dart'
    as _i12;
import 'package:paws_connect/features/fundraising/screens/fundraising_screen.dart'
    as _i13;
import 'package:paws_connect/features/google_map/screens/map_screen.dart'
    as _i16;
import 'package:paws_connect/features/main/screens/home_screen.dart' as _i14;
import 'package:paws_connect/features/main/screens/main_screen.dart' as _i15;
import 'package:paws_connect/features/main/screens/no_internet_screen.dart'
    as _i17;
import 'package:paws_connect/features/main/screens/notfound_screen.dart'
    as _i18;
import 'package:paws_connect/features/notifications/screens/notification_screen.dart'
    as _i19;
import 'package:paws_connect/features/payment/screens/payment_method_screen.dart'
    as _i21;
import 'package:paws_connect/features/payment/screens/payment_screen.dart'
    as _i22;
import 'package:paws_connect/features/payment/screens/payment_success_screen.dart'
    as _i23;
import 'package:paws_connect/features/pets/models/pet_model.dart' as _i31;
import 'package:paws_connect/features/pets/screens/extensions/pet_detail_screen.dart'
    as _i24;
import 'package:paws_connect/features/pets/screens/pet_screen.dart' as _i25;
import 'package:paws_connect/features/profile/screens/edit_profile_screen.dart'
    as _i7;
import 'package:paws_connect/features/profile/screens/profile_screen.dart'
    as _i26;
import 'package:paws_connect/features/shopee/screens/shopee_screen.dart'
    as _i27;

/// generated route for
/// [_i1.AddForumMemberScreen]
class AddForumMemberRoute extends _i29.PageRouteInfo<AddForumMemberRouteArgs> {
  AddForumMemberRoute({
    _i30.Key? key,
    required int forumId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         AddForumMemberRoute.name,
         args: AddForumMemberRouteArgs(key: key, forumId: forumId),
         initialChildren: children,
       );

  static const String name = 'AddForumMemberRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddForumMemberRouteArgs>();
      return _i29.WrappedRoute(
        child: _i1.AddForumMemberScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class AddForumMemberRouteArgs {
  const AddForumMemberRouteArgs({this.key, required this.forumId});

  final _i30.Key? key;

  final int forumId;

  @override
  String toString() {
    return 'AddForumMemberRouteArgs{key: $key, forumId: $forumId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddForumMemberRouteArgs) return false;
    return key == other.key && forumId == other.forumId;
  }

  @override
  int get hashCode => key.hashCode ^ forumId.hashCode;
}

/// generated route for
/// [_i2.AddForumScreen]
class AddForumRoute extends _i29.PageRouteInfo<void> {
  const AddForumRoute({List<_i29.PageRouteInfo>? children})
    : super(AddForumRoute.name, initialChildren: children);

  static const String name = 'AddForumRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i2.AddForumScreen();
    },
  );
}

/// generated route for
/// [_i3.AdoptionHistoryScreen]
class AdoptionHistoryRoute extends _i29.PageRouteInfo<void> {
  const AdoptionHistoryRoute({List<_i29.PageRouteInfo>? children})
    : super(AdoptionHistoryRoute.name, initialChildren: children);

  static const String name = 'AdoptionHistoryRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i3.AdoptionHistoryScreen());
    },
  );
}

/// generated route for
/// [_i4.ChangePasswordScreen]
class ChangePasswordRoute extends _i29.PageRouteInfo<ChangePasswordRouteArgs> {
  ChangePasswordRoute({
    _i30.Key? key,
    void Function(bool)? onResult,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         ChangePasswordRoute.name,
         args: ChangePasswordRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'ChangePasswordRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangePasswordRouteArgs>(
        orElse: () => const ChangePasswordRouteArgs(),
      );
      return _i29.WrappedRoute(
        child: _i4.ChangePasswordScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class ChangePasswordRouteArgs {
  const ChangePasswordRouteArgs({this.key, this.onResult});

  final _i30.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'ChangePasswordRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangePasswordRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i5.CreateAdoptionScreen]
class CreateAdoptionRoute extends _i29.PageRouteInfo<CreateAdoptionRouteArgs> {
  CreateAdoptionRoute({
    _i30.Key? key,
    required int petId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         CreateAdoptionRoute.name,
         args: CreateAdoptionRouteArgs(key: key, petId: petId),
         rawPathParams: {'petId': petId},
         initialChildren: children,
       );

  static const String name = 'CreateAdoptionRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreateAdoptionRouteArgs>(
        orElse: () =>
            CreateAdoptionRouteArgs(petId: pathParams.getInt('petId')),
      );
      return _i29.WrappedRoute(
        child: _i5.CreateAdoptionScreen(key: args.key, petId: args.petId),
      );
    },
  );
}

class CreateAdoptionRouteArgs {
  const CreateAdoptionRouteArgs({this.key, required this.petId});

  final _i30.Key? key;

  final int petId;

  @override
  String toString() {
    return 'CreateAdoptionRouteArgs{key: $key, petId: $petId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateAdoptionRouteArgs) return false;
    return key == other.key && petId == other.petId;
  }

  @override
  int get hashCode => key.hashCode ^ petId.hashCode;
}

/// generated route for
/// [_i6.DonationHistoryScreen]
class DonationHistoryRoute extends _i29.PageRouteInfo<void> {
  const DonationHistoryRoute({List<_i29.PageRouteInfo>? children})
    : super(DonationHistoryRoute.name, initialChildren: children);

  static const String name = 'DonationHistoryRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i6.DonationHistoryScreen());
    },
  );
}

/// generated route for
/// [_i7.EditProfileScreen]
class EditProfileRoute extends _i29.PageRouteInfo<void> {
  const EditProfileRoute({List<_i29.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i7.EditProfileScreen());
    },
  );
}

/// generated route for
/// [_i8.FavoriteScreen]
class FavoriteRoute extends _i29.PageRouteInfo<void> {
  const FavoriteRoute({List<_i29.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i8.FavoriteScreen());
    },
  );
}

/// generated route for
/// [_i9.ForumChatScreen]
class ForumChatRoute extends _i29.PageRouteInfo<ForumChatRouteArgs> {
  ForumChatRoute({
    _i30.Key? key,
    required int forumId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         ForumChatRoute.name,
         args: ForumChatRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumChatRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumChatRouteArgs>(
        orElse: () => ForumChatRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i29.WrappedRoute(
        child: _i9.ForumChatScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumChatRouteArgs {
  const ForumChatRouteArgs({this.key, required this.forumId});

  final _i30.Key? key;

  final int forumId;

  @override
  String toString() {
    return 'ForumChatRouteArgs{key: $key, forumId: $forumId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForumChatRouteArgs) return false;
    return key == other.key && forumId == other.forumId;
  }

  @override
  int get hashCode => key.hashCode ^ forumId.hashCode;
}

/// generated route for
/// [_i10.ForumScreen]
class ForumRoute extends _i29.PageRouteInfo<void> {
  const ForumRoute({List<_i29.PageRouteInfo>? children})
    : super(ForumRoute.name, initialChildren: children);

  static const String name = 'ForumRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i10.ForumScreen());
    },
  );
}

/// generated route for
/// [_i11.ForumSettingsScreen]
class ForumSettingsRoute extends _i29.PageRouteInfo<ForumSettingsRouteArgs> {
  ForumSettingsRoute({
    _i30.Key? key,
    required int forumId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         ForumSettingsRoute.name,
         args: ForumSettingsRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumSettingsRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumSettingsRouteArgs>(
        orElse: () =>
            ForumSettingsRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i29.WrappedRoute(
        child: _i11.ForumSettingsScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumSettingsRouteArgs {
  const ForumSettingsRouteArgs({this.key, required this.forumId});

  final _i30.Key? key;

  final int forumId;

  @override
  String toString() {
    return 'ForumSettingsRouteArgs{key: $key, forumId: $forumId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForumSettingsRouteArgs) return false;
    return key == other.key && forumId == other.forumId;
  }

  @override
  int get hashCode => key.hashCode ^ forumId.hashCode;
}

/// generated route for
/// [_i12.FundraisingDetailScreen]
class FundraisingDetailRoute
    extends _i29.PageRouteInfo<FundraisingDetailRouteArgs> {
  FundraisingDetailRoute({
    _i30.Key? key,
    required int id,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         FundraisingDetailRoute.name,
         args: FundraisingDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'FundraisingDetailRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FundraisingDetailRouteArgs>(
        orElse: () => FundraisingDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i29.WrappedRoute(
        child: _i12.FundraisingDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class FundraisingDetailRouteArgs {
  const FundraisingDetailRouteArgs({this.key, required this.id});

  final _i30.Key? key;

  final int id;

  @override
  String toString() {
    return 'FundraisingDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FundraisingDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i13.FundraisingScreen]
class FundraisingRoute extends _i29.PageRouteInfo<void> {
  const FundraisingRoute({List<_i29.PageRouteInfo>? children})
    : super(FundraisingRoute.name, initialChildren: children);

  static const String name = 'FundraisingRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i13.FundraisingScreen());
    },
  );
}

/// generated route for
/// [_i14.HomeScreen]
class HomeRoute extends _i29.PageRouteInfo<void> {
  const HomeRoute({List<_i29.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i14.HomeScreen());
    },
  );
}

/// generated route for
/// [_i15.MainScreen]
class MainRoute extends _i29.PageRouteInfo<MainRouteArgs> {
  MainRoute({
    _i30.Key? key,
    int? initialIndex,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         MainRoute.name,
         args: MainRouteArgs(key: key, initialIndex: initialIndex),
         initialChildren: children,
       );

  static const String name = 'MainRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainRouteArgs>(
        orElse: () => const MainRouteArgs(),
      );
      return _i15.MainScreen(key: args.key, initialIndex: args.initialIndex);
    },
  );
}

class MainRouteArgs {
  const MainRouteArgs({this.key, this.initialIndex});

  final _i30.Key? key;

  final int? initialIndex;

  @override
  String toString() {
    return 'MainRouteArgs{key: $key, initialIndex: $initialIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MainRouteArgs) return false;
    return key == other.key && initialIndex == other.initialIndex;
  }

  @override
  int get hashCode => key.hashCode ^ initialIndex.hashCode;
}

/// generated route for
/// [_i16.MapScreen]
class MapRoute extends _i29.PageRouteInfo<void> {
  const MapRoute({List<_i29.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i16.MapScreen();
    },
  );
}

/// generated route for
/// [_i17.NoInternetScreen]
class NoInternetRoute extends _i29.PageRouteInfo<NoInternetRouteArgs> {
  NoInternetRoute({
    _i30.Key? key,
    dynamic Function(bool)? onResult,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         NoInternetRoute.name,
         args: NoInternetRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'NoInternetRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoInternetRouteArgs>(
        orElse: () => const NoInternetRouteArgs(),
      );
      return _i17.NoInternetScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class NoInternetRouteArgs {
  const NoInternetRouteArgs({this.key, this.onResult});

  final _i30.Key? key;

  final dynamic Function(bool)? onResult;

  @override
  String toString() {
    return 'NoInternetRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoInternetRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i18.NotfoundScreen]
class NotfoundRoute extends _i29.PageRouteInfo<void> {
  const NotfoundRoute({List<_i29.PageRouteInfo>? children})
    : super(NotfoundRoute.name, initialChildren: children);

  static const String name = 'NotfoundRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i18.NotfoundScreen();
    },
  );
}

/// generated route for
/// [_i19.NotificationScreen]
class NotificationRoute extends _i29.PageRouteInfo<void> {
  const NotificationRoute({List<_i29.PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i19.NotificationScreen());
    },
  );
}

/// generated route for
/// [_i20.OnboardingScreen]
class OnboardingRoute extends _i29.PageRouteInfo<void> {
  const OnboardingRoute({List<_i29.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i20.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i21.PaymentMethodScreen]
class PaymentMethodRoute extends _i29.PageRouteInfo<PaymentMethodRouteArgs> {
  PaymentMethodRoute({
    _i30.Key? key,
    required String paymongoId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         PaymentMethodRoute.name,
         args: PaymentMethodRouteArgs(key: key, paymongoId: paymongoId),
         initialChildren: children,
       );

  static const String name = 'PaymentMethodRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentMethodRouteArgs>();
      return _i21.PaymentMethodScreen(
        key: args.key,
        paymongoId: args.paymongoId,
      );
    },
  );
}

class PaymentMethodRouteArgs {
  const PaymentMethodRouteArgs({this.key, required this.paymongoId});

  final _i30.Key? key;

  final String paymongoId;

  @override
  String toString() {
    return 'PaymentMethodRouteArgs{key: $key, paymongoId: $paymongoId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentMethodRouteArgs) return false;
    return key == other.key && paymongoId == other.paymongoId;
  }

  @override
  int get hashCode => key.hashCode ^ paymongoId.hashCode;
}

/// generated route for
/// [_i22.PaymentScreen]
class PaymentRoute extends _i29.PageRouteInfo<PaymentRouteArgs> {
  PaymentRoute({
    _i30.Key? key,
    required int fundraisingId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         PaymentRoute.name,
         args: PaymentRouteArgs(key: key, fundraisingId: fundraisingId),
         rawPathParams: {'id': fundraisingId},
         initialChildren: children,
       );

  static const String name = 'PaymentRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentRouteArgs>(
        orElse: () => PaymentRouteArgs(fundraisingId: pathParams.getInt('id')),
      );
      return _i29.WrappedRoute(
        child: _i22.PaymentScreen(
          key: args.key,
          fundraisingId: args.fundraisingId,
        ),
      );
    },
  );
}

class PaymentRouteArgs {
  const PaymentRouteArgs({this.key, required this.fundraisingId});

  final _i30.Key? key;

  final int fundraisingId;

  @override
  String toString() {
    return 'PaymentRouteArgs{key: $key, fundraisingId: $fundraisingId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentRouteArgs) return false;
    return key == other.key && fundraisingId == other.fundraisingId;
  }

  @override
  int get hashCode => key.hashCode ^ fundraisingId.hashCode;
}

/// generated route for
/// [_i23.PaymentSuccessScreen]
class PaymentSuccessRoute extends _i29.PageRouteInfo<PaymentSuccessRouteArgs> {
  PaymentSuccessRoute({
    _i30.Key? key,
    required int id,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessRoute.name,
         args: PaymentSuccessRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentSuccessRouteArgs>(
        orElse: () => PaymentSuccessRouteArgs(id: pathParams.getInt('id')),
      );
      return _i23.PaymentSuccessScreen(key: args.key, id: args.id);
    },
  );
}

class PaymentSuccessRouteArgs {
  const PaymentSuccessRouteArgs({this.key, required this.id});

  final _i30.Key? key;

  final int id;

  @override
  String toString() {
    return 'PaymentSuccessRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentSuccessRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i24.PetDetailScreen]
class PetDetailRoute extends _i29.PageRouteInfo<PetDetailRouteArgs> {
  PetDetailRoute({
    _i30.Key? key,
    required _i31.Pet pet,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         PetDetailRoute.name,
         args: PetDetailRouteArgs(key: key, pet: pet),
         initialChildren: children,
       );

  static const String name = 'PetDetailRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PetDetailRouteArgs>();
      return _i24.PetDetailScreen(key: args.key, pet: args.pet);
    },
  );
}

class PetDetailRouteArgs {
  const PetDetailRouteArgs({this.key, required this.pet});

  final _i30.Key? key;

  final _i31.Pet pet;

  @override
  String toString() {
    return 'PetDetailRouteArgs{key: $key, pet: $pet}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PetDetailRouteArgs) return false;
    return key == other.key && pet == other.pet;
  }

  @override
  int get hashCode => key.hashCode ^ pet.hashCode;
}

/// generated route for
/// [_i25.PetScreen]
class PetRoute extends _i29.PageRouteInfo<void> {
  const PetRoute({List<_i29.PageRouteInfo>? children})
    : super(PetRoute.name, initialChildren: children);

  static const String name = 'PetRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i25.PetScreen());
    },
  );
}

/// generated route for
/// [_i26.ProfileScreen]
class ProfileRoute extends _i29.PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    _i30.Key? key,
    required String id,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         ProfileRoute.name,
         args: ProfileRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ProfileRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileRouteArgs>();
      return _i29.WrappedRoute(
        child: _i26.ProfileScreen(key: args.key, id: args.id),
      );
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key, required this.id});

  final _i30.Key? key;

  final String id;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i27.ShopeeScreen]
class ShopeeRoute extends _i29.PageRouteInfo<ShopeeRouteArgs> {
  ShopeeRoute({
    _i30.Key? key,
    String initialUrl = 'https://shopee.ph',
    List<_i29.PageRouteInfo>? children,
  }) : super(
         ShopeeRoute.name,
         args: ShopeeRouteArgs(key: key, initialUrl: initialUrl),
         initialChildren: children,
       );

  static const String name = 'ShopeeRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShopeeRouteArgs>(
        orElse: () => const ShopeeRouteArgs(),
      );
      return _i27.ShopeeScreen(key: args.key, initialUrl: args.initialUrl);
    },
  );
}

class ShopeeRouteArgs {
  const ShopeeRouteArgs({this.key, this.initialUrl = 'https://shopee.ph'});

  final _i30.Key? key;

  final String initialUrl;

  @override
  String toString() {
    return 'ShopeeRouteArgs{key: $key, initialUrl: $initialUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShopeeRouteArgs) return false;
    return key == other.key && initialUrl == other.initialUrl;
  }

  @override
  int get hashCode => key.hashCode ^ initialUrl.hashCode;
}

/// generated route for
/// [_i28.SignInScreen]
class SignInRoute extends _i29.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i30.Key? key,
    void Function(bool)? onResult,
    String? email,
    String? password,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         SignInRoute.name,
         args: SignInRouteArgs(
           key: key,
           onResult: onResult,
           email: email,
           password: password,
         ),
         initialChildren: children,
       );

  static const String name = 'SignInRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i29.WrappedRoute(
        child: _i28.SignInScreen(
          key: args.key,
          onResult: args.onResult,
          email: args.email,
          password: args.password,
        ),
      );
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.onResult, this.email, this.password});

  final _i30.Key? key;

  final void Function(bool)? onResult;

  final String? email;

  final String? password;

  @override
  String toString() {
    return 'SignInRouteArgs{key: $key, onResult: $onResult, email: $email, password: $password}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignInRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ password.hashCode;
}
