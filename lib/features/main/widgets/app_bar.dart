// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/features/google_map/models/address_model.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

import '../../../core/widgets/text.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onProfileTap;
  final Function()? onOpenCurrentLocation;
  final Address? address;
  final UserProfile? profile;
  const HomeAppBar({
    super.key,
    this.onProfileTap,
    this.onOpenCurrentLocation,
    this.address,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: GestureDetector(
        onTap: onOpenCurrentLocation,
        child: Row(
          spacing: 4,
          children: [
            Icon(LucideIcons.mapPin, size: 24, color: PawsColors.primary),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PawsText('Current location', fontSize: 13),
                  PawsText(
                    address?.fullAddress ?? 'Add address',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.router.push(NotificationRoute());
          },
          icon: Icon(LucideIcons.bell, size: 20),
        ),
        profile != null
            ? IconButton(
                onPressed: onProfileTap,
                icon: UserAvatar(
                  imageUrl: profile!.profileImageLink,
                  initials: profile!.username,
                  size: 24,
                ),
              )
            : InkWell(
                onTap: onProfileTap,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PawsColors.primary, width: 1.5),
                  ),
                  child: PawsText('Sign In', color: PawsColors.primary),
                ),
              ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
