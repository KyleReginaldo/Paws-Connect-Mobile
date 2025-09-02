import 'package:auto_route/auto_route.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';

import '../services/supabase_service.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Use the current auth state synchronously here. Attaching a listener
    // inside `onNavigation` can cause multiple events and lead to calling
    // `resolver.next()` more than once which triggers an assertion in
    // auto_route. Check the current user/session and decide once.
    final user = supabase.auth.currentUser;
    if (user != null) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(
        SignInRoute(
          onResult: (success) {
            if (success) {
              resolver.next(true);
            }
          },
        ),
      );
    }
  }
}
