import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/forum/widgets/forum_tile.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
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
  late RealtimeChannel _forumMembersChannel;
  late RealtimeChannel _forumChannel;

  DateTime _lastRealtimeRefresh = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ForumRepository>();
      repo.fetchForums(USER_ID ?? '');
    });

    _forumChatsChannel = supabase.channel('public:forum_chats');
    _forumMembersChannel = supabase.channel('public:forum_members');
    _forumChannel = supabase.channel('public:forum');

    _forumChatsChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'forum_chats',
          callback: (_) {
            if (!mounted) return;
            final now = DateTime.now();

            if (now.difference(_lastRealtimeRefresh).inMilliseconds < 300) {
              return;
            }
            _lastRealtimeRefresh = now;
            context.read<ForumRepository>().fetchForums(USER_ID ?? '');
          },
        )
        .subscribe();
    _forumMembersChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'forum_members',
          callback: (_) {
            if (!mounted) return;
            context.read<ForumRepository>().fetchForums(USER_ID ?? '');
          },
        )
        .subscribe();
    _forumChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'forum',
          callback: (_) {
            if (!mounted) return;
            context.read<ForumRepository>().fetchForums(USER_ID ?? '');
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _forumChatsChannel.unsubscribe();
    _forumChannel.unsubscribe();
    _forumMembersChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ForumRepository>();
    final forums = repo.forums;
    final isLoadingForums = repo.isLoadingForums;

    return Scaffold(
      appBar: AppBar(title: const Text('Forum'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          final repo = context.read<ForumRepository>();
          repo.fetchForums(USER_ID ?? '');
        },
        child: isLoadingForums && forums.isEmpty
            ? ListView.builder(
                itemCount: 6,
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
                  return ForumTile(forum: forum);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? reload = await context.router.push(const AddForumRoute());
          if (reload == true && mounted) {
            context.read<ForumRepository>().fetchForums(USER_ID ?? '');
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
