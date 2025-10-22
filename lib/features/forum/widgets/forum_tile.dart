// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/widgets/network_image_viewer.dart';
import 'package:paws_connect/features/forum/models/forum_model.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/supabase/client.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

class ForumTile extends StatelessWidget {
  final Forum forum;
  const ForumTile({super.key, required this.forum});

  @override
  Widget build(BuildContext context) {
    debugPrint('image: ${forum.forumImageUrl}');
    final profile = forum.members?.singleWhere((e) => e.id == USER_ID);
    return ListTile(
      title: profile != null && profile.mute
          ? Row(
              spacing: 5,
              children: [
                Icon(
                  LucideIcons.bellOff,
                  size: 16,
                  color: PawsColors.textSecondary,
                ),
                PawsText(
                  forum.forumName,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: PawsColors.textPrimary,
                ),
              ],
            )
          : PawsText(
              forum.forumName,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: PawsColors.textPrimary,
            ),
      leading: ClipOval(
        child: forum.forumImageUrl != null
            ? NetworkImageView(
                forum.forumImageUrl!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/user.png',
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
      ),
      subtitle: forum.lastChat != null
          ? PawsText(
              '${forum.lastChat!.sender.username}: ${forum.lastChat!.imageUrl != null ? 'Sent an image' : forum.lastChat!.message}',
              fontSize: 14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              color: forum.lastChat!.isViewed == false
                  ? PawsColors.textPrimary
                  : PawsColors.textSecondary,
              fontWeight: forum.lastChat!.isViewed == false
                  ? FontWeight.w600
                  : FontWeight.normal,
            )
          : null,
      trailing: (forum.members ?? []).any((member) => member.id == USER_ID)
          ? const Icon(Icons.chevron_right, color: PawsColors.textSecondary)
          : PawsText('Pending', fontSize: 12, color: PawsColors.warning),
      onTap: (forum.members ?? []).any((member) => member.id == USER_ID)
          ? () {
              context.router.push(ForumChatRoute(forumId: forum.id));
            }
          : null,
    );
  }
}
