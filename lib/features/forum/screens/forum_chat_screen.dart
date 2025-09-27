// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/components/components.dart';
import '../../../core/router/app_route.gr.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../models/forum_model.dart';
import '../repository/forum_repository.dart';

@RoutePage()
class ForumChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final int forumId;
  const ForumChatScreen({
    super.key,
    @PathParam('forumId') required this.forumId,
  });

  @override
  State<ForumChatScreen> createState() => _ForumChatScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ForumRepository>(),
      child: this,
    );
  }
}

class _ForumChatScreenState extends State<ForumChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  XFile? _imageFile;
  int _previousMessageCount = 0;
  late RealtimeChannel chatChannel;
  bool _isSendingMessage = false;
  @override
  void initState() {
    super.initState();
    chatChannel = supabase.channel(
      'public:forum_chats:forum=eq.${widget.forumId}',
    );

    // Load chats immediately without waiting
    _loadChats();
    listenToChanges();
  }

  Future<void> _loadChats() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<ForumRepository>();
      repo.getRealChats(widget.forumId);
    });
    // Immediate scroll to bottom - no delay
    if (mounted && _scrollController.hasClients) {
      _scrollToBottom();
    }
  }

  void listenToChanges() {
    chatChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'forum_chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'forum',
            value: widget.forumId,
          ),
          callback: (payload) {
            // Check if widget is still mounted before accessing context
            if (mounted) {
              context.read<ForumRepository>().setForumChats(widget.forumId);
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    // Unsubscribe from realtime channel to prevent memory leaks
    chatChannel.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Since reverse: true, position 0 is at the bottom
        duration: const Duration(milliseconds: 100), // Ultra fast scroll
        curve: Curves.fastOutSlowIn, // Snappier curve
      );
    }
  }

  void _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _sendMessage() {
    context.read<ForumRepository>().addPendingChat(
      _messageController.text.trim(),
    );
    if (_messageController.text.trim().isEmpty || _isSendingMessage) return;

    final message = _messageController.text.trim();
    _messageController.clear(); // Clear immediately for instant feedback

    // Immediate scroll to bottom
    _scrollToBottom();

    // Set sending state
    setState(() {
      _isSendingMessage = true;
    });

    // Fire-and-forget send - maximum speed
    ForumProvider()
        .sendChat(
          sender: USER_ID ?? '',
          message: message,
          forumId: widget.forumId,
          imageFile: _imageFile,
        )
        .catchError((e) {
          // Only handle errors, don't wait for success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            // Restore message if sending failed
            _messageController.text = message;
          }
        })
        .whenComplete(() {
          // Reset sending state when done
          if (mounted) {
            setState(() {
              _imageFile = null;
              _isSendingMessage = false;
            });
            context.read<ForumRepository>().setForumChats(widget.forumId);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ForumRepository>();
    final forumChats = repo.forumChats;
    final isLoadingChats = repo.isLoadingChats;
    final pendingChats = repo.pendingChats;
    // Auto-scroll to bottom when new messages arrive - instant
    if (forumChats.length != _previousMessageCount) {
      _previousMessageCount = forumChats.length;
      if (forumChats.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const PawsText(
          'Forum Chat',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        actions: [
          IconButton(
            onPressed: () async {
              await SharePlus.instance.share(
                ShareParams(
                  text:
                      'Join the discussion in this forum: https://paws-connect-sable.vercel.app/forum-chat/${widget.forumId}',
                ),
              );
            },
            icon: Iconify(Ion.md_share_alt, color: PawsColors.textSecondary),
            color: PawsColors.textSecondary,
          ),
          IconButton(
            onPressed: () {
              context.router.push(ForumSettingsRoute(forumId: widget.forumId));
            },
            icon: Icon(Icons.info),
            color: PawsColors.textSecondary,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoadingChats && forumChats.isEmpty
                ? ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: 8, // Show 8 skeleton messages
                    itemBuilder: (context, index) =>
                        _buildSkeletonMessage(index),
                  )
                : forumChats.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.messageCircle,
                          size: 64,
                          color: PawsColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        PawsText(
                          'No messages yet',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: PawsColors.textPrimary,
                        ),
                        SizedBox(height: 8),
                        PawsText(
                          'Start the conversation!',
                          color: PawsColors.textSecondary,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadChats,
                    child: Builder(
                      builder: (context) {
                        // Build a combined list: server chats followed by pending chats
                        final combined = <dynamic>[];
                        combined.addAll(forumChats);
                        combined.addAll(pendingChats);

                        if (combined.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: combined.length,
                          itemBuilder: (context, index) {
                            // Reverse the index to show latest messages at bottom
                            final reversedIndex = combined.length - 1 - index;
                            final item = combined[reversedIndex];

                            // If item is a ForumChat from the server
                            if (item is ForumChat) {
                              final chat = item;
                              final isCurrentUser = chat.users.id == USER_ID;
                              final showAvatar =
                                  reversedIndex == forumChats.length - 1 ||
                                  (reversedIndex + 1 < forumChats.length
                                      ? forumChats[reversedIndex + 1]
                                                .users
                                                .id !=
                                            chat.users.id
                                      : true);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: isCurrentUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isCurrentUser) ...[
                                      showAvatar
                                          ? UserAvatar(
                                              imageUrl:
                                                  null, // no image in Users model
                                              initials: chat.users.username,
                                              size: 32,
                                            )
                                          : const SizedBox(width: 32),
                                      const SizedBox(width: 8),
                                    ],

                                    Flexible(
                                      child: ChatBubble(
                                        isMe: isCurrentUser,
                                        color: isCurrentUser
                                            ? PawsColors.primary
                                            : PawsColors.border,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!isCurrentUser && showAvatar)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: PawsText(
                                                  chat.users.username,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: PawsColors.primary,
                                                ),
                                              ),
                                            if (chat.imageUrl != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: NetworkImageView(
                                                  chat.imageUrl!,
                                                  height: 220,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            PawsText(
                                              chat.message,
                                              fontSize: 14,
                                              color: isCurrentUser
                                                  ? Colors.white
                                                  : PawsColors.textPrimary,
                                            ),
                                            const SizedBox(height: 4),
                                            PawsText(
                                              timeago.format(chat.sentAt),
                                              fontSize: 10,
                                              color: isCurrentUser
                                                  ? Colors.white70
                                                  : PawsColors.textSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    if (isCurrentUser) const SizedBox(width: 8),
                                  ],
                                ),
                              );
                            }

                            // Otherwise it's a pending chat (String)
                            final pendingMessage = item as String;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: PendingChatBubble(pendingMessage),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),

          // Message input area using component
          MessageInputBar(
            controller: _messageController,
            isSending: _isSendingMessage,
            onPickImage: _pickImage,
            onSend: _sendMessage,
            previewImage: _imageFile != null ? File(_imageFile!.path) : null,
            onRemovePreview: () => setState(() => _imageFile = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonMessage(int index) {
    final isEven = index % 2 == 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isEven
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isEven) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isEven ? Colors.grey[200] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isEven ? 4 : 16),
                bottomRight: Radius.circular(isEven ? 16 : 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          if (!isEven) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
