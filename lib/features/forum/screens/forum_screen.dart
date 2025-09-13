import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ForumRepository>();
      repo.setForums(USER_ID ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ForumRepository>();
    final forums = repo.forums;
    final errorMessage = repo.errorMessage;
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
                    Icon(
                      Icons.forum_outlined,
                      size: 64,
                      color: PawsColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    PawsText(
                      errorMessage.isNotEmpty
                          ? 'Error loading forums'
                          : 'No forums available',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: PawsColors.textPrimary,
                    ),
                    SizedBox(height: 8),
                    PawsText(
                      errorMessage.isNotEmpty
                          ? errorMessage
                          : 'Start a new discussion!',
                      fontSize: 14,
                      color: PawsColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: forums.length,
                itemBuilder: (context, index) {
                  final forum = forums[index];
                  return ListTile(
                    title: PawsText(
                      forum.forumName,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: PawsColors.textPrimary,
                    ),
                    subtitle: PawsText(
                      'Created ${DateFormat('MMM dd, yyyy').format(forum.createdAt)}',
                      fontSize: 12,
                      color: PawsColors.textSecondary,
                    ),
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
