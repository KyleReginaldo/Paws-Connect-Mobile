// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/repository/common_repository.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/features/google_map/models/address_model.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/text.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onProfileTap;
  final Function()? onOpenCurrentLocation;
  final Address? address;
  final UserProfile? profile;
  final GlobalKey? locationButtonKey;
  final GlobalKey? notificationsButtonKey;
  final GlobalKey? profileButtonKey;

  const HomeAppBar({
    super.key,
    this.onProfileTap,
    this.onOpenCurrentLocation,
    this.address,
    this.profile,
    this.locationButtonKey,
    this.notificationsButtonKey,
    this.profileButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: PawsColors.primary,
      foregroundColor: Colors.white,
      shadowColor: Colors.white,
      centerTitle: false,
      title: GestureDetector(
        key: locationButtonKey,
        onTap: onOpenCurrentLocation,
        child: Row(
          spacing: 4,
          children: [
            Icon(LucideIcons.mapPin, size: 24, color: Colors.white),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PawsText(
                    address?.city != null
                        ? address?.city ?? 'Current location'
                        : 'Location',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  PawsText(
                    address?.fullAddress ?? 'Add address',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (profile != null)
          Consumer<CommonRepository>(
            builder: (context, notifRepo, _) {
              final unread = notifRepo.notificationCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    key: notificationsButtonKey,
                    onPressed: () {
                      context.router.push(NotificationRoute()).then((_) {
                        // Optionally mark all as viewed when returning
                        // notifRepo.markAllViewed(USER_ID ?? ''); // if USER_ID accessible
                      });
                    },
                    icon: Iconify(
                      Ri.notification_line,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if ((unread ?? 0) > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Center(
                          child: Text(
                            (unread ?? 0) > 99 ? '99+' : unread.toString(),
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
              );
            },
          ),
        profile != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  key: profileButtonKey,
                  onTap: onProfileTap,
                  child: UserAvatar(
                    imageUrl: profile!.profileImageLink,
                    initials: profile!.username,
                    size: 24,
                  ),
                ),
              )
            : InkWell(
                key: profileButtonKey,
                onTap: () {
                  context.router.push(SignInRoute());
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: PawsText('Sign In', color: Colors.white),
                ),
              ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
