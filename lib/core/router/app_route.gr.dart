// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:paws_connect/features/auth/screens/auth_screen.dart' as _i1;
import 'package:paws_connect/features/auth/screens/onboarding_screen.dart'
    as _i5;
import 'package:paws_connect/features/auth/screens/signin_screen.dart' as _i6;
import 'package:paws_connect/features/main/screens/home_screen.dart' as _i2;
import 'package:paws_connect/features/main/screens/main_screen.dart' as _i3;
import 'package:paws_connect/features/main/screens/notfound_screen.dart' as _i4;

/// generated route for
/// [_i1.AuthScreen]
class AuthRoute extends _i7.PageRouteInfo<void> {
  const AuthRoute({List<_i7.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return _i7.WrappedRoute(child: const _i1.AuthScreen());
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.MainScreen]
class MainRoute extends _i7.PageRouteInfo<void> {
  const MainRoute({List<_i7.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.MainScreen();
    },
  );
}

/// generated route for
/// [_i4.NotfoundScreen]
class NotfoundRoute extends _i7.PageRouteInfo<void> {
  const NotfoundRoute({List<_i7.PageRouteInfo>? children})
    : super(NotfoundRoute.name, initialChildren: children);

  static const String name = 'NotfoundRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.NotfoundScreen();
    },
  );
}

/// generated route for
/// [_i5.OnboardingScreen]
class OnboardingRoute extends _i7.PageRouteInfo<void> {
  const OnboardingRoute({List<_i7.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i5.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i6.SignInScreen]
class SignInRoute extends _i7.PageRouteInfo<void> {
  const SignInRoute({List<_i7.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return _i7.WrappedRoute(child: const _i6.SignInScreen());
    },
  );
}
