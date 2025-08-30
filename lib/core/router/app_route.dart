import 'package:auto_route/auto_route.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthRoute.page, initial: true),
    CustomRoute(
      page: SignInRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: MainRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      children: [
        CustomRoute(
          page: HomeRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: NotfoundRoute.page,
          path: '*',
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
      ],
    ),
  ];
}
