import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/onboarding_background.jpg',
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        fit: BoxFit.cover,
      ),
    );
  }
}
