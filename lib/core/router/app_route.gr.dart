// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i46;
import 'package:flutter/material.dart' as _i47;
import 'package:paws_connect/features/adoption/screens/adoption_detail_screen.dart'
    as _i3;
import 'package:paws_connect/features/adoption/screens/adoption_history_screen.dart'
    as _i4;
import 'package:paws_connect/features/adoption/screens/adoption_success_screen.dart'
    as _i5;
import 'package:paws_connect/features/adoption/screens/create_adoption_screen.dart'
    as _i11;
import 'package:paws_connect/features/auth/screens/auth_screen.dart' as _i43;
import 'package:paws_connect/features/auth/screens/change_password_screen.dart'
    as _i8;
import 'package:paws_connect/features/auth/screens/contact_support_screen.dart'
    as _i10;
import 'package:paws_connect/features/auth/screens/forgot_password_screen.dart'
    as _i17;
import 'package:paws_connect/features/auth/screens/indefinite_user_screen.dart'
    as _i24;
import 'package:paws_connect/features/auth/screens/onboarding_screen.dart'
    as _i32;
import 'package:paws_connect/features/auth/screens/otp_verification_screen.dart'
    as _i31;
import 'package:paws_connect/features/auth/screens/reset_password_screen.dart'
    as _i41;
import 'package:paws_connect/features/donation/screens/donation_history_screen.dart'
    as _i13;
import 'package:paws_connect/features/events/screens/event_detail_screen.dart'
    as _i15;
import 'package:paws_connect/features/favorite/screens/favorite_screen.dart'
    as _i16;
import 'package:paws_connect/features/forum/screens/add_forum_member_screen.dart'
    as _i1;
import 'package:paws_connect/features/forum/screens/add_forum_screen.dart'
    as _i2;
import 'package:paws_connect/features/forum/screens/forum_chat_screen.dart'
    as _i18;
import 'package:paws_connect/features/forum/screens/forum_screen.dart' as _i19;
import 'package:paws_connect/features/forum/screens/forum_settings_screen.dart'
    as _i20;
import 'package:paws_connect/features/fundraising/screens/fundraising_detail_screen.dart'
    as _i21;
import 'package:paws_connect/features/fundraising/screens/fundraising_screen.dart'
    as _i22;
import 'package:paws_connect/features/google_map/screens/map_screen.dart'
    as _i26;
import 'package:paws_connect/features/main/screens/home_screen.dart' as _i23;
import 'package:paws_connect/features/main/screens/main_screen.dart' as _i25;
import 'package:paws_connect/features/main/screens/no_internet_screen.dart'
    as _i27;
import 'package:paws_connect/features/main/screens/not_found_screen.dart'
    as _i28;
import 'package:paws_connect/features/notifications/models/notification_model.dart'
    as _i49;
import 'package:paws_connect/features/notifications/screens/notification_detail_screen.dart'
    as _i29;
import 'package:paws_connect/features/notifications/screens/notification_screen.dart'
    as _i30;
import 'package:paws_connect/features/payment/screens/payment_method_screen.dart'
    as _i33;
import 'package:paws_connect/features/payment/screens/payment_screen.dart'
    as _i34;
import 'package:paws_connect/features/payment/screens/payment_success_screen.dart'
    as _i35;
import 'package:paws_connect/features/pets/screens/extensions/breeg_gallery_screen.dart'
    as _i6;
import 'package:paws_connect/features/pets/screens/extensions/cat_care_screen.dart'
    as _i7;
import 'package:paws_connect/features/pets/screens/extensions/dog_care_screen.dart'
    as _i12;
import 'package:paws_connect/features/pets/screens/extensions/pet_detail_screen.dart'
    as _i36;
import 'package:paws_connect/features/pets/screens/pet_screen.dart' as _i37;
import 'package:paws_connect/features/posts/provider/posts_provider.dart'
    as _i48;
import 'package:paws_connect/features/posts/screens/comments_screen.dart'
    as _i9;
import 'package:paws_connect/features/posts/screens/posts_screen.dart' as _i38;
import 'package:paws_connect/features/posts/screens/reactions_screen.dart'
    as _i40;
import 'package:paws_connect/features/profile/screens/edit_profile_screen.dart'
    as _i14;
import 'package:paws_connect/features/profile/screens/profile_screen.dart'
    as _i39;
import 'package:paws_connect/features/profile/screens/user_house_screen.dart'
    as _i44;
import 'package:paws_connect/features/settings/screens/user_settings_screen.dart'
    as _i45;
import 'package:paws_connect/features/verification/screens/setup_verification_screen.dart'
    as _i42;

/// generated route for
/// [_i1.AddForumMemberScreen]
class AddForumMemberRoute extends _i46.PageRouteInfo<AddForumMemberRouteArgs> {
  AddForumMemberRoute({
    _i47.Key? key,
    required int forumId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         AddForumMemberRoute.name,
         args: AddForumMemberRouteArgs(key: key, forumId: forumId),
         initialChildren: children,
       );

  static const String name = 'AddForumMemberRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddForumMemberRouteArgs>();
      return _i46.WrappedRoute(
        child: _i1.AddForumMemberScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class AddForumMemberRouteArgs {
  const AddForumMemberRouteArgs({this.key, required this.forumId});

  final _i47.Key? key;

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
class AddForumRoute extends _i46.PageRouteInfo<void> {
  const AddForumRoute({List<_i46.PageRouteInfo>? children})
    : super(AddForumRoute.name, initialChildren: children);

  static const String name = 'AddForumRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i2.AddForumScreen());
    },
  );
}

/// generated route for
/// [_i3.AdoptionDetailScreen]
class AdoptionDetailRoute extends _i46.PageRouteInfo<AdoptionDetailRouteArgs> {
  AdoptionDetailRoute({
    _i47.Key? key,
    required int id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         AdoptionDetailRoute.name,
         args: AdoptionDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'AdoptionDetailRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdoptionDetailRouteArgs>();
      return _i46.WrappedRoute(
        child: _i3.AdoptionDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class AdoptionDetailRouteArgs {
  const AdoptionDetailRouteArgs({this.key, required this.id});

  final _i47.Key? key;

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
class AdoptionHistoryRoute extends _i46.PageRouteInfo<void> {
  const AdoptionHistoryRoute({List<_i46.PageRouteInfo>? children})
    : super(AdoptionHistoryRoute.name, initialChildren: children);

  static const String name = 'AdoptionHistoryRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i4.AdoptionHistoryScreen());
    },
  );
}

/// generated route for
/// [_i5.AdoptionSuccessScreen]
class AdoptionSuccessRoute
    extends _i46.PageRouteInfo<AdoptionSuccessRouteArgs> {
  AdoptionSuccessRoute({
    _i47.Key? key,
    String? petName,
    String? applicationId,
    List<_i46.PageRouteInfo>? children,
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

  static _i46.PageInfo page = _i46.PageInfo(
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

  final _i47.Key? key;

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
/// [_i6.BreedGalleryScreen]
class BreedGalleryRoute extends _i46.PageRouteInfo<void> {
  const BreedGalleryRoute({List<_i46.PageRouteInfo>? children})
    : super(BreedGalleryRoute.name, initialChildren: children);

  static const String name = 'BreedGalleryRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i6.BreedGalleryScreen();
    },
  );
}

/// generated route for
/// [_i7.CatCareScreen]
class CatCareRoute extends _i46.PageRouteInfo<void> {
  const CatCareRoute({List<_i46.PageRouteInfo>? children})
    : super(CatCareRoute.name, initialChildren: children);

  static const String name = 'CatCareRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i7.CatCareScreen();
    },
  );
}

/// generated route for
/// [_i8.ChangePasswordScreen]
class ChangePasswordRoute extends _i46.PageRouteInfo<ChangePasswordRouteArgs> {
  ChangePasswordRoute({
    _i47.Key? key,
    void Function(bool)? onResult,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ChangePasswordRoute.name,
         args: ChangePasswordRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'ChangePasswordRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangePasswordRouteArgs>(
        orElse: () => const ChangePasswordRouteArgs(),
      );
      return _i46.WrappedRoute(
        child: _i8.ChangePasswordScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class ChangePasswordRouteArgs {
  const ChangePasswordRouteArgs({this.key, this.onResult});

  final _i47.Key? key;

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
/// [_i9.CommentsScreen]
class CommentsRoute extends _i46.PageRouteInfo<CommentsRouteArgs> {
  CommentsRoute({
    _i47.Key? key,
    required _i48.Post post,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         CommentsRoute.name,
         args: CommentsRouteArgs(key: key, post: post),
         initialChildren: children,
       );

  static const String name = 'CommentsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommentsRouteArgs>();
      return _i46.WrappedRoute(
        child: _i9.CommentsScreen(key: args.key, post: args.post),
      );
    },
  );
}

class CommentsRouteArgs {
  const CommentsRouteArgs({this.key, required this.post});

  final _i47.Key? key;

  final _i48.Post post;

  @override
  String toString() {
    return 'CommentsRouteArgs{key: $key, post: $post}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CommentsRouteArgs) return false;
    return key == other.key && post == other.post;
  }

  @override
  int get hashCode => key.hashCode ^ post.hashCode;
}

/// generated route for
/// [_i10.ContactSupportScreen]
class ContactSupportRoute extends _i46.PageRouteInfo<void> {
  const ContactSupportRoute({List<_i46.PageRouteInfo>? children})
    : super(ContactSupportRoute.name, initialChildren: children);

  static const String name = 'ContactSupportRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i10.ContactSupportScreen());
    },
  );
}

/// generated route for
/// [_i11.CreateAdoptionScreen]
class CreateAdoptionRoute extends _i46.PageRouteInfo<CreateAdoptionRouteArgs> {
  CreateAdoptionRoute({
    _i47.Key? key,
    required int petId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         CreateAdoptionRoute.name,
         args: CreateAdoptionRouteArgs(key: key, petId: petId),
         rawPathParams: {'petId': petId},
         initialChildren: children,
       );

  static const String name = 'CreateAdoptionRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreateAdoptionRouteArgs>(
        orElse: () =>
            CreateAdoptionRouteArgs(petId: pathParams.getInt('petId')),
      );
      return _i46.WrappedRoute(
        child: _i11.CreateAdoptionScreen(key: args.key, petId: args.petId),
      );
    },
  );
}

class CreateAdoptionRouteArgs {
  const CreateAdoptionRouteArgs({this.key, required this.petId});

  final _i47.Key? key;

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
/// [_i12.DogCareScreen]
class DogCareRoute extends _i46.PageRouteInfo<void> {
  const DogCareRoute({List<_i46.PageRouteInfo>? children})
    : super(DogCareRoute.name, initialChildren: children);

  static const String name = 'DogCareRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i12.DogCareScreen();
    },
  );
}

/// generated route for
/// [_i13.DonationHistoryScreen]
class DonationHistoryRoute extends _i46.PageRouteInfo<void> {
  const DonationHistoryRoute({List<_i46.PageRouteInfo>? children})
    : super(DonationHistoryRoute.name, initialChildren: children);

  static const String name = 'DonationHistoryRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i13.DonationHistoryScreen());
    },
  );
}

/// generated route for
/// [_i14.EditProfileScreen]
class EditProfileRoute extends _i46.PageRouteInfo<void> {
  const EditProfileRoute({List<_i46.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i14.EditProfileScreen());
    },
  );
}

/// generated route for
/// [_i15.EventDetailScreen]
class EventDetailRoute extends _i46.PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    _i47.Key? key,
    required int id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         EventDetailRoute.name,
         args: EventDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'EventDetailRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EventDetailRouteArgs>(
        orElse: () => EventDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i46.WrappedRoute(
        child: _i15.EventDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({this.key, required this.id});

  final _i47.Key? key;

  final int id;

  @override
  String toString() {
    return 'EventDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i16.FavoriteScreen]
class FavoriteRoute extends _i46.PageRouteInfo<void> {
  const FavoriteRoute({List<_i46.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i16.FavoriteScreen());
    },
  );
}

/// generated route for
/// [_i17.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i46.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i46.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i17.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i18.ForumChatScreen]
class ForumChatRoute extends _i46.PageRouteInfo<ForumChatRouteArgs> {
  ForumChatRoute({
    _i47.Key? key,
    required int forumId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ForumChatRoute.name,
         args: ForumChatRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumChatRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumChatRouteArgs>(
        orElse: () => ForumChatRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i46.WrappedRoute(
        child: _i18.ForumChatScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumChatRouteArgs {
  const ForumChatRouteArgs({this.key, required this.forumId});

  final _i47.Key? key;

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
/// [_i19.ForumScreen]
class ForumRoute extends _i46.PageRouteInfo<void> {
  const ForumRoute({List<_i46.PageRouteInfo>? children})
    : super(ForumRoute.name, initialChildren: children);

  static const String name = 'ForumRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i19.ForumScreen());
    },
  );
}

/// generated route for
/// [_i20.ForumSettingsScreen]
class ForumSettingsRoute extends _i46.PageRouteInfo<ForumSettingsRouteArgs> {
  ForumSettingsRoute({
    _i47.Key? key,
    required int forumId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ForumSettingsRoute.name,
         args: ForumSettingsRouteArgs(key: key, forumId: forumId),
         rawPathParams: {'forumId': forumId},
         initialChildren: children,
       );

  static const String name = 'ForumSettingsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ForumSettingsRouteArgs>(
        orElse: () =>
            ForumSettingsRouteArgs(forumId: pathParams.getInt('forumId')),
      );
      return _i46.WrappedRoute(
        child: _i20.ForumSettingsScreen(key: args.key, forumId: args.forumId),
      );
    },
  );
}

class ForumSettingsRouteArgs {
  const ForumSettingsRouteArgs({this.key, required this.forumId});

  final _i47.Key? key;

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
/// [_i21.FundraisingDetailScreen]
class FundraisingDetailRoute
    extends _i46.PageRouteInfo<FundraisingDetailRouteArgs> {
  FundraisingDetailRoute({
    _i47.Key? key,
    required int id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         FundraisingDetailRoute.name,
         args: FundraisingDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'FundraisingDetailRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FundraisingDetailRouteArgs>(
        orElse: () => FundraisingDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i46.WrappedRoute(
        child: _i21.FundraisingDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class FundraisingDetailRouteArgs {
  const FundraisingDetailRouteArgs({this.key, required this.id});

  final _i47.Key? key;

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
/// [_i22.FundraisingScreen]
class FundraisingRoute extends _i46.PageRouteInfo<void> {
  const FundraisingRoute({List<_i46.PageRouteInfo>? children})
    : super(FundraisingRoute.name, initialChildren: children);

  static const String name = 'FundraisingRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i22.FundraisingScreen());
    },
  );
}

/// generated route for
/// [_i23.HomeScreen]
class HomeRoute extends _i46.PageRouteInfo<void> {
  const HomeRoute({List<_i46.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i23.HomeScreen());
    },
  );
}

/// generated route for
/// [_i24.IndefiniteUserScreen]
class IndefiniteUserRoute extends _i46.PageRouteInfo<void> {
  const IndefiniteUserRoute({List<_i46.PageRouteInfo>? children})
    : super(IndefiniteUserRoute.name, initialChildren: children);

  static const String name = 'IndefiniteUserRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i24.IndefiniteUserScreen();
    },
  );
}

/// generated route for
/// [_i25.MainScreen]
class MainRoute extends _i46.PageRouteInfo<MainRouteArgs> {
  MainRoute({
    _i47.Key? key,
    int? initialIndex,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         MainRoute.name,
         args: MainRouteArgs(key: key, initialIndex: initialIndex),
         initialChildren: children,
       );

  static const String name = 'MainRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainRouteArgs>(
        orElse: () => const MainRouteArgs(),
      );
      return _i46.WrappedRoute(
        child: _i25.MainScreen(key: args.key, initialIndex: args.initialIndex),
      );
    },
  );
}

class MainRouteArgs {
  const MainRouteArgs({this.key, this.initialIndex});

  final _i47.Key? key;

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
/// [_i26.MapScreen]
class MapRoute extends _i46.PageRouteInfo<void> {
  const MapRoute({List<_i46.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i26.MapScreen();
    },
  );
}

/// generated route for
/// [_i27.NoInternetScreen]
class NoInternetRoute extends _i46.PageRouteInfo<NoInternetRouteArgs> {
  NoInternetRoute({
    _i47.Key? key,
    dynamic Function(bool)? onResult,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         NoInternetRoute.name,
         args: NoInternetRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'NoInternetRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoInternetRouteArgs>(
        orElse: () => const NoInternetRouteArgs(),
      );
      return _i27.NoInternetScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class NoInternetRouteArgs {
  const NoInternetRouteArgs({this.key, this.onResult});

  final _i47.Key? key;

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
/// [_i28.NotfoundScreen]
class NotfoundRoute extends _i46.PageRouteInfo<void> {
  const NotfoundRoute({List<_i46.PageRouteInfo>? children})
    : super(NotfoundRoute.name, initialChildren: children);

  static const String name = 'NotfoundRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i28.NotfoundScreen();
    },
  );
}

/// generated route for
/// [_i29.NotificationDetailScreen]
class NotificationDetailRoute
    extends _i46.PageRouteInfo<NotificationDetailRouteArgs> {
  NotificationDetailRoute({
    _i47.Key? key,
    required _i49.Notification notification,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         NotificationDetailRoute.name,
         args: NotificationDetailRouteArgs(
           key: key,
           notification: notification,
         ),
         initialChildren: children,
       );

  static const String name = 'NotificationDetailRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationDetailRouteArgs>();
      return _i29.NotificationDetailScreen(
        key: args.key,
        notification: args.notification,
      );
    },
  );
}

class NotificationDetailRouteArgs {
  const NotificationDetailRouteArgs({this.key, required this.notification});

  final _i47.Key? key;

  final _i49.Notification notification;

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
/// [_i30.NotificationScreen]
class NotificationRoute extends _i46.PageRouteInfo<void> {
  const NotificationRoute({List<_i46.PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i30.NotificationScreen());
    },
  );
}

/// generated route for
/// [_i31.OTPVerificationScreen]
class OTPVerificationRoute
    extends _i46.PageRouteInfo<OTPVerificationRouteArgs> {
  OTPVerificationRoute({
    _i47.Key? key,
    required String email,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         OTPVerificationRoute.name,
         args: OTPVerificationRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'OTPVerificationRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OTPVerificationRouteArgs>();
      return _i31.OTPVerificationScreen(key: args.key, email: args.email);
    },
  );
}

class OTPVerificationRouteArgs {
  const OTPVerificationRouteArgs({this.key, required this.email});

  final _i47.Key? key;

  final String email;

  @override
  String toString() {
    return 'OTPVerificationRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OTPVerificationRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [_i32.OnboardingScreen]
class OnboardingRoute extends _i46.PageRouteInfo<void> {
  const OnboardingRoute({List<_i46.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i32.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i33.PaymentMethodScreen]
class PaymentMethodRoute extends _i46.PageRouteInfo<PaymentMethodRouteArgs> {
  PaymentMethodRoute({
    _i47.Key? key,
    required String paymongoId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         PaymentMethodRoute.name,
         args: PaymentMethodRouteArgs(key: key, paymongoId: paymongoId),
         initialChildren: children,
       );

  static const String name = 'PaymentMethodRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentMethodRouteArgs>();
      return _i33.PaymentMethodScreen(
        key: args.key,
        paymongoId: args.paymongoId,
      );
    },
  );
}

class PaymentMethodRouteArgs {
  const PaymentMethodRouteArgs({this.key, required this.paymongoId});

  final _i47.Key? key;

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
/// [_i34.PaymentScreen]
class PaymentRoute extends _i46.PageRouteInfo<PaymentRouteArgs> {
  PaymentRoute({
    _i47.Key? key,
    required int fundraisingId,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         PaymentRoute.name,
         args: PaymentRouteArgs(key: key, fundraisingId: fundraisingId),
         rawPathParams: {'id': fundraisingId},
         initialChildren: children,
       );

  static const String name = 'PaymentRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentRouteArgs>(
        orElse: () => PaymentRouteArgs(fundraisingId: pathParams.getInt('id')),
      );
      return _i46.WrappedRoute(
        child: _i34.PaymentScreen(
          key: args.key,
          fundraisingId: args.fundraisingId,
        ),
      );
    },
  );
}

class PaymentRouteArgs {
  const PaymentRouteArgs({this.key, required this.fundraisingId});

  final _i47.Key? key;

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
/// [_i35.PaymentSuccessScreen]
class PaymentSuccessRoute extends _i46.PageRouteInfo<PaymentSuccessRouteArgs> {
  PaymentSuccessRoute({
    _i47.Key? key,
    required int id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         PaymentSuccessRoute.name,
         args: PaymentSuccessRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PaymentSuccessRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PaymentSuccessRouteArgs>(
        orElse: () => PaymentSuccessRouteArgs(id: pathParams.getInt('id')),
      );
      return _i35.PaymentSuccessScreen(key: args.key, id: args.id);
    },
  );
}

class PaymentSuccessRouteArgs {
  const PaymentSuccessRouteArgs({this.key, required this.id});

  final _i47.Key? key;

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
/// [_i36.PetDetailScreen]
class PetDetailRoute extends _i46.PageRouteInfo<PetDetailRouteArgs> {
  PetDetailRoute({
    _i47.Key? key,
    required int id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         PetDetailRoute.name,
         args: PetDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'PetDetailRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PetDetailRouteArgs>();
      return _i46.WrappedRoute(
        child: _i36.PetDetailScreen(key: args.key, id: args.id),
      );
    },
  );
}

class PetDetailRouteArgs {
  const PetDetailRouteArgs({this.key, required this.id});

  final _i47.Key? key;

  final int id;

  @override
  String toString() {
    return 'PetDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PetDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i37.PetScreen]
class PetRoute extends _i46.PageRouteInfo<void> {
  const PetRoute({List<_i46.PageRouteInfo>? children})
    : super(PetRoute.name, initialChildren: children);

  static const String name = 'PetRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i37.PetScreen());
    },
  );
}

/// generated route for
/// [_i38.PostsScreen]
class PostsRoute extends _i46.PageRouteInfo<void> {
  const PostsRoute({List<_i46.PageRouteInfo>? children})
    : super(PostsRoute.name, initialChildren: children);

  static const String name = 'PostsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i38.PostsScreen());
    },
  );
}

/// generated route for
/// [_i39.ProfileScreen]
class ProfileRoute extends _i46.PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    _i47.Key? key,
    required String id,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ProfileRoute.name,
         args: ProfileRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ProfileRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileRouteArgs>();
      return _i46.WrappedRoute(
        child: _i39.ProfileScreen(key: args.key, id: args.id),
      );
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key, required this.id});

  final _i47.Key? key;

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
/// [_i40.ReactionsScreen]
class ReactionsRoute extends _i46.PageRouteInfo<ReactionsRouteArgs> {
  ReactionsRoute({
    _i47.Key? key,
    required _i48.Post post,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ReactionsRoute.name,
         args: ReactionsRouteArgs(key: key, post: post),
         initialChildren: children,
       );

  static const String name = 'ReactionsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReactionsRouteArgs>();
      return _i40.ReactionsScreen(key: args.key, post: args.post);
    },
  );
}

class ReactionsRouteArgs {
  const ReactionsRouteArgs({this.key, required this.post});

  final _i47.Key? key;

  final _i48.Post post;

  @override
  String toString() {
    return 'ReactionsRouteArgs{key: $key, post: $post}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReactionsRouteArgs) return false;
    return key == other.key && post == other.post;
  }

  @override
  int get hashCode => key.hashCode ^ post.hashCode;
}

/// generated route for
/// [_i41.ResetPasswordScreen]
class ResetPasswordRoute extends _i46.PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    _i47.Key? key,
    required String email,
    List<_i46.PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return _i41.ResetPasswordScreen(key: args.key, email: args.email);
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({this.key, required this.email});

  final _i47.Key? key;

  final String email;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [_i42.SetUpVerificationScreen]
class SetUpVerificationRoute extends _i46.PageRouteInfo<void> {
  const SetUpVerificationRoute({List<_i46.PageRouteInfo>? children})
    : super(SetUpVerificationRoute.name, initialChildren: children);

  static const String name = 'SetUpVerificationRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return const _i42.SetUpVerificationScreen();
    },
  );
}

/// generated route for
/// [_i43.SignInScreen]
class SignInRoute extends _i46.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i47.Key? key,
    void Function(bool)? onResult,
    String? email,
    String? password,
    List<_i46.PageRouteInfo>? children,
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

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i46.WrappedRoute(
        child: _i43.SignInScreen(
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

  final _i47.Key? key;

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
/// [_i44.UserHouseScreen]
class UserHouseRoute extends _i46.PageRouteInfo<void> {
  const UserHouseRoute({List<_i46.PageRouteInfo>? children})
    : super(UserHouseRoute.name, initialChildren: children);

  static const String name = 'UserHouseRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i44.UserHouseScreen());
    },
  );
}

/// generated route for
/// [_i45.UserSettingsScreen]
class UserSettingsRoute extends _i46.PageRouteInfo<void> {
  const UserSettingsRoute({List<_i46.PageRouteInfo>? children})
    : super(UserSettingsRoute.name, initialChildren: children);

  static const String name = 'UserSettingsRoute';

  static _i46.PageInfo page = _i46.PageInfo(
    name,
    builder: (data) {
      return _i46.WrappedRoute(child: const _i45.UserSettingsScreen());
    },
  );
}
