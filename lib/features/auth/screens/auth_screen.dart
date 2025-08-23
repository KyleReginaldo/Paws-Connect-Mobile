import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:paws_connect/features/auth/screens/signin_screen.dart';
import 'package:provider/provider.dart';

@RoutePage()
class AuthScreen extends StatelessWidget implements AutoRouteWrapper {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, authRepository, child) {
        if (authRepository.user != null) {
          return Container(color: Colors.green);
        }
        if (authRepository.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authRepository.errorMessage!)),
            );
          });
        }
        return const SignInScreen();
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
