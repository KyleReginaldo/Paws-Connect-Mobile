// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i33;
import 'package:flutter/material.dart' as _i34;
import 'package:paws_connect/features/adoption/screens/adoption_detail_screen.dart'
    as _i3;
import 'package:paws_connect/features/adoption/screens/adoption_history_screen.dart'
    as _i4;
import 'package:paws_connect/features/adoption/screens/adoption_success_screen.dart'
    as _i5;
import 'package:paws_connect/features/adoption/screens/create_adoption_screen.dart'
    as _i7;
import 'package:paws_connect/features/auth/screens/auth_screen.dart' as _i31;
import 'package:paws_connect/features/auth/screens/change_password_screen.dart'
    as _i6;
import 'package:paws_connect/features/auth/screens/onboarding_screen.dart'
    as _i23;
import 'package:paws_connect/features/donation/screens/donation_history_screen.dart'
    as _i8;
import 'package:paws_connect/features/favorite/screens/favorite_screen.dart'
    as _i10;
import 'package:paws_connect/features/forum/screens/add_forum_member_screen.dart'
    as _i1;
import 'package:paws_connect/features/forum/screens/add_forum_screen.dart'
    as _i2;
import 'package:paws_connect/features/forum/screens/forum_chat_screen.dart'
    as _i11;
import 'package:paws_connect/features/forum/screens/forum_screen.dart' as _i12;
import 'package:paws_connect/features/forum/screens/forum_settings_screen.dart'
    as _i13;
import 'package:paws_connect/features/fundraising/screens/fundraising_detail_screen.dart'
    as _i14;
import 'package:paws_connect/features/fundraising/screens/fundraising_screen.dart'
    as _i15;
import 'package:paws_connect/features/google_map/screens/map_screen.dart'
    as _i18;
import 'package:paws_connect/features/main/screens/home_screen.dart' as _i16;
import 'package:paws_connect/features/main/screens/main_screen.dart' as _i17;
import 'package:paws_connect/features/main/screens/no_internet_screen.dart'
    as _i19;
import 'package:paws_connect/features/main/screens/notfound_screen.dart'
    as _i20;
import 'package:paws_connect/features/notifications/models/notification_model.dart'
    as _i35;
import 'package:paws_connect/features/notifications/screens/notification_detail_screen.dart'
    as _i21;
import 'package:paws_connect/features/notifications/screens/notification_screen.dart'
    as _i22;
import 'package:paws_connect/features/payment/screens/payment_method_screen.dart'
    as _i24;
import 'package:paws_connect/features/payment/screens/payment_screen.dart'
    as _i25;
import 'package:paws_connect/features/payment/screens/payment_success_screen.dart'
    as _i26;
import 'package:paws_connect/features/pets/models/pet_model.dart' as _i36;
import 'package:paws_connect/features/pets/screens/extensions/pet_detail_screen.dart'
    as _i27;
import 'package:paws_connect/features/pets/screens/pet_screen.dart' as _i28;
import 'package:paws_connect/features/profile/screens/edit_profile_screen.dart'
    as _i9;
import 'package:paws_connect/features/profile/screens/profile_screen.dart'
    as _i29;
import 'package:paws_connect/features/profile/screens/user_house_screen.dart'
    as _i32;
import 'package:paws_connect/features/verification/screens/setup_verification_screen.dart'
    as _i30;

/// generated route for
/// [_i1.AddForumMemberScreen]
class AddForumMemberRoute extends _i33.PageRouteInfo<AddForumMemberRouteArgs> {
  AddForumMemberRoute({
    _i34.Key? key,
    required int forumId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         AddForumMemberRoute.name,
         args: AddForumMemberRouteArgs(key: key, forumId: forumId),
         initialChildren: children,
       );

  static const String name = 'AddForumMemberRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddForumMemberRouteArgs>();
      return _i33.WrappedRoute(
        child: _i1.AddForumMemberScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class AddForumMemberRouteArgs {
  const AddForumMemberRouteArgs({this.key, required this.forumId});

  final _i34.Key? key;

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
class AddForumRoute extends _i33.PageRouteInfo<void> {
  const AddForumRoute({List<_i33.PageRouteInfo>? children})
    : super(AddForumRoute.name, initialChildren: children);

  static const String name = 'AddForumRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return const _i2.AddForumScreen();
    },
  );
}

/// generated route for
/// [_i3.AdoptionDetailScreen]
class AdoptionDetailRoute extends _i33.PageRouteInfo<AdoptionDetailRouteArgs> {
  AdoptionDetailRoute({
    _i34.Key? key,
    required int id,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         AdoptionDetailRoute.name,
         args: AdoptionDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'AdoptionDetailRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdoptionDetailRouteArgs>();
      return _i33.WrappedRoute(
        child: _i3.AdoptionDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class AdoptionDetailRouteArgs {
  const AdoptionDetailRouteArgs({this.key, required this.id});

  final _i34.Key? key;

  final int id;

  @override
  String toString() {
    return 'AdoptionDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdoptionDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i4.AdoptionHistoryScreen]
class AdoptionHistoryRoute extends _i33.PageRouteInfo<void> {
  const AdoptionHistoryRoute({List<_i33.PageRouteInfo>? children})
    : super(AdoptionHistoryRoute.name, initialChildren: children);

  static const String name = 'AdoptionHistoryRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i4.AdoptionHistoryScreen());
    },
  );
}

/// generated route for
/// [_i5.AdoptionSuccessScreen]
class AdoptionSuccessRoute
    extends _i33.PageRouteInfo<AdoptionSuccessRouteArgs> {
  AdoptionSuccessRoute({
    _i34.Key? key,
    String? petName,
    String? applicationId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         AdoptionSuccessRoute.name,
         args: AdoptionSuccessRouteArgs(
           key: key,
           petName: petName,
           applicationId: applicationId,
         ),
         initialChildren: children,
       );

  static const String name = 'AdoptionSuccessRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdoptionSuccessRouteArgs>(
        orElse: () => const AdoptionSuccessRouteArgs(),
      );
      return _i5.AdoptionSuccessScreen(
        key: args.key,
        petName: args.petName,
        applicationId: args.applicationId,
      );
    },
  );
}

class AdoptionSuccessRouteArgs {
  const AdoptionSuccessRouteArgs({this.key, this.petName, this.applicationId});

  final _i34.Key? key;

  final String? petName;

  final String? applicationId;

  @override
  String toString() {
    return 'AdoptionSuccessRouteArgs{key: $key, petName: $petName, applicationId: $applicationId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdoptionSuccessRouteArgs) return false;
    return key == other.key &&
        petName == other.petName &&
        applicationId == other.applicationId;
  }

  @override
  int get hashCode => key.hashCode ^ petName.hashCode ^ applicationId.hashCode;
}

/// generated route for
/// [_i6.ChangePasswordScreen]
class ChangePasswordRoute extends _i33.PageRouteInfo<ChangePasswordRouteArgs> {
  ChangePasswordRoute({
    _i34.Key? key,
    void Function(bool)? onResult,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         ChangePasswordRoute.name,
         args: ChangePasswordRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'ChangePasswordRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangePasswordRouteArgs>(
        orElse: () => const ChangePasswordRouteArgs(),
      );
      return _i33.WrappedRoute(
        child: _i6.ChangePasswordScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class ChangePasswordRouteArgs {
  const ChangePasswordRouteArgs({this.key, this.onResult});

  final _i34.Key? key;

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
/// [_i7.CreateAdoptionScreen]
class CreateAdoptionRoute extends _i33.PageRouteInfo<CreateAdoptionRouteArgs> {
  CreateAdoptionRoute({
    _i34.Key? key,
    required int petId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         CreateAdoptionRoute.name,
         args: CreateAdoptionRouteArgs(key: key, petId: petId),
         rawPathParams: {'petId': petId},
         initialChildren: children,
       );

  static const String name = 'CreateAdoptionRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreateAdoptionRouteArgs>(
        orElse: () =>
            CreateAdoptionRouteArgs(petId: pathParams.getInt('petId')),
      );
      return _i33.WrappedRoute(
        child: _i7.CreateAdoptionScreen(key: args.key, petId: args.petId),
      );
    },
  );
}

class CreateAdoptionRouteArgs {
  const CreateAdoptionRouteArgs({this.key, required this.petId});

  final _i34.Key? key;

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
/// [_i8.DonationHistoryScreen]
class DonationHistoryRoute extends _i33.PageRouteInfo<void> {
  const DonationHistoryRoute({List<_i33.PageRouteInfo>? children})
    : super(DonationHistoryRoute.name, initialChildren: children);

  static const String name = 'DonationHistoryRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i8.DonationHistoryScreen());
    },
  );
}

/// generated route for
/// [_i9.EditProfileScreen]
class EditProfileRoute extends _i33.PageRouteInfo<void> {
  const EditProfileRoute({List<_i33.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i9.EditProfileScreen());
    },
  );
}

/// generated route for
/// [_i10.FavoriteScreen]
class FavoriteRoute extends _i33.PageRouteInfo<void> {
  const FavoriteRoute({List<_i33.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i10.FavoriteScreen());
    },
  );
}

/// generated route for
/// [_i11.ForumChatScreen]
class ForumChatRoute extends _i33.PageRouteInfo<ForumChatRouteArgs> {
  ForumChatRoute({
    _i34.Key? key,
    required int forumId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         ForumChatRoute.name,
         args: ForumChatRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumChatRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumChatRouteArgs>(
        orElse: () => ForumChatRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i33.WrappedRoute(
        child: _i11.ForumChatScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumChatRouteArgs {
  const ForumChatRouteArgs({this.key, required this.forumId});

  final _i34.Key? key;

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
/// [_i12.ForumScreen]
class ForumRoute extends _i33.PageRouteInfo<void> {
  const ForumRoute({List<_i33.PageRouteInfo>? children})
    : super(ForumRoute.name, initialChildren: children);

  static const String name = 'ForumRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i12.ForumScreen());
    },
  );
}

/// generated route for
/// [_i13.ForumSettingsScreen]
class ForumSettingsRoute extends _i33.PageRouteInfo<ForumSettingsRouteArgs> {
  ForumSettingsRoute({
    _i34.Key? key,
    required int forumId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         ForumSettingsRoute.name,
         args: ForumSettingsRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumSettingsRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumSettingsRouteArgs>(
        orElse: () =>
            ForumSettingsRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i33.WrappedRoute(
        child: _i13.ForumSettingsScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumSettingsRouteArgs {
  const ForumSettingsRouteArgs({this.key, required this.forumId});

  final _i34.Key? key;

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
/// [_i14.FundraisingDetailScreen]
class FundraisingDetailRoute
    extends _i33.PageRouteInfo<FundraisingDetailRouteArgs> {
  FundraisingDetailRoute({
    _i34.Key? key,
    required int id,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         FundraisingDetailRoute.name,
         args: FundraisingDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'FundraisingDetailRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FundraisingDetailRouteArgs>(
        orElse: () => FundraisingDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i33.WrappedRoute(
        child: _i14.FundraisingDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class FundraisingDetailRouteArgs {
  const FundraisingDetailRouteArgs({this.key, required this.id});

  final _i34.Key? key;

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
/// [_i15.FundraisingScreen]
class FundraisingRoute extends _i33.PageRouteInfo<void> {
  const FundraisingRoute({List<_i33.PageRouteInfo>? children})
    : super(FundraisingRoute.name, initialChildren: children);

  static const String name = 'FundraisingRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i15.FundraisingScreen());
    },
  );
}

/// generated route for
/// [_i16.HomeScreen]
class HomeRoute extends _i33.PageRouteInfo<void> {
  const HomeRoute({List<_i33.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i16.HomeScreen());
    },
  );
}

/// generated route for
/// [_i17.MainScreen]
class MainRoute extends _i33.PageRouteInfo<MainRouteArgs> {
  MainRoute({
    _i34.Key? key,
    int? initialIndex,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         MainRoute.name,
         args: MainRouteArgs(key: key, initialIndex: initialIndex),
         initialChildren: children,
       );

  static const String name = 'MainRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainRouteArgs>(
        orElse: () => const MainRouteArgs(),
      );
      return _i33.WrappedRoute(
        child: _i17.MainScreen(key: args.key, initialIndex: args.initialIndex),
      );
    },
  );
}

class MainRouteArgs {
  const MainRouteArgs({this.key, this.initialIndex});

  final _i34.Key? key;

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
/// [_i18.MapScreen]
class MapRoute extends _i33.PageRouteInfo<void> {
  const MapRoute({List<_i33.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return const _i18.MapScreen();
    },
  );
}

/// generated route for
/// [_i19.NoInternetScreen]
class NoInternetRoute extends _i33.PageRouteInfo<NoInternetRouteArgs> {
  NoInternetRoute({
    _i34.Key? key,
    dynamic Function(bool)? onResult,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         NoInternetRoute.name,
         args: NoInternetRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'NoInternetRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoInternetRouteArgs>(
        orElse: () => const NoInternetRouteArgs(),
      );
      return _i19.NoInternetScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class NoInternetRouteArgs {
  const NoInternetRouteArgs({this.key, this.onResult});

  final _i34.Key? key;

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
/// [_i20.NotfoundScreen]
class NotfoundRoute extends _i33.PageRouteInfo<void> {
  const NotfoundRoute({List<_i33.PageRouteInfo>? children})
    : super(NotfoundRoute.name, initialChildren: children);

  static const String name = 'NotfoundRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return const _i20.NotfoundScreen();
    },
  );
}

/// generated route for
/// [_i21.NotificationDetailScreen]
class NotificationDetailRoute
    extends _i33.PageRouteInfo<NotificationDetailRouteArgs> {
  NotificationDetailRoute({
    _i34.Key? key,
    required _i35.Notification notification,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         NotificationDetailRoute.name,
         args: NotificationDetailRouteArgs(
           key: key,
           notification: notification,
         ),
         initialChildren: children,
       );

  static const String name = 'NotificationDetailRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationDetailRouteArgs>();
      return _i21.NotificationDetailScreen(
        key: args.key,
        notification: args.notification,
      );
    },
  );
}

class NotificationDetailRouteArgs {
  const NotificationDetailRouteArgs({this.key, required this.notification});

  final _i34.Key? key;

  final _i35.Notification notification;

  @override
  String toString() {
    return 'NotificationDetailRouteArgs{key: $key, notification: $notification}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationDetailRouteArgs) return false;
    return key == other.key && notification == other.notification;
  }

  @override
  int get hashCode => key.hashCode ^ notification.hashCode;
}

/// generated route for
/// [_i22.NotificationScreen]
class NotificationRoute extends _i33.PageRouteInfo<void> {
  const NotificationRoute({List<_i33.PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i22.NotificationScreen());
    },
  );
}

/// generated route for
/// [_i23.OnboardingScreen]
class OnboardingRoute extends _i33.PageRouteInfo<void> {
  const OnboardingRoute({List<_i33.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return const _i23.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i24.PaymentMethodScreen]
class PaymentMethodRoute extends _i33.PageRouteInfo<PaymentMethodRouteArgs> {
  PaymentMethodRoute({
    _i34.Key? key,
    required String paymongoId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         PaymentMethodRoute.name,
         args: PaymentMethodRouteArgs(key: key, paymongoId: paymongoId),
         initialChildren: children,
       );

  static const String name = 'PaymentMethodRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentMethodRouteArgs>();
      return _i24.PaymentMethodScreen(
        key: args.key,
        paymongoId: args.paymongoId,
      );
    },
  );
}

class PaymentMethodRouteArgs {
  const PaymentMethodRouteArgs({this.key, required this.paymongoId});

  final _i34.Key? key;

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
/// [_i25.PaymentScreen]
class PaymentRoute extends _i33.PageRouteInfo<PaymentRouteArgs> {
  PaymentRoute({
    _i34.Key? key,
    required int fundraisingId,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         PaymentRoute.name,
         args: PaymentRouteArgs(key: key, fundraisingId: fundraisingId),
         rawPathParams: {'id': fundraisingId},
         initialChildren: children,
       );

  static const String name = 'PaymentRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentRouteArgs>(
        orElse: () => PaymentRouteArgs(fundraisingId: pathParams.getInt('id')),
      );
      return _i33.WrappedRoute(
        child: _i25.PaymentScreen(
          key: args.key,
          fundraisingId: args.fundraisingId,
        ),
      );
    },
  );
}

class PaymentRouteArgs {
  const PaymentRouteArgs({this.key, required this.fundraisingId});

  final _i34.Key? key;

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
/// [_i26.PaymentSuccessScreen]
class PaymentSuccessRoute extends _i33.PageRouteInfo<PaymentSuccessRouteArgs> {
  PaymentSuccessRoute({
    _i34.Key? key,
    required int id,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessRoute.name,
         args: PaymentSuccessRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentSuccessRouteArgs>(
        orElse: () => PaymentSuccessRouteArgs(id: pathParams.getInt('id')),
      );
      return _i26.PaymentSuccessScreen(key: args.key, id: args.id);
    },
  );
}

class PaymentSuccessRouteArgs {
  const PaymentSuccessRouteArgs({this.key, required this.id});

  final _i34.Key? key;

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
/// [_i27.PetDetailScreen]
class PetDetailRoute extends _i33.PageRouteInfo<PetDetailRouteArgs> {
  PetDetailRoute({
    _i34.Key? key,
    required _i36.Pet pet,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         PetDetailRoute.name,
         args: PetDetailRouteArgs(key: key, pet: pet),
         initialChildren: children,
       );

  static const String name = 'PetDetailRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PetDetailRouteArgs>();
      return _i33.WrappedRoute(
        child: _i27.PetDetailScreen(key: args.key, pet: args.pet),
      );
    },
  );
}

class PetDetailRouteArgs {
  const PetDetailRouteArgs({this.key, required this.pet});

  final _i34.Key? key;

  final _i36.Pet pet;

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
/// [_i28.PetScreen]
class PetRoute extends _i33.PageRouteInfo<void> {
  const PetRoute({List<_i33.PageRouteInfo>? children})
    : super(PetRoute.name, initialChildren: children);

  static const String name = 'PetRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i28.PetScreen());
    },
  );
}

/// generated route for
/// [_i29.ProfileScreen]
class ProfileRoute extends _i33.PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    _i34.Key? key,
    required String id,
    List<_i33.PageRouteInfo>? children,
  }) : super(
         ProfileRoute.name,
         args: ProfileRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ProfileRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileRouteArgs>();
      return _i33.WrappedRoute(
        child: _i29.ProfileScreen(key: args.key, id: args.id),
      );
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key, required this.id});

  final _i34.Key? key;

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
/// [_i30.SetUpVerificationScreen]
class SetUpVerificationRoute extends _i33.PageRouteInfo<void> {
  const SetUpVerificationRoute({List<_i33.PageRouteInfo>? children})
    : super(SetUpVerificationRoute.name, initialChildren: children);

  static const String name = 'SetUpVerificationRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return const _i30.SetUpVerificationScreen();
    },
  );
}

/// generated route for
/// [_i31.SignInScreen]
class SignInRoute extends _i33.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i34.Key? key,
    void Function(bool)? onResult,
    String? email,
    String? password,
    List<_i33.PageRouteInfo>? children,
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

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i33.WrappedRoute(
        child: _i31.SignInScreen(
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

  final _i34.Key? key;

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

/// generated route for
/// [_i32.UserHouseScreen]
class UserHouseRoute extends _i33.PageRouteInfo<void> {
  const UserHouseRoute({List<_i33.PageRouteInfo>? children})
    : super(UserHouseRoute.name, initialChildren: children);

  static const String name = 'UserHouseRoute';

  static _i33.PageInfo page = _i33.PageInfo(
    name,
    builder: (data) {
      return _i33.WrappedRoute(child: const _i32.UserHouseScreen());
    },
  );
}
