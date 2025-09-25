// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/result.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/theme/paws_theme.dart';

@RoutePage()
class SignInScreen extends StatefulWidget implements AutoRouteWrapper {
  final void Function(bool success)? onResult;
  final String? email;
  final String? password;

  const SignInScreen({super.key, this.onResult, this.email, this.password});

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
  bool agreedToTerms = false;
  void _handleSignIn({String? initEmail, String? initPassword}) async {
    if (!mounted) return;
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        final result = await AuthProvider().signIn(
          email: initEmail ?? email.text,
          password: initPassword ?? password.text,
        );

        if (result.isError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.error)));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sign in successful')));
          // Preload user data after successful sign in
          await SessionManager.bootstrapAfterSignIn(eager: false);
          widget.onResult?.call(true);
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  void _handleSignUp() async {
    if (!mounted) return;
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
          // Try automatic sign in after successful registration
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Signing you in...')),
          );

          Result<String>? lastError;
          for (var attempt = 0; attempt < 3; attempt++) {
            // Small backoff to allow backend propagation
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
            final signInResult = await AuthProvider().signIn(
              email: email.text.trim(),
              password: password.text.trim(),
            );
            if (!signInResult.isError) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome! You are now signed in.'),
                ),
              );
              await SessionManager.bootstrapAfterSignIn(eager: false);
              widget.onResult?.call(true);
              return;
            }
            lastError = signInResult;
          }

          if (!mounted) return;
          // If automatic sign-in failed after retries, fall back to manual login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created, but automatic sign-in failed. Please sign in manually.\nReason: ${lastError?.error ?? 'Unknown error'}',
              ),
            ),
          );
          setState(() => selectedTab = 0);
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  void initCredentials() {
    Future.delayed(Duration(seconds: 2), () {
      print(
        'initCredentials called - widget.email: ${widget.email}, widget.password: ${widget.password}',
      );
      print('Email is null: ${widget.email == null}');
      print('Password is null: ${widget.password == null}');

      if (mounted) {
        setState(() {
          email.text = widget.email ?? '';
          password.text = widget.password ?? '';
        });
        print(
          'Form fields updated - email.text: "${email.text}", password.text: "${password.text}"',
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    print(
      'initState called - widget.email: ${widget.email}, widget.password: ${widget.password}',
    );

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

    // Initialize credentials immediately
    initCredentials();

    // Start animation after credentials are set
    _entranceController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(
      'didChangeDependencies called - widget.email: ${widget.email}, widget.password: ${widget.password}',
    );

    // Try initializing credentials again in case they weren't available in initState
    if ((widget.email != null || widget.password != null) &&
        (email.text.isEmpty || password.text.isEmpty)) {
      print('Re-initializing credentials in didChangeDependencies');
      initCredentials();
    }
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
                                if (selectedTab == 1)
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: agreedToTerms,
                                        onChanged: (value) => setState(() {
                                          agreedToTerms = value ?? false;
                                        }),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'I agree to the ',
                                          style: TextStyle(
                                            color: PawsColors.textSecondary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Terms and Conditions',
                                              style: TextStyle(
                                                color: PawsColors.primary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  launchUrl(
                                                    Uri.parse(
                                                      'https://paws-connect-sable.vercel.app/terms-and-condition',
                                                    ),
                                                  );
                                                  // Add your navigation or action here
                                                  // Example: context.router.push(TermsRoute());
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                PawsElevatedButton(
                                  label: selectedTab == 0
                                      ? 'Sign In'
                                      : 'Sign Up',
                                  backgroundColor:
                                      (selectedTab == 1 && !agreedToTerms)
                                      ? PawsColors.disabled
                                      : PawsColors.primary,
                                  borderRadius: 25,
                                  onPressed:
                                      (isLoading) ||
                                          (selectedTab == 1 && !agreedToTerms)
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
