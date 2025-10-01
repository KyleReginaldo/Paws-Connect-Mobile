// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart'
    as chat_reactions;
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/components/components.dart';
import '../../../core/repository/common_repository.dart';
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
  late final chat_reactions.ReactionsController _controller;

  XFile? _imageFile;
  int _previousMessageCount = 0;
  late RealtimeChannel chatChannel;
  bool _isSendingMessage = false;
  @override
  void initState() {
    super.initState();

    // Initialize reactions controller with current user ID
    _controller = chat_reactions.ReactionsController(
      currentUserId: USER_ID ?? '',
    );

    // Add listener for reaction changes
    _controller.addListener(_onReactionChanged);

    chatChannel = supabase.channel(
      'public:forum_chats:forum=eq.${widget.forumId}',
    );

    // Load chats immediately without waiting
    _loadChats();
    listenToChanges();

    // Mark messages as viewed after frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = USER_ID;
      if (mounted && userId != null && userId.isNotEmpty) {
        try {
          sl<CommonRepository>().markMessagesViewed(
            userId: userId,
            forumId: widget.forumId,
          );
        } catch (e) {
          debugPrint('Failed to mark messages viewed: $e');
        }
      }
    });
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

    // Also listen to reaction changes if you have a separate reactions table
    // chatChannel
    //     .onPostgresChanges(
    //       event: PostgresChangeEvent.all,
    //       schema: 'public',
    //       table: 'forum_chat_reactions', // Adjust table name as needed
    //       callback: (payload) {
    //         if (mounted) {
    //           context.read<ForumRepository>().setForumChats(widget.forumId);
    //         }
    //       },
    //     )
    //     .subscribe();
  }

  @override
  void dispose() {
    // Unsubscribe from realtime channel to prevent memory leaks
    chatChannel.unsubscribe();
    _controller.removeListener(_onReactionChanged);
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

  // Handle reaction changes from the controller
  void _onReactionChanged() {
    debugPrint('Reactions updated');
    // Note: The actual backend sync happens through the config callbacks
    // when users interact with reactions
  }

  // Helper method to manually send reaction to backend
  // You can call this method when implementing reaction tapping
  Future<void> sendReactionToBackend({
    required int chatId,
    required String reaction,
    required bool isAdding,
  }) async {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) return;

    try {
      // Create provider instance
      final provider = ForumProvider();

      if (isAdding) {
        final result = await provider.addReaction(
          forumId: widget.forumId,
          chatId: chatId,
          reaction: reaction,
          userId: userId,
        );

        if (result.isError) {
          debugPrint('Failed to add reaction: ${result.error}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to add reaction'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          debugPrint('Successfully added reaction: $reaction');
          // Refresh chat data to get updated reactions from server
          if (mounted) {
            context.read<ForumRepository>().setForumChats(widget.forumId);
          }
        }
      } else {
        final result = await provider.removeReaction(
          forumId: widget.forumId,
          chatId: chatId,
          reaction: reaction,
          userId: userId,
        );

        if (result.isError) {
          debugPrint('Failed to remove reaction: ${result.error}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to remove reaction'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          debugPrint('Successfully removed reaction: $reaction');
          // Refresh chat data to get updated reactions from server
          if (mounted) {
            context.read<ForumRepository>().setForumChats(widget.forumId);
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending reaction to backend: $e');
    }
  } // Convert ForumChat reactions to display format

  Map<String, List<String>> _convertReactions(List<Reaction>? reactions) {
    if (reactions == null || reactions.isEmpty) return {};

    final Map<String, List<String>> result = {};
    for (final reaction in reactions) {
      result[reaction.emoji] = reaction.users;
    }
    return result;
  }

  // Initialize reactions for all messages
  void _initializeReactions(List<ForumChat> chats) {
    for (final chat in chats) {
      if (chat.reactions != null && chat.reactions!.isNotEmpty) {
        final reactions = _convertReactions(chat.reactions);
        // Set initial reactions for this message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            for (final entry in reactions.entries) {
              // Add each reaction type to the message
              _controller.addReaction(chat.id.toString(), entry.key);
            }
          }
        });
      }
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
    // Initialize reactions when chat data changes
    if (forumChats.isNotEmpty) {
      _initializeReactions(forumChats);
    }
    for (ForumChat chat in forumChats) {
      if (chat.reactions != null && chat.reactions!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            for (final reaction in chat.reactions!) {
              // Add each reaction type to the message
              _controller.addReaction(chat.id.toString(), reaction.emoji);
            }
          }
        });
      }
    }

    // Auto-scroll to bottom when new messages arrive - instant
    if (forumChats.length != _previousMessageCount) {
      _previousMessageCount = forumChats.length;
      if (forumChats.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom();
      }
    }

    return SafeArea(
      top: false,
      child: Scaffold(
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
              onPressed: () {
                context.router.push(
                  ForumSettingsRoute(forumId: widget.forumId),
                );
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
                              final config = chat_reactions.ChatReactionsConfig(
                                enableHapticFeedback: true,
                                maxReactionsToShow: 3,
                                enableDoubleTap: true,
                              );
                              // Reverse the index to show latest messages at bottom
                              final reversedIndex = combined.length - 1 - index;
                              final item = combined[reversedIndex];

                              // If item is a ForumChat from the server
                              if (item is ForumChat) {
                                final chat = item;
                                final isCurrentUser = chat.users?.id == USER_ID;
                                final showAvatar =
                                    reversedIndex == forumChats.length - 1 ||
                                    (reversedIndex + 1 < forumChats.length
                                        ? forumChats[reversedIndex + 1]
                                                  .users
                                                  ?.id !=
                                              chat.users?.id
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
                                                initials: chat.users?.username,
                                                size: 32,
                                              )
                                            : const SizedBox(width: 32),
                                        const SizedBox(width: 8),
                                      ],

                                      // Add gesture detector for manual reaction testing
                                      GestureDetector(
                                        onLongPress: () {
                                          // Example: Add a reaction when long pressing
                                          sendReactionToBackend(
                                            chatId: chat.id,
                                            reaction: "👍", // Default reaction
                                            isAdding: true,
                                          );
                                        },
                                        onDoubleTap: () {
                                          // Example: Add heart reaction on double tap
                                          sendReactionToBackend(
                                            chatId: chat.id,
                                            reaction: "❤️",
                                            isAdding: true,
                                          );
                                        },
                                        child: chat_reactions.ChatMessageWrapper(
                                          messageId: chat.id.toString(),
                                          controller: _controller,
                                          config: config,
                                          onReactionAdded: (reaction) {
                                            sendReactionToBackend(
                                              chatId: chat.id,
                                              reaction: reaction,
                                              isAdding: true,
                                            );
                                          },
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              ChatBubble(
                                                isMe: isCurrentUser,
                                                color: isCurrentUser
                                                    ? PawsColors.primary
                                                    : PawsColors.border,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (!isCurrentUser &&
                                                        showAvatar)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 4,
                                                            ),
                                                        child: PawsText(
                                                          chat
                                                                  .users
                                                                  ?.username ??
                                                              'Unknown',
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: PawsColors
                                                              .primary,
                                                        ),
                                                      ),
                                                    if (chat.imageUrl != null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
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
                                                          : PawsColors
                                                                .textPrimary,
                                                    ),
                                                    const SizedBox(height: 4),

                                                    // Display existing reactions from backend
                                                    // if (chat.reactions != null &&
                                                    //     chat.reactions!.isNotEmpty)
                                                    //   _buildReactionsDisplay(
                                                    //     chat.reactions!,
                                                    //     isCurrentUser,
                                                    //     chat.id,
                                                    //   ),
                                                    PawsText(
                                                      timeago.format(
                                                        chat.sentAt,
                                                      ),
                                                      fontSize: 10,
                                                      color: isCurrentUser
                                                          ? Colors.white70
                                                          : PawsColors
                                                                .textSecondary,
                                                    ),

                                                    // Add reaction test buttons
                                                  ],
                                                ),
                                              ),
                                              if (chat.reactions != null &&
                                                  chat.reactions!.isNotEmpty)
                                                Positioned(
                                                  bottom: -16,
                                                  right: -4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: chat.reactions!.map((
                                                        reaction,
                                                      ) {
                                                        final userCount =
                                                            reaction
                                                                .users
                                                                .length;
                                                        final hasCurrentUser =
                                                            reaction.users
                                                                .contains(
                                                                  USER_ID,
                                                                );

                                                        return GestureDetector(
                                                          onTap: () {
                                                            sendReactionToBackend(
                                                              chatId: chat.id,
                                                              reaction: reaction
                                                                  .emoji,
                                                              isAdding:
                                                                  !hasCurrentUser,
                                                            );
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 1,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  hasCurrentUser
                                                                  ? PawsColors
                                                                        .primary
                                                                        .withOpacity(
                                                                          0.15,
                                                                        )
                                                                  : Colors
                                                                        .transparent,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  reaction
                                                                      .emoji,
                                                                  style:
                                                                      const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                ),
                                                                if (userCount >
                                                                    1) ...[
                                                                  const SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    userCount
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          hasCurrentUser
                                                                          ? PawsColors.primary
                                                                          : Colors.grey.shade600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      if (isCurrentUser)
                                        const SizedBox(width: 8),
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
