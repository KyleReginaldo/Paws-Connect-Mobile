import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/supabase/client.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    handleOneSignalLogin();
    super.initState();
  }

  void handleOneSignalLogin() async {
    await OneSignal.login(USER_ID);
  }

  @override
  Widget build(BuildContext context) {
    // final user = context.watch<AuthRepository>().user;
    return AutoTabsScaffold(
      routes: [HomeRoute(), NotfoundRoute(), NotfoundRoute(), NotfoundRoute()],
      bottomNavigationBuilder: (_, tabsRouter) {
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
