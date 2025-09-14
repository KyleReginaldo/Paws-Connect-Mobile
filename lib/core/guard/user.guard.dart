import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

import '../services/supabase_service.dart';

class UserGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    // Use the current auth state synchronously here. Attaching a listener
    // inside `onNavigation` can cause multiple events and lead to calling
    // `resolver.next()` more than once which triggers an assertion in
    // auto_route. Check the current user/session and decide once.
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      resolver.redirectUntil(
        SignInRoute(
          onResult: (success) {
            if (success) {
              resolver.next(true);
            }
          },
        ),
      );
      return;
    }
    final response = await supabase
        .from('users')
        .select()
        .eq('id', currentUserId)
        .single();
    final user = UserProfileMapper.fromMap(response);
    debugPrint('UserGuard: $user');
    if (user.createdBy != null &&
        (user.passwordChanged == false || user.passwordChanged == null)) {
      resolver.redirectUntil(
        ChangePasswordRoute(
          onResult: (success) {
            if (success) {
              resolver.next(true);
            }
          },
        ),
      );
      return;
    } else {
      resolver.next(true);
    }
    // if (response.data != null) {
    //   resolver.next(true);
    // } else {
    //   resolver.redirectUntil(
    //     SignInRoute(
    //       onResult: (success) {
    //         if (success) {
    //           resolver.next(true);
    //         }
    //       },
    //     ),
    //   );
    // }
  }
}
