// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';

import '../../../core/widgets/text.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onOpenDrawer;
  final Function()? onOpenCurrentLocation;
  const HomeAppBar({super.key, this.onOpenDrawer, this.onOpenCurrentLocation});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: GestureDetector(
        onTap: onOpenCurrentLocation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PawsText('Current location', fontSize: 13),
            Row(
              spacing: 4,
              children: [
                Icon(LucideIcons.mapPin, size: 16, color: PawsColors.primary),
                PawsText(
                  'General Trias, Cavite',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(LucideIcons.bell)),
        IconButton(
          onPressed: onOpenDrawer,
          icon: Icon(LucideIcons.circleUserRound),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
