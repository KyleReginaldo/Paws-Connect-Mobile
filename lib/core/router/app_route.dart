import 'package:auto_route/auto_route.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthRoute.page, initial: true),
    AutoRoute(page: SignInRoute.page),
  ];
}
