// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/paws_theme.dart';

@RoutePage()
class SignInScreen extends StatefulWidget implements AutoRouteWrapper {
  final void Function(bool success)? onResult;

  const SignInScreen({super.key, this.onResult});

  @override
  State<SignInScreen> createState() => _SignInScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<AuthRepository>(),
      child: this,
    );
  }
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  final phoneNumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final List<String> tabs = ['Sign In', 'Sign Up'];
  int selectedTab = 0;
  late final AnimationController _entranceController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool rememberMe = false;
  bool isLoading = false;
  void _handleSignIn() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        final result = await AuthProvider().signIn(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        if (result.isError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.error)));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sign in successful')));
          widget.onResult?.call(true);
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  void _handleSignUp() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        final result = await AuthProvider().signUp(
          email: email.text.trim(),
          password: password.text.trim(),
          username: username.text.trim(),
          phoneNumber: '+63${phoneNumber.text.trim()}',
        );

        if (result.isError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.error)));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.value)));
          _handleSignIn();
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    // start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    username.dispose();
    phoneNumber.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context
        .watch<AuthRepository>()
        .errorMessage; // observed for side-effects (e.g. rebuilds)
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: PawsColors.backgroundDark,
              child: Image.asset(
                'assets/images/onboarding_background.jpg',
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                opacity: const AlwaysStoppedAnimation(0.7),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: PawsText(
                      'Go ahead and set up your account',
                      color: PawsColors.textLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: PawsText(
                      'Log in to continue your journey in changing lives',
                      color: PawsColors.textLight,
                    ),
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Form(
                            key: formKey,
                            child: Column(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEFEFEF),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    children: List.generate(tabs.length, (
                                      index,
                                    ) {
                                      final isSelected = index == selectedTab;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(
                                            () => selectedTab = index,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            alignment: Alignment.center,
                                            child: PawsText(
                                              tabs[index],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? PawsColors.textPrimary
                                                    : PawsColors.textSecondary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  transitionBuilder: (child, animation) {
                                    return SizeTransition(
                                      sizeFactor: animation,
                                      axisAlignment: -1,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: selectedTab == 1
                                      ? Column(
                                          spacing: 10,

                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          key: const ValueKey('signup-fields'),
                                          children: [
                                            PawsText('Username'),
                                            PawsTextField(
                                              controller: username,
                                              hint: 'juan123',
                                              validator: (value) =>
                                                  value != null &&
                                                      value.isNotEmpty
                                                  ? null
                                                  : "Enter a valid username",
                                            ),
                                            PawsText('Phone Number'),
                                            PawsTextField(
                                              controller: phoneNumber,
                                              keyboardType: TextInputType.phone,
                                              prefixIcon: PawsTextButton(
                                                label: '+63',
                                                padding: EdgeInsets.zero,
                                                foregroundColor:
                                                    PawsColors.textSecondary,
                                              ),
                                              hint: '9*********',
                                              validator: (value) =>
                                                  value != null &&
                                                      value.isNotEmpty
                                                  ? null
                                                  : "Enter a valid phone number",
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(
                                          key: ValueKey('signin'),
                                        ),
                                ),
                                PawsText('Email'),
                                PawsTextField(
                                  controller: email,
                                  hint: 'juan@example.com',
                                  validator: (value) =>
                                      value != null && value.contains("@")
                                      ? null
                                      : "Enter a valid email",
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                PawsText('Password'),
                                PawsTextField(
                                  controller: password,
                                  hint: '********',
                                  obscureText: true,
                                ),
                                if (selectedTab == 0)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: rememberMe,
                                              onChanged: (value) =>
                                                  setState(() {
                                                    rememberMe = value ?? false;
                                                  }),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            PawsText('Remember me'),
                                          ],
                                        ),
                                      ),
                                      PawsTextButton(label: 'Forgot password?'),
                                    ],
                                  ),
                                PawsElevatedButton(
                                  label: selectedTab == 0
                                      ? 'Sign In'
                                      : 'Sign Up',
                                  backgroundColor: PawsColors.primary,
                                  borderRadius: 25,
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (selectedTab == 0) {
                                            _handleSignIn();
                                          } else {
                                            _handleSignUp();
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
