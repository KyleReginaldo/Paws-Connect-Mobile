import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/repository/common_repository.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';

bool _oneSignalListenerInitialized = false;

DateTime? _lastNavigationTime;
String? _lastNavigatedRoute;

@RoutePage()
class MainScreen extends StatefulWidget implements AutoRouteWrapper {
  final int? initialIndex;
  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<CommonRepository>(),
      child: this,
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  bool _hasSetInitialIndex = false;
  RealtimeChannel? _forumChatsChannel;
  RealtimeChannel? _notificationsChannel;

  DateTime _lastRealtimeRefresh = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    handleOneSignalLogin();
    if (!_oneSignalListenerInitialized) {
      initPlatformState();
      _oneSignalListenerInitialized = true;
    }
    _initForumChatsRealtime();
    _initNotificationsRealtime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = USER_ID;
      if (userId != null && userId.isNotEmpty) {
        sl<CommonRepository>().getMessageCount(userId);
        sl<CommonRepository>().getNotificationCount(userId);
      }
    });
    super.initState();
  }

  void _initForumChatsRealtime() {
    _forumChatsChannel = supabase.channel('public:forum_chats_all');
    _forumChatsChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'forum_chats',
          callback: (_) {
            if (!mounted) return;
            final userId = USER_ID;
            if (userId == null || userId.isEmpty) return;
            final now = DateTime.now();

            if (now.difference(_lastRealtimeRefresh).inMilliseconds < 300) {
              return;
            }
            _lastRealtimeRefresh = now;
            sl<CommonRepository>().getMessageCount(userId);
          },
        )
        .subscribe();
  }

  void _initNotificationsRealtime() {
    _notificationsChannel = supabase.channel(
      'public:notifications:user=eq.$USER_ID',
    );
    _notificationsChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user',
            value: USER_ID ?? "",
          ),
          callback: (_) {
            if (!mounted) return;
            final userId = USER_ID;
            if (userId == null || userId.isEmpty) return;
            final now = DateTime.now();

            if (now.difference(_lastRealtimeRefresh).inMilliseconds < 300) {
              return;
            }
            _lastRealtimeRefresh = now;
            sl<CommonRepository>().getNotificationCount(userId);
          },
        )
        .subscribe();
  }

  void handleOneSignalLogin() async {
    final id = USER_ID;
    if (id != null && id.isNotEmpty) {
      await OneSignal.login(id);
    }
  }

  Future<void> initPlatformState() async {
    OneSignal.Notifications.addClickListener((event) {
      try {
        final json = event.notification.jsonRepresentation();
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
          final routeMatch = RegExp(r'"route":"([^"]*)"').firstMatch(json);
          route = routeMatch?.group(1);
        }
        if (route != null) {
          debugPrint('📱 Navigating to: $route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _navigateToRoute(route!);
            } else {
              debugPrint('Widget not mounted');
            }
          });
        }
      } catch (e) {
        debugPrint('$e');
      }
    });
  }

  void _navigateToRoute(String route) {
    if (!mounted) {
      return;
    }

    final now = DateTime.now();

    if (_lastNavigationTime != null &&
        _lastNavigatedRoute == route &&
        now.difference(_lastNavigationTime!).inSeconds < 2) {
      return;
    }

    _lastNavigationTime = now;
    _lastNavigatedRoute = route;

    final segments = route.split('/');

    if (route.contains('forum-chat') && segments.length > 2) {
      final forumId = int.tryParse(segments[2]);
      if (forumId != null && mounted) {
        context.router.navigate(ForumChatRoute(forumId: forumId));
        return;
      }
    }

    if (route.contains('fundraising') && segments.length > 2) {
      final fundraisingId = int.tryParse(segments[2]);
      if (fundraisingId != null && mounted) {
        context.router.navigate(FundraisingDetailRoute(id: fundraisingId));
        return;
      }
    }

    if (mounted) {
      context.router.pushPath(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mesCount = context.watch<CommonRepository>().messageCount;

    return AutoTabsScaffold(
      homeIndex: 4,

      routes: [HomeRoute(), FundraisingRoute(), PetRoute(), ForumRoute()],

      bottomNavigationBuilder: (_, tabsRouter) {
        if (widget.initialIndex != null && !_hasSetInitialIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.initialIndex != tabsRouter.activeIndex) {
              tabsRouter.setActiveIndex(widget.initialIndex!);
            }
          });
          _hasSetInitialIndex = true;
        }

        final badgeCount = mesCount ?? 0;
        String displayCount = badgeCount > 99 ? '99+' : badgeCount.toString();

        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          selectedItemColor: PawsColors.primary,
          unselectedItemColor: PawsColors.disabled,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          onTap: tabsRouter.setActiveIndex,
          items: [
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.house),
            ),
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.heartHandshake),
            ),
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.dog),
            ),

            BottomNavigationBarItem(
              label: '',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(LucideIcons.messageCircle),
                  if (badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            displayCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _forumChatsChannel?.unsubscribe();
    super.dispose();
  }
}
