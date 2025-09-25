// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/supabase/client.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';

// Global flag to ensure OneSignal listener is only added once
bool _oneSignalListenerInitialized = false;

// Debouncing to prevent rapid-fire navigation
DateTime? _lastNavigationTime;
String? _lastNavigatedRoute;

@RoutePage()
class MainScreen extends StatefulWidget {
  final int? initialIndex;
  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _hasSetInitialIndex = false;

  @override
  void initState() {
    handleOneSignalLogin();
    // Only initialize OneSignal listener once globally
    if (!_oneSignalListenerInitialized) {
      initPlatformState();
      _oneSignalListenerInitialized = true;
    }
    super.initState();
  }

  void handleOneSignalLogin() async {
    await OneSignal.login(USER_ID ?? '');
  }

  Future<void> initPlatformState() async {
    OneSignal.Notifications.addClickListener((event) {
      try {
        final json = event.notification.jsonRepresentation();
        debugPrint('🔔 Notification clicked: $json');

        // Simple route extraction
        String? route;
        try {
          final data = jsonDecode(json) as Map<String, dynamic>;
          final custom = data['custom'];

          if (custom is String) {
            final customData = jsonDecode(custom) as Map<String, dynamic>;
            route = customData['a']?['route'];
          } else if (custom is Map<String, dynamic>) {
            route = custom['a']?['route'];
          }
        } catch (e) {
          // Fallback: extract route using regex
          final routeMatch = RegExp(r'"route":"([^"]*)"').firstMatch(json);
          route = routeMatch?.group(1);
        }

        // Simple navigation - just navigate to the route once
        if (route != null) {
          debugPrint('📱 Navigating to: $route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check if widget is still mounted before navigation
            if (mounted) {
              _navigateToRoute(route!);
            } else {
              debugPrint('🚫 Widget unmounted, skipping navigation to $route');
            }
          });
        }
      } catch (e) {
        debugPrint('❌ Error handling notification: $e');
      }
    });
  }

  void _navigateToRoute(String route) {
    // Additional mounted check before any navigation operations
    if (!mounted) {
      debugPrint('🚫 Widget unmounted, cannot navigate to $route');
      return;
    }

    final now = DateTime.now();

    // Debouncing: Prevent navigation if same route was navigated within last 2 seconds
    if (_lastNavigationTime != null &&
        _lastNavigatedRoute == route &&
        now.difference(_lastNavigationTime!).inSeconds < 2) {
      debugPrint('🚫 Ignoring duplicate navigation to $route');
      return;
    }

    _lastNavigationTime = now;
    _lastNavigatedRoute = route;

    final segments = route.split('/');

    // Handle forum-chat routes: /forum-chat/123
    if (route.contains('forum-chat') && segments.length > 2) {
      final forumId = int.tryParse(segments[2]);
      if (forumId != null && mounted) {
        debugPrint('📱 Navigating to forum chat: $forumId');
        // Use navigate instead of push to replace current navigation
        context.router.navigate(ForumChatRoute(forumId: forumId));
        return;
      }
    }

    // Handle fundraising routes: /fundraising/123
    if (route.contains('fundraising') && segments.length > 2) {
      final fundraisingId = int.tryParse(segments[2]);
      if (fundraisingId != null && mounted) {
        debugPrint('📱 Navigating to fundraising detail: $fundraisingId');
        // Use navigate instead of push to replace current navigation
        context.router.navigate(FundraisingDetailRoute(id: fundraisingId));
        return;
      }
    }

    // Fallback
    if (mounted) {
      debugPrint('📱 Fallback navigation to: $route');
      context.router.pushPath(route);
    } else {
      debugPrint('🚫 Widget unmounted, skipping fallback navigation to $route');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = context.watch<AuthRepository>().user;
    return AutoTabsScaffold(
      homeIndex: 4,

      routes: [
        HomeRoute(),
        FundraisingRoute(),
        PetRoute(),
        FavoriteRoute(),
        ForumRoute(),
      ],

      bottomNavigationBuilder: (_, tabsRouter) {
        // Set initial index only once when the widget is first built
        if (widget.initialIndex != null && !_hasSetInitialIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.initialIndex != tabsRouter.activeIndex) {
              tabsRouter.setActiveIndex(widget.initialIndex!);
            }
          });
          _hasSetInitialIndex = true;
        }

        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          selectedItemColor: PawsColors.primary,
          unselectedItemColor: PawsColors.disabled,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          onTap: tabsRouter.setActiveIndex,

          items: const [
            BottomNavigationBarItem(label: '', icon: Icon(LucideIcons.house)),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.heartHandshake),
            ),
            BottomNavigationBarItem(label: '', icon: Icon(LucideIcons.dog)),
            BottomNavigationBarItem(label: '', icon: Icon(LucideIcons.heart)),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.messageCircle),
            ),
          ],
        );
      },
    );
  }
}
