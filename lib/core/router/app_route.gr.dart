// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:flutter/material.dart' as _i23;
import 'package:paws_connect/features/auth/screens/auth_screen.dart' as _i21;
import 'package:paws_connect/features/auth/screens/onboarding_screen.dart'
    as _i14;
import 'package:paws_connect/features/forum/screens/add_forum_member_screen.dart'
    as _i1;
import 'package:paws_connect/features/forum/screens/add_forum_screen.dart'
    as _i2;
import 'package:paws_connect/features/forum/screens/forum_chat_screen.dart'
    as _i4;
import 'package:paws_connect/features/forum/screens/forum_screen.dart' as _i5;
import 'package:paws_connect/features/forum/screens/forum_settings_screen.dart'
    as _i6;
import 'package:paws_connect/features/fundraising/screens/fundraising_detail_screen.dart'
    as _i7;
import 'package:paws_connect/features/fundraising/screens/fundraising_screen.dart'
    as _i8;
import 'package:paws_connect/features/google_map/screens/map_screen.dart'
    as _i11;
import 'package:paws_connect/features/main/screens/home_screen.dart' as _i9;
import 'package:paws_connect/features/main/screens/main_screen.dart' as _i10;
import 'package:paws_connect/features/main/screens/no_internet_screen.dart'
    as _i12;
import 'package:paws_connect/features/main/screens/notfound_screen.dart'
    as _i13;
import 'package:paws_connect/features/payment/screens/payment_method_screen.dart'
    as _i15;
import 'package:paws_connect/features/payment/screens/payment_screen.dart'
    as _i16;
import 'package:paws_connect/features/payment/screens/payment_success_screen.dart'
    as _i17;
import 'package:paws_connect/features/pets/models/pet_model.dart' as _i24;
import 'package:paws_connect/features/pets/screens/extensions/pet_detail_screen.dart'
    as _i18;
import 'package:paws_connect/features/pets/screens/pet_screen.dart' as _i19;
import 'package:paws_connect/features/profile/screens/edit_profile_screen.dart'
    as _i3;
import 'package:paws_connect/features/profile/screens/profile_screen.dart'
    as _i20;

/// generated route for
/// [_i1.AddForumMemberScreen]
class AddForumMemberRoute extends _i22.PageRouteInfo<AddForumMemberRouteArgs> {
  AddForumMemberRoute({
    _i23.Key? key,
    required int forumId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         AddForumMemberRoute.name,
         args: AddForumMemberRouteArgs(key: key, forumId: forumId),
         initialChildren: children,
       );

  static const String name = 'AddForumMemberRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddForumMemberRouteArgs>();
      return _i22.WrappedRoute(
        child: _i1.AddForumMemberScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class AddForumMemberRouteArgs {
  const AddForumMemberRouteArgs({this.key, required this.forumId});

  final _i23.Key? key;

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
class AddForumRoute extends _i22.PageRouteInfo<void> {
  const AddForumRoute({List<_i22.PageRouteInfo>? children})
    : super(AddForumRoute.name, initialChildren: children);

  static const String name = 'AddForumRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.AddForumScreen();
    },
  );
}

/// generated route for
/// [_i3.EditProfileScreen]
class EditProfileRoute extends _i22.PageRouteInfo<void> {
  const EditProfileRoute({List<_i22.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i22.WrappedRoute(child: const _i3.EditProfileScreen());
    },
  );
}

/// generated route for
/// [_i4.ForumChatScreen]
class ForumChatRoute extends _i22.PageRouteInfo<ForumChatRouteArgs> {
  ForumChatRoute({
    _i23.Key? key,
    required int forumId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         ForumChatRoute.name,
         args: ForumChatRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumChatRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumChatRouteArgs>(
        orElse: () => ForumChatRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i22.WrappedRoute(
        child: _i4.ForumChatScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumChatRouteArgs {
  const ForumChatRouteArgs({this.key, required this.forumId});

  final _i23.Key? key;

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
/// [_i5.ForumScreen]
class ForumRoute extends _i22.PageRouteInfo<void> {
  const ForumRoute({List<_i22.PageRouteInfo>? children})
    : super(ForumRoute.name, initialChildren: children);

  static const String name = 'ForumRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i22.WrappedRoute(child: const _i5.ForumScreen());
    },
  );
}

/// generated route for
/// [_i6.ForumSettingsScreen]
class ForumSettingsRoute extends _i22.PageRouteInfo<ForumSettingsRouteArgs> {
  ForumSettingsRoute({
    _i23.Key? key,
    required int forumId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         ForumSettingsRoute.name,
         args: ForumSettingsRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumSettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumSettingsRouteArgs>(
        orElse: () =>
            ForumSettingsRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i22.WrappedRoute(
        child: _i6.ForumSettingsScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumSettingsRouteArgs {
  const ForumSettingsRouteArgs({this.key, required this.forumId});

  final _i23.Key? key;

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
/// [_i7.FundraisingDetailScreen]
class FundraisingDetailRoute
    extends _i22.PageRouteInfo<FundraisingDetailRouteArgs> {
  FundraisingDetailRoute({
    _i23.Key? key,
    required int id,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         FundraisingDetailRoute.name,
         args: FundraisingDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'FundraisingDetailRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FundraisingDetailRouteArgs>(
        orElse: () => FundraisingDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i22.WrappedRoute(
        child: _i7.FundraisingDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class FundraisingDetailRouteArgs {
  const FundraisingDetailRouteArgs({this.key, required this.id});

  final _i23.Key? key;

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
/// [_i8.FundraisingScreen]
class FundraisingRoute extends _i22.PageRouteInfo<void> {
  const FundraisingRoute({List<_i22.PageRouteInfo>? children})
    : super(FundraisingRoute.name, initialChildren: children);

  static const String name = 'FundraisingRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i22.WrappedRoute(child: const _i8.FundraisingScreen());
    },
  );
}

/// generated route for
/// [_i9.HomeScreen]
class HomeRoute extends _i22.PageRouteInfo<void> {
  const HomeRoute({List<_i22.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i22.WrappedRoute(child: const _i9.HomeScreen());
    },
  );
}

/// generated route for
/// [_i10.MainScreen]
class MainRoute extends _i22.PageRouteInfo<void> {
  const MainRoute({List<_i22.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.MainScreen();
    },
  );
}

/// generated route for
/// [_i11.MapScreen]
class MapRoute extends _i22.PageRouteInfo<void> {
  const MapRoute({List<_i22.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.MapScreen();
    },
  );
}

/// generated route for
/// [_i12.NoInternetScreen]
class NoInternetRoute extends _i22.PageRouteInfo<NoInternetRouteArgs> {
  NoInternetRoute({
    _i23.Key? key,
    dynamic Function(bool)? onResult,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         NoInternetRoute.name,
         args: NoInternetRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'NoInternetRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoInternetRouteArgs>(
        orElse: () => const NoInternetRouteArgs(),
      );
      return _i12.NoInternetScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class NoInternetRouteArgs {
  const NoInternetRouteArgs({this.key, this.onResult});

  final _i23.Key? key;

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
/// [_i13.NotfoundScreen]
class NotfoundRoute extends _i22.PageRouteInfo<void> {
  const NotfoundRoute({List<_i22.PageRouteInfo>? children})
    : super(NotfoundRoute.name, initialChildren: children);

  static const String name = 'NotfoundRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i13.NotfoundScreen();
    },
  );
}

/// generated route for
/// [_i14.OnboardingScreen]
class OnboardingRoute extends _i22.PageRouteInfo<void> {
  const OnboardingRoute({List<_i22.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i14.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i15.PaymentMethodScreen]
class PaymentMethodRoute extends _i22.PageRouteInfo<PaymentMethodRouteArgs> {
  PaymentMethodRoute({
    _i23.Key? key,
    required String paymongoId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         PaymentMethodRoute.name,
         args: PaymentMethodRouteArgs(key: key, paymongoId: paymongoId),
         initialChildren: children,
       );

  static const String name = 'PaymentMethodRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentMethodRouteArgs>();
      return _i15.PaymentMethodScreen(
        key: args.key,
        paymongoId: args.paymongoId,
      );
    },
  );
}

class PaymentMethodRouteArgs {
  const PaymentMethodRouteArgs({this.key, required this.paymongoId});

  final _i23.Key? key;

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
/// [_i16.PaymentScreen]
class PaymentRoute extends _i22.PageRouteInfo<PaymentRouteArgs> {
  PaymentRoute({
    _i23.Key? key,
    required int fundraisingId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         PaymentRoute.name,
         args: PaymentRouteArgs(key: key, fundraisingId: fundraisingId),
         rawPathParams: {'id': fundraisingId},
         initialChildren: children,
       );

  static const String name = 'PaymentRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentRouteArgs>(
        orElse: () => PaymentRouteArgs(fundraisingId: pathParams.getInt('id')),
      );
      return _i22.WrappedRoute(
        child: _i16.PaymentScreen(
          key: args.key,
          fundraisingId: args.fundraisingId,
        ),
      );
    },
  );
}

class PaymentRouteArgs {
  const PaymentRouteArgs({this.key, required this.fundraisingId});

  final _i23.Key? key;

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
/// [_i17.PaymentSuccessScreen]
class PaymentSuccessRoute extends _i22.PageRouteInfo<PaymentSuccessRouteArgs> {
  PaymentSuccessRoute({
    _i23.Key? key,
    required int id,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessRoute.name,
         args: PaymentSuccessRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentSuccessRouteArgs>(
        orElse: () => PaymentSuccessRouteArgs(id: pathParams.getInt('id')),
      );
      return _i17.PaymentSuccessScreen(key: args.key, id: args.id);
    },
  );
}

class PaymentSuccessRouteArgs {
  const PaymentSuccessRouteArgs({this.key, required this.id});

  final _i23.Key? key;

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
/// [_i18.PetDetailScreen]
class PetDetailRoute extends _i22.PageRouteInfo<PetDetailRouteArgs> {
  PetDetailRoute({
    _i23.Key? key,
    required _i24.Pet pet,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         PetDetailRoute.name,
         args: PetDetailRouteArgs(key: key, pet: pet),
         initialChildren: children,
       );

  static const String name = 'PetDetailRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PetDetailRouteArgs>();
      return _i18.PetDetailScreen(key: args.key, pet: args.pet);
    },
  );
}

class PetDetailRouteArgs {
  const PetDetailRouteArgs({this.key, required this.pet});

  final _i23.Key? key;

  final _i24.Pet pet;

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
/// [_i19.PetScreen]
class PetRoute extends _i22.PageRouteInfo<void> {
  const PetRoute({List<_i22.PageRouteInfo>? children})
    : super(PetRoute.name, initialChildren: children);

  static const String name = 'PetRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i22.WrappedRoute(child: const _i19.PetScreen());
    },
  );
}

/// generated route for
/// [_i20.ProfileScreen]
class ProfileRoute extends _i22.PageRouteInfo<void> {
  const ProfileRoute({List<_i22.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i22.WrappedRoute(child: const _i20.ProfileScreen());
    },
  );
}

/// generated route for
/// [_i21.SignInScreen]
class SignInRoute extends _i22.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i23.Key? key,
    void Function(bool)? onResult,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         SignInRoute.name,
         args: SignInRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignInRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i22.WrappedRoute(
        child: _i21.SignInScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.onResult});

  final _i23.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'SignInRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignInRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}
