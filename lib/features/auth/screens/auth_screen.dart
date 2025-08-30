import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_route.gr.dart';

@RoutePage()
class AuthScreen extends StatelessWidget implements AutoRouteWrapper {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, provider, child) {
        if (provider.user == null) {
          context.router.replace(const SignInRoute());
        } else {
          context.router.replace(const MainRoute());
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        );
      },
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<AuthRepository>()..init(),
      child: this,
    );
  }
}
