import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SignInScreen extends StatefulWidget implements AutoRouteWrapper {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<AuthRepository>(),
      child: this,
    );
  }
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  void _handleSignIn() async {
    if (formKey.currentState?.validate() ?? false) {
      context.read<AuthRepository>().signIn(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.watch<AuthRepository>().errorMessage;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (errorMessage != null)
                  Text(errorMessage, style: TextStyle(color: Colors.red)),
                PawsTextField(
                  controller: email,
                  hint: 'juan@example.com',
                  validator: (value) => value != null && value.contains("@")
                      ? null
                      : "Enter a valid email",
                ),
                PawsTextField(
                  controller: password,
                  hint: '********',
                  obscureText: true,
                ),
                PawsElevatedButton(
                  label: 'Sign In',
                  onPressed: _handleSignIn,
                  backgroundColor: Colors.deepOrange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
