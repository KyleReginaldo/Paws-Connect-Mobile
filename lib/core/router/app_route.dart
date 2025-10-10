import 'package:auto_route/auto_route.dart';
import 'package:paws_connect/core/guard/auth.guard.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // AutoRoute(page: AuthRoute.page, initial: true),
    CustomRoute(
      page: SignInRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: MainRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      path: '/',
      initial: true,
      children: [
        CustomRoute(
          page: HomeRoute.page,
          path: 'home',
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          path: 'fundraising',
          page: FundraisingRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          path: 'pet',
          page: PetRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          path: 'forum',
          page: ForumRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
      ],
    ),
    CustomRoute(
      page: FavoriteRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: MapRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      guards: [AuthGuard()],
    ),
    CustomRoute(
      page: PetDetailRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: FundraisingDetailRoute.page,
      path: '/fundraising/:id',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: PaymentRoute.page,
      path: '/payment',
      transitionsBuilder: TransitionsBuilders.fadeIn,
      guards: [AuthGuard()],
    ),
    CustomRoute(
      page: PaymentMethodRoute.page,
      path: '/payment-method',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: PaymentSuccessRoute.page,
      path: '/payment-success/:id',
      transitionsBuilder: TransitionsBuilders.slideBottom,
    ),
    CustomRoute(
      page: ForumChatRoute.page,
      path: '/forum-chat/:forumId',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: AddForumRoute.page,
      path: '/add-forum',
      transitionsBuilder: TransitionsBuilders.fadeIn,
      guards: [AuthGuard()],
    ),
    CustomRoute(
      page: ProfileRoute.page,
      path: '/profile',
      guards: [AuthGuard()],

      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: EditProfileRoute.page,
      path: '/edit-profile',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: ForumSettingsRoute.page,
      path: '/forum-settings/:forumId',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: AddForumMemberRoute.page,
      path: '/add-forum-member/:forumId',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: ChangePasswordRoute.page,
      path: '/change-password',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: CreateAdoptionRoute.page,
      path: '/create-adoption/:petId',
      transitionsBuilder: TransitionsBuilders.slideBottom,
      guards: [AuthGuard()],
    ),
    CustomRoute(
      page: AdoptionHistoryRoute.page,
      path: '/adoption-history',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: DonationHistoryRoute.page,
      path: '/donation-history',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: NotificationRoute.page,
      path: '/notification',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: NotificationDetailRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: SetUpVerificationRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: AdoptionDetailRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: AdoptionSuccessRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: UserHouseRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: EventDetailRoute.page,
      path: '/event-detail/:id',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
  ];
}
