// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/services/supabase_service.dart';
import '../repository/forum_repository.dart';

@RoutePage()
class ForumSettingsScreen extends StatefulWidget implements AutoRouteWrapper {
  final int forumId;
  const ForumSettingsScreen({
    super.key,
    @PathParam('forumId') required this.forumId,
  });

  @override
  State<ForumSettingsScreen> createState() => _ForumSettingsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ForumRepository>(),
      child: this,
    );
  }
}

class _ForumSettingsScreenState extends State<ForumSettingsScreen> {
  late RealtimeChannel forumChannel;

  void listenToChanges() {
    debugPrint(
      '🔊 Setting up forum members listener for forum ID: ${widget.forumId}',
    );

    forumChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'forum_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'forum',
            value: widget.forumId,
          ),
          callback: (payload) {},
        )
        .subscribe((status, error) {
          debugPrint('📡 Subscription status: $status');
          if (error != null) {
            debugPrint('❌ Subscription error: $error');
          } else {
            debugPrint('✅ Successfully subscribed to forum members changes');
          }
        });
  }

  @override
  void initState() {
    super.initState();
    debugPrint(
      '🚀 Initializing ForumSettingsScreen for forum ID: ${widget.forumId}',
    );

    // Create unique channel name
    forumChannel = supabase.channel(
      'forum_members_${widget.forumId}_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('🔄 Loading initial forum data...');
      context.read<ForumRepository>().setForumById(widget.forumId);
    });

    // Set up listener
    listenToChanges();
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing ForumSettingsScreen and unsubscribing channel');
    forumChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forum = context.watch<ForumRepository>().forum;
    final isLoading = context.watch<ForumRepository>().isLoadingForums;
    if (forum != null) {
      return Scaffold(
        appBar: AppBar(),
        body: isLoading
            ? LinearProgressIndicator()
            : RefreshIndicator(
                onRefresh: () async {
                  context.read<ForumRepository>().setForumById(widget.forumId);
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: PawsColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PawsColors.primary.withValues(alpha: 0.2),
                            width: 3,
                          ),
                        ),
                        child: forum.private
                            ? Icon(
                                LucideIcons.shieldCheck,
                                size: 64,
                                color: PawsColors.primary,
                              )
                            : Icon(
                                LucideIcons.globe,
                                size: 64,
                                color: PawsColors.primary,
                              ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        spacing: 4,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PawsText(
                            forum.forumName,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PawsColors.textPrimary,
                          ),
                          PawsText(
                            forum.private ? '(Private)' : '(Public)',
                            fontSize: 14,
                            color: PawsColors.textPrimary,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: () async {
                              await SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      'Join ${forum.forumName} forum\nhttps://paws-connect-sable.vercel.app/forum-invite/${forum.id}?invitedBy=$USER_ID',
                                ),
                              );
                            },
                            style: ButtonStyle().copyWith(
                              backgroundColor: WidgetStatePropertyAll(
                                PawsColors.textPrimary,
                              ),
                            ),
                            icon: Icon(
                              LucideIcons.share2,
                              size: 16,
                              color: PawsColors.textLight,
                            ),
                          ),
                          IconButton.filled(
                            onPressed: () async {
                              debugPrint(
                                '🚀 Navigating to add forum member screen',
                              );
                              bool? result = await context.router.push(
                                AddForumMemberRoute(forumId: forum.id),
                              );
                              debugPrint(
                                '🔄 Returned from add member screen with result: $result',
                              );
                              if (result == true) {
                                context.read<ForumRepository>().setForumById(
                                  widget.forumId,
                                );
                              }
                            },
                            style: ButtonStyle().copyWith(
                              backgroundColor: WidgetStatePropertyAll(
                                PawsColors.textPrimary,
                              ),
                            ),
                            icon: Icon(
                              LucideIcons.userPlus,
                              size: 16,
                              color: PawsColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      // PawsText('${forum.memberCount} member(s)'),
                      SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (forum.members != null &&
                                forum.members!.isNotEmpty)
                              PawsText(
                                'Forum members (${forum.members!.length})',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            forum.members != null && forum.members!.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: forum.members!.map((member) {
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: VisualDensity(
                                          horizontal: 0,
                                          vertical: -4,
                                        ),
                                        leading: member.profileImageLink != null
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  member.profileImageLink!,
                                                ),
                                              )
                                            : CircleAvatar(
                                                backgroundImage: AssetImage(
                                                  'assets/images/user.png',
                                                ),
                                              ),
                                        title: PawsText(member.username),
                                        subtitle: PawsText(
                                          'Joined on ${DateFormat('MMM dd, yyyy').format(member.joinedAt)}',
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : Center(child: PawsText('No members yet')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }
    return Scaffold(appBar: AppBar(), body: LinearProgressIndicator());
  }
}
