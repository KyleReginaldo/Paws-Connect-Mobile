import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
import '../models/forum_model.dart';
import '../repository/forum_repository.dart';

@RoutePage()
class ForumScreen extends StatefulWidget implements AutoRouteWrapper {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ForumRepository>(),
      child: this,
    );
  }
}

class _ForumScreenState extends State<ForumScreen> {
  late RealtimeChannel _forumChatsChannel;
  DateTime _lastRealtimeRefresh = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ForumRepository>();
      repo.setForums(USER_ID ?? '');
    });

    // Screen-level listener: keep forum list (e.g., last message preview) fresh
    _forumChatsChannel = supabase.channel('public:forum_chats_forum_screen');
    _forumChatsChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'forum_chats',
          callback: (_) {
            if (!mounted) return;
            final now = DateTime.now();
            // Throttle to avoid redundant rapid refreshes when multiple messages arrive
            if (now.difference(_lastRealtimeRefresh).inMilliseconds < 300) {
              return;
            }
            _lastRealtimeRefresh = now;
            context.read<ForumRepository>().setForums(USER_ID ?? '');
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    try {
      _forumChatsChannel.unsubscribe();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ForumRepository>();
    final forums = repo.forums;
    final isLoadingForums = repo.isLoadingForums;

    return Scaffold(
      appBar: AppBar(
        title: const PawsText(
          'Forum',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final repo = context.read<ForumRepository>();
          repo.setForums(USER_ID ?? '');
        },
        child: isLoadingForums && forums.isEmpty
            ? ListView.builder(
                itemCount: 6, // Show 6 skeleton items
                itemBuilder: (context, index) => _buildSkeletonItem(),
              )
            : forums.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/empty_chat.png', width: 120),
                    PawsText(
                      "No forum available",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    PawsText("All forums you join will appear here."),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: forums.length,
                itemBuilder: (context, index) {
                  final forum = forums[index];
                  // Safely find current user's membership (singleWhere would throw if none)
                  Member? myProfile;
                  if (USER_ID != null && (forum.members?.isNotEmpty ?? false)) {
                    for (final m in forum.members!) {
                      if (m.id == USER_ID) {
                        myProfile = m;
                        break;
                      }
                    }
                  }
                  return ListTile(
                    title: myProfile != null && myProfile.mute
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
                    trailing:
                        (forum.members ?? []).any(
                          (member) => member.id == USER_ID,
                        )
                        ? const Icon(
                            Icons.chevron_right,
                            color: PawsColors.textSecondary,
                          )
                        : PawsText(
                            'Pending',
                            fontSize: 12,
                            color: PawsColors.warning,
                          ),
                    onTap:
                        (forum.members ?? []).any(
                          (member) => member.id == USER_ID,
                        )
                        ? () {
                            context.router.push(
                              ForumChatRoute(forumId: forum.id),
                            );
                          }
                        : null,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? reload = await context.router.push(const AddForumRoute());
          if (reload == true && mounted) {
            context.read<ForumRepository>().setForums(USER_ID ?? '');
          }
        },
        child: Icon(LucideIcons.messageCirclePlus),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return ListTile(
      title: Container(
        height: 16,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Container(
          height: 12,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      trailing: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
