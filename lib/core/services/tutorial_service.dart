import 'package:flutter/material.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  static TutorialCoachMark? _tutorialCoachMark;
  static final List<TargetFocus> _targets = [];
  static bool _shouldShowTutorialForNewUser = false;

  static void startTutorial(
    BuildContext context, {
    required Map<String, GlobalKey> targetKeys,
    required VoidCallback onComplete,
    required VoidCallback onSkip,
  }) {
    _createTutorialTargets(context, targetKeys);
    // If there are no valid targets, do not attempt to show or mark onboarded
    if (_targets.isEmpty) {
      debugPrint(
        '[TutorialService] No valid tutorial targets found; skipping.',
      );
      return;
    }
    _showTutorial(context, onComplete: onComplete, onSkip: onSkip);
  }

  static void _createTutorialTargets(
    BuildContext context,
    Map<String, GlobalKey> targetKeys,
  ) {
    _targets.clear();

    bool isMounted(GlobalKey? k) =>
        k?.currentContext?.findRenderObject() != null;

    // Bottom navigation targets
    if (isMounted(targetKeys['home_tab'])) {
      _targets.add(
        TargetFocus(
          identify: 'home_tab',
          keyTarget: targetKeys['home_tab']!,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => _buildContent(
                title: 'Home Dashboard',
                description:
                    "Your main hub for everything! Here you'll find recently added pets, active fundraising campaigns, your adoption applications, and quick access to search. This is where you start your pet adoption journey.",
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    if (isMounted(targetKeys['fundraising_tab'])) {
      _targets.add(
        TargetFocus(
          identify: 'fundraising_tab',
          keyTarget: targetKeys['fundraising_tab']!,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => _buildContent(
                title: 'Fundraising Tab',
                description:
                    'Browse and support fundraising campaigns for pets in need. Help animals get medical care and find homes.',
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    if (isMounted(targetKeys['feed_tab'])) {
      _targets.add(
        TargetFocus(
          identify: 'feed_tab',
          keyTarget: targetKeys['feed_tab']!,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => _buildContent(
                title: 'Community Feed',
                description:
                    'Share and discover posts from the PawsConnect community! Post photos and stories of your pets, adoption journeys, tips and advice, or ask for help. Connect with other pet lovers and stay updated on community activities.',
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    if (isMounted(targetKeys['pets_tab'])) {
      _targets.add(
        TargetFocus(
          identify: 'pets_tab',
          keyTarget: targetKeys['pets_tab']!,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => _buildContent(
                title: 'Browse All Pets',
                description:
                    'Tap here to see ALL available pets for adoption! Use advanced filters to search by type (dogs, cats, etc.), age, size, location, and special needs. Find your perfect furry companion by browsing detailed profiles with photos and descriptions.',
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    if (isMounted(targetKeys['forum_tab'])) {
      _targets.add(
        TargetFocus(
          identify: 'forum_tab',
          keyTarget: targetKeys['forum_tab']!,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => _buildContent(
                title: 'Forum Tab',
                description:
                    'Connect with other pet lovers! Join discussions, ask questions, and share your pet experiences with the community.',
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    // App bar targets
    if (isMounted(targetKeys['location_button'])) {
      _targets.add(
        TargetFocus(
          identify: 'location_button',
          keyTarget: targetKeys['location_button']!,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => _buildContent(
                title: 'Add Your Address',
                description:
                    'Tap here to add and manage your addresses. Set your default location to see pets and services near you. You can add multiple addresses and switch between them easily.',
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    if (isMounted(targetKeys['notifications_button'])) {
      _targets.add(
        TargetFocus(
          identify: 'notifications_button',
          keyTarget: targetKeys['notifications_button']!,
          alignSkip: Alignment.topLeft,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => _buildContent(
                title: 'View Notifications',
                description:
                    'Tap the bell icon to see all your notifications. Get updates about adoption applications, forum replies, fundraising progress, and important app news. The red badge shows unread notifications.',
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }

    if (isMounted(targetKeys['profile_button'])) {
      _targets.add(
        TargetFocus(
          identify: 'profile_button',
          keyTarget: targetKeys['profile_button']!,
          alignSkip: Alignment.topLeft,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => _buildContent(
                title: 'Access Your Profile',
                description:
                    "Tap your profile picture (or 'Sign In' if not logged in) to access your profile, view adoption history, donation records, change settings, and manage your account. Keep your profile updated to improve adoption chances!",
                controller: controller,
              ),
            ),
          ],
        ),
      );
    }
  }

  static Widget _buildContent({
    required String title,
    required String description,
    required TutorialCoachMarkController controller,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: PawsColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.skip(),
                child: const Text(
                  'Skip Tutorial',
                  style: TextStyle(
                    color: PawsColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    controller.skip();
                  } else {
                    controller.next();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawsColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isLast ? 'Get Started!' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showTutorial(
    BuildContext context, {
    required VoidCallback onComplete,
    required VoidCallback onSkip,
  }) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      colorShadow: PawsColors.textPrimary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      imageFilter: ColorFilter.mode(
        PawsColors.primary.withValues(alpha: 0.6),
        BlendMode.srcATop,
      ),
      onFinish: () {
        _markUserAsOnboarded();
        // Show a lightweight congrats animation after the tutorial completes
        _showCongratsAnimation(context);
        onComplete();
      },
      onSkip: () {
        _markUserAsOnboarded();
        onSkip();
        return true;
      },
      onClickTarget: (target) {
        print('Clicked on target: ${target.identify}');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print(
          'Clicked target: ${target.identify} at position: ${tapDetails.globalPosition}',
        );
      },
    );

    _tutorialCoachMark?.show(context: context);
  }

  static void _showCongratsAnimation(BuildContext context) {
    if (!context.mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Congratulations',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, secondary, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: curved, child: _congratsDialog()),
        );
      },
    );
  }

  // Simple animated congrats card (no external assets required)
  static const _confettiColors = [
    Color(0xFFFF6B6B),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFFD93D),
  ];

  static Widget _confettiDot(int i) {
    final color = _confettiColors[i % _confettiColors.length];
    return Positioned(
      top: 12.0 + (i * 6) % 40,
      left: 16.0 + (i * 11) % 160,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  static Widget _animatedCheck() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: PawsColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: PawsColors.primary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
      ),
    );
  }

  static Widget _animatedText(String text) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 8),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: PawsColors.textSecondary),
      ),
    );
  }

  static Widget _animatedTitle(String text) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PawsColors.textPrimary,
        ),
      ),
    );
  }

  static Widget _actionButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).maybePop(),
      child: const Text('Awesome!'),
    );
  }

  static Widget _congratsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 88,
            width: double.infinity,
            child: Stack(
              children: [
                for (var i = 0; i < 18; i++) _confettiDot(i),
                Center(child: _animatedCheck()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _animatedTitle('You’re all set! 🎉'),
          const SizedBox(height: 6),
          _animatedText('Thanks for completing the tour. Enjoy exploring!'),
          const SizedBox(height: 8),
          _actionButton(context),
        ],
      ),
    );
  }

  static Widget _dialogScaffold(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(child: _congratsCard(context)),
    );
  }

  // Stateless wrapper so transitionBuilder can render a widget tree
  static Widget _congratsDialog() =>
      Builder(builder: (context) => _dialogScaffold(context));

  static Future<void> _markUserAsOnboarded() async {
    try {
      final userId = USER_ID;
      if (userId != null && userId.isNotEmpty) {
        await supabase
            .from('users')
            .update({'onboarded': true})
            .eq('id', userId);
      }
    } catch (e) {
      print('Error marking user as onboarded: $e');
    }
  }

  static void dispose() {
    _tutorialCoachMark = null;
    _targets.clear();
  }

  static Future<bool> shouldShowTutorial() async {
    try {
      final userId = USER_ID;
      if (userId == null || userId.isEmpty) return false;

      final response = await supabase
          .from('users')
          .select('onboarded')
          .eq('id', userId)
          .single();

      final onboarded = response['onboarded'] as bool? ?? false;
      return !onboarded;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  static Future<void> showTutorialForNewUser(
    BuildContext context, {
    required Map<String, GlobalKey> targetKeys,
    required VoidCallback onComplete,
    required VoidCallback onSkip,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      startTutorial(
        context,
        targetKeys: targetKeys,
        onComplete: onComplete,
        onSkip: onSkip,
      );
    }
  }

  static Future<bool> isNewlyRegisteredUser() async {
    try {
      final userId = USER_ID;
      if (userId == null || userId.isEmpty) return false;

      final response = await supabase
          .from('users')
          .select('onboarded, created_at')
          .eq('id', userId)
          .single();

      final onboarded = response['onboarded'] as bool? ?? false;
      final createdAt = DateTime.parse(response['created_at'] as String);
      final now = DateTime.now();

      final isNewUser = now.difference(createdAt).inMinutes < 5 && !onboarded;
      return isNewUser;
    } catch (e) {
      print('Error checking if user is newly registered: $e');
      return false;
    }
  }

  static Future<void> resetOnboardingStatus() async {
    try {
      final userId = USER_ID;
      if (userId != null && userId.isNotEmpty) {
        await supabase
            .from('users')
            .update({'onboarded': false})
            .eq('id', userId);
        print('User onboarding status reset successfully');
      }
    } catch (e) {
      print('Error resetting onboarding status: $e');
    }
  }

  static void markNewUserForTutorial() {
    print('🎯 TUTORIAL SERVICE: markNewUserForTutorial called');
    _shouldShowTutorialForNewUser = true;
    print(
      '🎯 TUTORIAL SERVICE: _shouldShowTutorialForNewUser set to: $_shouldShowTutorialForNewUser',
    );
  }

  static bool shouldShowTutorialForNewUser() {
    print(
      '🎯 TUTORIAL SERVICE: shouldShowTutorialForNewUser called, returning: $_shouldShowTutorialForNewUser',
    );
    return _shouldShowTutorialForNewUser;
  }

  static void clearNewUserTutorialFlag() {
    print('🎯 TUTORIAL SERVICE: clearNewUserTutorialFlag called');
    _shouldShowTutorialForNewUser = false;
    print(
      '🎯 TUTORIAL SERVICE: _shouldShowTutorialForNewUser set to: $_shouldShowTutorialForNewUser',
    );
  }
}
