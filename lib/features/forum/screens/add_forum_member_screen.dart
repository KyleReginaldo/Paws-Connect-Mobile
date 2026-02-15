// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/search_field.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/forum/models/forum_model.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:paws_connect/features/forum/repository/forum_repository.dart';
import 'package:provider/provider.dart';

@RoutePage()
class AddForumMemberScreen extends StatefulWidget implements AutoRouteWrapper {
  final int forumId;
  const AddForumMemberScreen({super.key, required this.forumId});

  @override
  State<AddForumMemberScreen> createState() => _AddForumMemberScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ForumRepository>(),
      child: this,
    );
  }
}

class _AddForumMemberScreenState extends State<AddForumMemberScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ForumRepository>();
      repo.fetchAvailableUsers(widget.forumId);
    });
    super.initState();
  }

  List<AvailableUser> selectedUsers = [];

  void handleAddMembers() async {
    EasyLoading.show(status: 'Adding members...');
    final result = await ForumProvider().addMembers(
      userId: USER_ID ?? "",
      forumId: widget.forumId,
      memberIds: selectedUsers.map((user) => user.id).toList(),
    );
    if (result.isError) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showToast(
        result.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showToast(
        'Members added successfully',
        toastPosition: EasyLoadingToastPosition.top,
      );
      context.router.root.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<ForumRepository>().availableUsers;
    final isLoading = context.watch<ForumRepository>().usersLoading;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Forum Members',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          actions: [
            if (selectedUsers.isNotEmpty)
              PawsTextButton(
                label: 'Add (${selectedUsers.length})',
                onPressed: () {
                  handleAddMembers();
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PawsSearchBar(
                hintText: 'Search users',
                onChanged: (value) {
                  debugPrint('Search: $value');
                  final repo = context.read<ForumRepository>();
                  repo.fetchAvailableUsers(widget.forumId, username: value);
                },
              ),
              PawsText('Suggested'),
              if (context.watch<ForumRepository>().userErrorMessage != null)
                Center(
                  child: PawsText(
                    context.watch<ForumRepository>().userErrorMessage ?? '',
                    fontSize: 12,
                    color: PawsColors.textSecondary,
                  ),
                ),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      spacing: 8,
                      children: users
                          .map(
                            (member) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity(
                                horizontal: 0,
                                vertical: -4,
                              ),
                              leading: UserAvatar(
                                imageUrl: member.profileImageLink,
                                initials: member.username,
                                size: 32,
                              ),
                              title: PawsText(member.username),
                              trailing: Checkbox(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedUsers.add(member);
                                    } else {
                                      selectedUsers.remove(member);
                                    }
                                  });
                                  debugPrint('Selected Users: $selectedUsers');
                                },
                                value: selectedUsers.contains(member),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
