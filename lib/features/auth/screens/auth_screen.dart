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
import 'package:paws_connect/features/main/screens/extension/terms_and_condition.dart'
    show TermsContent;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/result.dart';
import '../../../core/router/app_route.gr.dart';
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
  // Controllers
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  final phoneNumber = TextEditingController();

  // UI / State
  late final AnimationController _entranceController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool isLoading = false;
  bool rememberMe = false;
  bool agreedToTerms = false;
  bool _viewedTermsAndScrolled =
      false; // must view dialog & scroll to bottom before agreeing
  bool _didSignalResult = false;

  int selectedTab = 0;
  final List<String> tabs = const ['Sign In', 'Sign Up'];

  // Password rules state
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

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

    // Add password validation listener
    password.addListener(() {
      _validatePassword(password.text);
    });

    // Initialize credentials from widget
    initCredentials();

    _entranceController.forward();
  }

  Future<bool> _showTermsDialog() async {
    final controller = ScrollController();
    bool scrolledToBottom = false;
    bool accepted = false;

    if (!mounted) return false;
    await showDialog<void>(
      context: context,

      barrierDismissible: false,
      builder: (ctx) {
        // use StatefulBuilder to reflect scroll state in the dialog UI
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: PawsColors.border),
                        ),
                      ),
                      child: const Text(
                        'Terms & Conditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PawsColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        controller: controller,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final m = notification.metrics;
                            final canScroll = m.maxScrollExtent > 0;
                            final atBottom =
                                m.pixels >= (m.maxScrollExtent - 8);
                            final next = canScroll
                                ? atBottom
                                : true; // if content fits, treat as read
                            if (next != scrolledToBottom) {
                              setState(() => scrolledToBottom = next);
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: controller,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: const TermsContent(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                accepted = false;
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: scrolledToBottom
                                  ? () {
                                      accepted = true;
                                      Navigator.of(ctx).pop();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scrolledToBottom
                                    ? PawsColors.primary
                                    : PawsColors.disabled,
                              ),
                              child: Text(
                                scrolledToBottom
                                    ? 'I Agree'
                                    : 'Scroll to the end',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    return accepted;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retry initializing if they weren't ready in initState
    if ((widget.email != null || widget.password != null) &&
        (email.text.isEmpty || password.text.isEmpty)) {
      initCredentials();
    }
  }

  void initCredentials() {
    // Delay slightly to allow route args to propagate
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        email.text = widget.email ?? '';
        password.text = widget.password ?? '';
      });
      _loadRememberedCredentials();
    });

    // Load remembered credentials
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberedEmail = prefs.getString('remembered_email') ?? '';
      final rememberedPassword = prefs.getString('remembered_password') ?? '';
      final shouldRemember = prefs.getBool('remember_me') ?? false;
      debugPrint('email: $rememberedEmail, rememberMe: $shouldRemember');
      if (shouldRemember && rememberedEmail.isNotEmpty) {
        if (mounted) {
          setState(() {
            email.text = rememberedEmail.trim();
            password.text = rememberedPassword.trim();
            rememberMe = shouldRemember;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading remembered credentials: $e');
    }
  }

  Future<void> _saveRememberedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('remembered_email', email.text.trim());
        await prefs.setString('remembered_password', password.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('remembered_email');
        await prefs.remove('remembered_password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      debugPrint('Error saving remembered credentials: $e');
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

  String? _validatePasswordField(String? value) {
    if (selectedTab == 0) {
      // Sign-in: basic non-empty check
      if (value == null || value.isEmpty) return 'Enter your password';
      return null;
    }
    // Sign-up: enforce rules (compute without setState during build)
    final v = value ?? '';
    final okMin = v.length >= 8;
    final okUpper = RegExp(r'[A-Z]').hasMatch(v);
    final okLower = RegExp(r'[a-z]').hasMatch(v);
    final okNum = RegExp(r'[0-9]').hasMatch(v);
    final okSpec = RegExp(r'[!@#\$%^&*]').hasMatch(v);
    if (!(okMin && okUpper && okLower && okNum && okSpec)) {
      return 'Password does not meet all requirements';
    }
    return null;
  }

  void _validatePassword(String value) {
    final min = value.length >= 8;
    final upper = RegExp(r'[A-Z]').hasMatch(value);
    final lower = RegExp(r'[a-z]').hasMatch(value);
    final number = RegExp(r'[0-9]').hasMatch(value);
    final special = RegExp(r'[!@#\$%^&*]').hasMatch(value);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        hasMinLength = min;
        hasUpperCase = upper;
        hasLowerCase = lower;
        hasNumber = number;
        hasSpecialChar = special;
      });
    });
  }

  Widget _buildPasswordRequirement(String text, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: ok ? Colors.green : Colors.redAccent,
        ),
        const SizedBox(width: 8),
        PawsText(
          text,
          color: ok ? PawsColors.textSecondary : Colors.redAccent,
          fontSize: 13,
        ),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    if (formKey.currentState?.validate() != true) return;
    setState(() => isLoading = true);
    try {
      final result = await AuthProvider().signIn(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (result.isError && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error)));
        return;
      }

      // Save remembered credentials if sign in is successful
      await _saveRememberedCredentials();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign in successful')));
      }

      await SessionManager.bootstrapAfterSignIn(eager: false);
      if (!_didSignalResult) {
        _didSignalResult = true;
        widget.onResult?.call(true);
      }
      if (mounted) {
        context.router.maybePop(true);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (!mounted) return;
    if (formKey.currentState?.validate() != true) return;
    setState(() => isLoading = true);
    try {
      final result = await AuthProvider().signUp(
        email: email.text.trim(),
        password: password.text.trim(),
        username: username.text.trim(),
        phoneNumber: '+63${phoneNumber.text.trim()}',
      );

      if (result.isError && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error)));
        return;
      }

      // Account created, attempt automatic sign-in
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Signing you in...')),
        );
      }

      // TutorialService removed; proceed with normal sign-in attempts

      Result<String>? lastError;
      for (var attempt = 0; attempt < 3; attempt++) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        final signInResult = await AuthProvider().signIn(
          email: email.text.trim(),
          password: password.text.trim(),
        );
        if (!signInResult.isError) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Welcome! You are now signed in. Let\'s show you around!',
              ),
            ),
          );
          await SessionManager.bootstrapAfterSignIn(eager: false);
          if (!_didSignalResult) {
            _didSignalResult = true;
            widget.onResult?.call(true);
          }
          if (mounted) {
            debugPrint('🎯 AUTH: Navigating to MainRoute');
            context.router.replaceAll([MainRoute()]);
          }
          return;
        }
        lastError = signInResult;
      }

      if (!mounted) return;
      // Fallback: navigate to root anyway
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created, but automatic sign-in failed. Please sign in manually.\nReason: ${lastError?.error ?? 'Unknown error'}',
          ),
        ),
      );
      debugPrint('🎯 AUTH: Auto sign-in failed; navigating to MainRoute');
      context.router.replaceAll([MainRoute()]);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: formKey,
                            child: Column(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEFEF),
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
                                  transitionBuilder: (child, animation) =>
                                      SizeTransition(
                                        sizeFactor: animation,
                                        axisAlignment: -1,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
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
                                              hint: 'Enter your username',
                                              validator: (value) =>
                                                  value != null &&
                                                      value.isNotEmpty
                                                  ? null
                                                  : 'Enter a valid username',
                                            ),
                                            PawsText('Phone Number'),
                                            PawsTextField(
                                              controller: phoneNumber,
                                              keyboardType: TextInputType.phone,
                                              prefixIcon: const PawsTextButton(
                                                label: '+63',
                                                padding: EdgeInsets.zero,
                                                foregroundColor:
                                                    PawsColors.textSecondary,
                                              ),
                                              hint: '9923189664',
                                              validator: (value) =>
                                                  value != null &&
                                                      value.isNotEmpty
                                                  ? null
                                                  : 'Enter a valid phone number',
                                              maxLength: 10,
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
                                  hint: 'Enter your email',
                                  validator: (value) =>
                                      value != null && value.contains('@')
                                      ? null
                                      : 'Enter a valid email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                PawsText('Password'),
                                PawsTextField(
                                  controller: password,
                                  hint: selectedTab == 1
                                      ? 'Create your password'
                                      : 'Enter your password',
                                  obscureText: true,
                                  validator: _validatePasswordField,
                                ),
                                if (selectedTab == 1 &&
                                    password.text.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: PawsColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PawsText(
                                          'Password Requirements:',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: PawsColors.textPrimary,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildPasswordRequirement(
                                          'At least 8 characters',
                                          hasMinLength,
                                        ),
                                        const SizedBox(height: 4),
                                        _buildPasswordRequirement(
                                          'One uppercase letter (A-Z)',
                                          hasUpperCase,
                                        ),
                                        const SizedBox(height: 4),
                                        _buildPasswordRequirement(
                                          'One lowercase letter (a-z)',
                                          hasLowerCase,
                                        ),
                                        const SizedBox(height: 4),
                                        _buildPasswordRequirement(
                                          'One number (0-9)',
                                          hasNumber,
                                        ),
                                        const SizedBox(height: 4),
                                        _buildPasswordRequirement(
                                          'One special character (!@#\$%^&*)',
                                          hasSpecialChar,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (selectedTab == 0)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: rememberMe,
                                              onChanged: (value) => setState(
                                                () =>
                                                    rememberMe = value ?? false,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            const PawsText('Remember me'),
                                          ],
                                        ),
                                      ),
                                      PawsTextButton(
                                        label: 'Forgot password?',
                                        onPressed: () {
                                          context.router.push(
                                            ForgotPasswordRoute(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                if (selectedTab == 1)
                                  Row(
                                    children: [
                                      Checkbox(
                                        value:
                                            agreedToTerms &&
                                            _viewedTermsAndScrolled,
                                        onChanged: (value) async {
                                          // Always show dialog before accepting
                                          final accepted =
                                              await _showTermsDialog();
                                          if (!mounted) return;
                                          setState(() {
                                            _viewedTermsAndScrolled = accepted;
                                            agreedToTerms = accepted;
                                          });
                                        },
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'I agree to the ',
                                          style: const TextStyle(
                                            color: PawsColors.textSecondary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Terms and Conditions',
                                              style: const TextStyle(
                                                color: PawsColors.primary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  final accepted =
                                                      await _showTermsDialog();
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _viewedTermsAndScrolled =
                                                        accepted;
                                                    agreedToTerms = accepted;
                                                  });
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
                                      (selectedTab == 1 &&
                                          (!agreedToTerms ||
                                              !_viewedTermsAndScrolled))
                                      ? PawsColors.disabled
                                      : PawsColors.primary,
                                  borderRadius: 25,
                                  onPressed:
                                      isLoading ||
                                          (selectedTab == 1 &&
                                              (!agreedToTerms ||
                                                  !_viewedTermsAndScrolled))
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
