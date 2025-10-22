// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/global_confirm_dialog.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/components/components.dart';
import '../../../core/router/app_route.gr.dart';
import '../../../core/services/supabase_service.dart';
import '../models/forum_model.dart';
import '../provider/forum_provider.dart';
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
  final ImagePicker _picker = ImagePicker();

  void handleNotificationStatus(int forumMemberId, bool mute) async {
    final result = await ForumProvider().toggleForumNotificationSettings(
      forumMemberId: forumMemberId,
      mute: mute,
    );
    if (result.isError) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.value)));
      context.read<ForumRepository>().fetchForumById(
        widget.forumId,
        USER_ID ?? '',
      );
    }
  }

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

    forumChannel = supabase.channel(
      'forum_members_${widget.forumId}_${DateTime.now().millisecondsSinceEpoch}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('🔄 Loading initial forum data...');
      context.read<ForumRepository>().fetchForumById(
        widget.forumId,
        USER_ID ?? '',
      );
    });

    listenToChanges();
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing ForumSettingsScreen and unsubscribing channel');
    forumChannel.unsubscribe();
    super.dispose();
  }

  void approveMember(int memberId) async {
    if (!mounted) return;
    final result = await ForumProvider().approveOrRejectMember(
      forumId: widget.forumId,
      forumMemberId: memberId,
      status: 'APPROVED',
    );
    if (result.isError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
    } else {
      context.read<ForumRepository>().fetchForumById(
        widget.forumId,
        USER_ID ?? "",
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.value)));
    }
  }

  void rejectMember(int memberId) async {
    if (!mounted) return;
    final result = await ForumProvider().approveOrRejectMember(
      forumId: widget.forumId,
      forumMemberId: memberId,
      status: 'REJECTED',
    );
    if (result.isError) {
      EasyLoading.showToast(
        result.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      if (mounted) {
        context.read<ForumRepository>().fetchForumById(
          widget.forumId,
          USER_ID ?? "",
        );
      }
      EasyLoading.showToast(
        result.value,
        toastPosition: EasyLoadingToastPosition.top,
      );
    }
  }

  void leaveForum(int id) async {
    final result = await ForumProvider().quitForum(
      forumId: id,
      userId: USER_ID ?? "",
    );
    if (result.isError) {
      if (!mounted) return;
      EasyLoading.showToast(
        result.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      if (!mounted) return;
      EasyLoading.showToast(
        result.value,
        toastPosition: EasyLoadingToastPosition.top,
      );
      context.router.popUntilRoot();
    }
  }

  void kickMember(int id, String memberId) async {
    final result = await ForumProvider().kickMember(
      forumId: id,
      kickedBy: USER_ID ?? "",
      userId: memberId,
    );
    if (result.isError) {
      if (!mounted) return;
      EasyLoading.showToast(
        result.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      if (!mounted) return;
      EasyLoading.showToast(
        result.value,
        toastPosition: EasyLoadingToastPosition.top,
      );
      context.read<ForumRepository>().fetchForumById(
        widget.forumId,
        USER_ID ?? "",
      );
    }
  }

  Future<void> _onChangeForumImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (picked == null) return;
      EasyLoading.show(status: 'Updating image...');
      final result = await ForumProvider().updateForum(
        forumId: widget.forumId,
        forumImageFile: picked,
      );
      EasyLoading.dismiss();
      if (mounted) {
        if (result.isError) {
          EasyLoading.showToast(result.error);
        } else {
          EasyLoading.showToast('Forum image updated');
          context.read<ForumRepository>().fetchForumById(
            widget.forumId,
            USER_ID ?? '',
          );
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        EasyLoading.showToast('Failed to update image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final forum = context.watch<ForumRepository>().forum;
    final isLoading = context.watch<ForumRepository>().isLoadingForums;
    Member? myProfile;
    final members = forum?.members;
    if (USER_ID != null && members != null && members.isNotEmpty) {
      for (final m in members) {
        if (m.id == USER_ID) {
          myProfile = m;
          break;
        }
      }
    }
    debugPrint('user id: $USER_ID');
    debugPrint('forum: ${forum?.createdBy}');
    debugPrint('private: ${forum?.private}');
    if (forum != null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                showGlobalConfirmDialog(
                  context,
                  title: 'Leave Forum',
                  message: 'Are you sure you want to leave this forum?',
                  confirmLabel: 'Leave',
                  cancelLabel: 'Cancel',
                ).then((value) {
                  if (value == true) {
                    leaveForum(forum.id);
                  }
                });
              },
              icon: Icon(
                LucideIcons.doorOpen,
                size: 24,
                color: PawsColors.error,
              ),
            ),
          ],
        ),
        body: isLoading
            ? LinearProgressIndicator()
            : RefreshTrigger(
                onRefresh: () async {
                  context.read<ForumRepository>().fetchForumById(
                    widget.forumId,
                    USER_ID ?? "",
                  );
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: PawsColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PawsColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  (forum.transformedForumImageUrl != null &&
                                      forum
                                          .transformedForumImageUrl!
                                          .isNotEmpty)
                                  ? NetworkImageView(
                                      forum.transformedForumImageUrl!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : Center(
                                      child: Icon(
                                        forum.private
                                            ? LucideIcons.shieldCheck
                                            : LucideIcons.globe,
                                        size: 64,
                                        color: PawsColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _onChangeForumImage,
                              child: const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  LucideIcons.camera,
                                  size: 16,
                                  color: PawsColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                          if ((forum.private == true &&
                                  forum.createdBy == USER_ID) ||
                              (forum.private == false &&
                                  (forum.members ?? []).any(
                                    (member) => member.id == USER_ID,
                                  )))
                            IconButton.filled(
                              onPressed: () async {
                                await SharePlus.instance.share(
                                  ShareParams(
                                    text:
                                        'Join ${forum.forumName} forum\nhttps://paws-connect-rho.vercel.app/forum-invite/${forum.id}?invitedBy=$USER_ID',
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
                          if ((forum.private == true &&
                                  forum.createdBy == USER_ID) ||
                              (forum.private == false &&
                                  (forum.members ?? []).any(
                                    (member) => member.id == USER_ID,
                                  )))
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
                                  context
                                      .read<ForumRepository>()
                                      .fetchForumById(
                                        widget.forumId,
                                        USER_ID ?? "",
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
                          IconButton.filled(
                            onPressed: () async {
                              if (myProfile != null) {
                                handleNotificationStatus(
                                  myProfile.forumMemberId,
                                  !(myProfile.mute),
                                );
                              }
                            },
                            style: ButtonStyle().copyWith(
                              backgroundColor: WidgetStatePropertyAll(
                                myProfile != null && myProfile.mute
                                    ? PawsColors.primary
                                    : PawsColors.textPrimary,
                              ),
                            ),
                            icon: Icon(
                              myProfile != null && myProfile.mute
                                  ? LucideIcons.bellOff
                                  : LucideIcons.bell,
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
                                        onTap: member.id != USER_ID
                                            ? () {
                                                context.router.push(
                                                  ProfileRoute(id: member.id),
                                                );
                                              }
                                            : null,
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
                                        title: PawsText(
                                          '${member.username}(${member.id == USER_ID
                                              ? "You"
                                              : member.id == forum.createdBy
                                              ? "Admin"
                                              : member.invitationStatus == "APPROVED"
                                              ? "Member"
                                              : "Pending"})',
                                        ),
                                        subtitle: PawsText(
                                          member.invitationStatus == 'PENDING'
                                              ? 'Waiting for acceptance'
                                              : 'Joined on ${DateFormat('MMM dd, yyyy').format(member.joinedAt)}',
                                        ),
                                        trailing:
                                            forum.createdBy == USER_ID &&
                                                member.invitationStatus ==
                                                    'PENDING'
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                spacing: 8,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      approveMember(
                                                        member.forumMemberId,
                                                      );
                                                    },
                                                    style: ButtonStyle().copyWith(
                                                      shape: WidgetStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          WidgetStatePropertyAll(
                                                            PawsColors
                                                                .backgroundDark,
                                                          ),
                                                    ),
                                                    icon: Icon(
                                                      LucideIcons.check,
                                                      size: 13,
                                                      color:
                                                          PawsColors.textLight,
                                                    ),
                                                    label: PawsText(
                                                      'Accept',
                                                      color:
                                                          PawsColors.textLight,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      rejectMember(
                                                        member.forumMemberId,
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: PawsColors.error,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : PopupMenuButton(
                                                itemBuilder: (context) {
                                                  return [
                                                    if (forum.createdBy ==
                                                            USER_ID &&
                                                        member.id != USER_ID &&
                                                        member.invitationStatus ==
                                                            'APPROVED')
                                                      PopupMenuItem(
                                                        value: 'kick',
                                                        child: Row(
                                                          spacing: 8,
                                                          children: [
                                                            Icon(
                                                              LucideIcons.userX,
                                                              size: 16,
                                                              color: PawsColors
                                                                  .error,
                                                            ),
                                                            PawsText('Kick'),
                                                          ],
                                                        ),
                                                      ),
                                                  ];
                                                },
                                                onSelected: (value) {
                                                  if (value == 'kick') {
                                                    showGlobalConfirmDialog(
                                                      context,
                                                      title: 'Kick Member',
                                                      message:
                                                          'Are you sure you want to kick ${member.username} from this forum?',
                                                      confirmLabel: 'Kick',
                                                      cancelLabel: 'Cancel',
                                                    ).then((value) {
                                                      if (value == true) {
                                                        kickMember(
                                                          forum.id,
                                                          member.id,
                                                        );
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                        // Container(
                                        //     padding: EdgeInsets.symmetric(
                                        //       vertical: 4,
                                        //       horizontal: 8,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: PawsColors.success
                                        //           .withValues(alpha: 0.1),
                                        //       borderRadius:
                                        //           BorderRadius.circular(4),
                                        //     ),
                                        //     child: PawsText(
                                        //       member.invitationStatus
                                        //           .capitalize(),
                                        //       fontSize: 13,
                                        //       color: PawsColors.success,
                                        //     ),
                                        //   ),
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
