import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart'
    as chat_reactions;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/components/components.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/utils/mention_parser.dart';
import '../../../core/widgets/text.dart';
import '../models/forum_model.dart';

class ChatMessageWidget extends StatefulWidget {
  final ForumChat chat;
  final bool isCurrentUser;
  final bool showAvatar;
  final GlobalKey? messageKey;
  final chat_reactions.ReactionsController controller;
  final chat_reactions.ChatReactionsConfig config;
  final Function(String reaction) onReactionAdded;
  final Function(String reaction) onReactionRemoved;
  final Function(String menuLabel) onMenuItemTapped;
  final Function() onLongPress;
  final Function() onDoubleTap;
  final Function(int messageId)? onReplyToTapped;
  final String? currentUserId;
  final List<ForumChat> allChats; // Add this to filter viewers properly

  const ChatMessageWidget({
    super.key,
    required this.chat,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.messageKey,
    required this.controller,
    required this.config,
    required this.onReactionAdded,
    required this.onReactionRemoved,
    required this.onMenuItemTapped,
    required this.onLongPress,
    required this.onDoubleTap,
    required this.currentUserId,
    required this.allChats, // Add this parameter
    this.onReplyToTapped,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> with AutomaticKeepAliveClientMixin {
  List<Viewer>? _cachedViewers;
  String? _lastAllChatsHash;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    int reactionCount = 0;
    widget.chat.reactions?.forEach((reaction) {
      reactionCount += reaction.users.length;
    });

    final filteredViewers = _getViewersForMessageCached();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: widget.isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isCurrentUser) ...[
                widget.showAvatar
                    ? Stack(
                        children: [
                          UserAvatar(
                            imageUrl: widget.chat.users?.profileImageLink,
                            initials: widget.chat.users?.username,
                            size: 32,
                            borderColor: widget.chat.users?.isActive ?? false
                                ? Colors.green
                                : Colors.grey,
                            borderWidth: 2,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor: widget.chat.users?.isActive ?? false
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(width: 32),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onLongPress: widget.onLongPress,
                onDoubleTap: widget.onDoubleTap,
                child: Column(
                  crossAxisAlignment: widget.isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (widget.chat.repliedTo != null)
                      ReplyIndicator(
                        repliedMessage: widget.chat.repliedTo!,
                        onTap: () => widget.onReplyToTapped?.call(widget.chat.repliedTo!.id),
                      ),
                    chat_reactions.ChatMessageWrapper(
                      key: widget.messageKey,
                      messageId: widget.chat.id.toString(),
                      controller: widget.controller,
                      config: widget.config,
                      onReactionAdded: widget.onReactionAdded,
                      onReactionRemoved: widget.onReactionRemoved,
                      onMenuItemTapped: (menu) => widget.onMenuItemTapped(menu.label),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ChatBubble(
                            isMe: widget.isCurrentUser,
                            color: widget.isCurrentUser
                                ? PawsColors.primary
                                : PawsColors.border,
                            messageWarning: widget.chat.messageWarning,
                            child: MessageContent(
                              chat: widget.chat,
                              isCurrentUser: widget.isCurrentUser,
                              showAvatar: widget.showAvatar,
                            ),
                          ),

                          if (widget.chat.reactions != null &&
                              widget.chat.reactions!.isNotEmpty)
                            MessageReactions(
                              reactions: widget.chat.reactions!,
                              isCurrentUser: widget.isCurrentUser,
                              reactionCount: reactionCount,
                              currentUserId: widget.currentUserId,
                              onReactionTapped: (reaction, hasCurrentUser) {
                                if (hasCurrentUser) {
                                  widget.onReactionRemoved(reaction.emoji);
                                } else {
                                  widget.onReactionAdded(reaction.emoji);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isCurrentUser) const SizedBox(width: 8),
            ],
          ),
          if (filteredViewers.isNotEmpty) ...{
            SizedBox(height: 8),
            Container(
              margin: widget.isCurrentUser
                  ? const EdgeInsets.only(right: 8)
                  : const EdgeInsets.only(left: 40),
              height: 24,
              child: Builder(
                builder: (context) {
                  // Ensure unique viewers by id to avoid duplicate keys
                  final uniqueViewers = <Viewer>[];
                  final seenIds = <String>{};
                  for (final v in filteredViewers) {
                    if (!seenIds.contains(v.id)) {
                      uniqueViewers.add(v);
                      seenIds.add(v.id);
                    }
                  }

                  final width = uniqueViewers.length >= 5
                      ? (24 * 5).toDouble()
                      : (24 * uniqueViewers.length).toDouble();

                  return SizedBox(
                    width: width,
                    child: WidgetStack(
                      positions: RestrictedPositions(
                        align: widget.isCurrentUser
                            ? StackAlign.right
                            : StackAlign.left,
                        maxCoverage: (uniqueViewers.length > 5) ? 0.7 : 0.9,
                      ),
                      buildInfoWidget: (context, surplus) {
                        // We don't want a "+N" pill, so render nothing when overflowing
                        return const SizedBox.shrink();
                      },
                      stackedWidgets: uniqueViewers.map((viewer) {
                        final hasImage =
                            viewer.profileImage != null &&
                            viewer.profileImage!.isNotEmpty;
                        debugPrint('image url: ${viewer.profileImage}');
                        return Container(
                          key: ValueKey('viewer-${viewer.id}'),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PawsColors.primary,
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: hasImage
                              ? ClipOval(
                                  child: Image.network(
                                    viewer.profileImage!.transformedUrl,
                                    fit: BoxFit.cover,
                                    // Add loading optimization
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const SizedBox(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/user.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/user.png',
                                  fit: BoxFit.cover,
                                ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          },
        ],
      ),
    );
  }

  /// Cached version of _getViewersForMessage to avoid recalculation
  List<Viewer> _getViewersForMessageCached() {
    final currentHash = widget.allChats.map((c) => '${c.id}-${c.viewers?.length ?? 0}').join(',');
    
    if (_lastAllChatsHash != currentHash) {
      _lastAllChatsHash = currentHash;
      _cachedViewers = _getViewersForMessage();
    }
    
    return _cachedViewers ?? [];
  }

  /// Filter viewers to show only those who have seen up to this message but not beyond
  /// This creates the Messenger-like behavior where each viewer's avatar appears
  /// only on the last message they've seen
  List<Viewer> _getViewersForMessage() {
    if (widget.chat.viewers == null || widget.chat.viewers!.isEmpty) {
      return [];
    }

    final List<Viewer> result = [];

    // Sort chats by timestamp (newest first, which is how they're usually ordered)
    final sortedChats = List<ForumChat>.from(widget.allChats)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

    // Find the index of current message
    final currentMessageIndex = sortedChats.indexWhere((c) => c.id == widget.chat.id);
    if (currentMessageIndex == -1) return [];

    // For each viewer of the current message, check if they appear in any newer message
    for (final viewer in widget.chat.viewers!) {
      bool appearsInNewerMessage = false;

      // Check all messages newer than current message (lower index means newer)
      for (int i = 0; i < currentMessageIndex; i++) {
        final newerChat = sortedChats[i];
        if (newerChat.viewers != null &&
            newerChat.viewers!.any((v) => v.id == viewer.id)) {
          appearsInNewerMessage = true;
          break;
        }
      }

      // Only add viewer if they don't appear in any newer message
      if (!appearsInNewerMessage) {
        result.add(viewer);
      }
    }

    return result;
  }
}

class ReplyIndicator extends StatelessWidget {
  final ForumChat repliedMessage;
  final VoidCallback? onTap;

  const ReplyIndicator({super.key, required this.repliedMessage, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.cornerUpLeft,
              size: 13,
              color: PawsColors.textSecondary,
            ),
            PawsText(
              'Replied to',
              fontSize: 13,
              color: PawsColors.textSecondary,
            ),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.2,
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: PawsColors.border,
              border: Border.all(
                color: PawsColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: PawsText(repliedMessage.message, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class MessageContent extends StatelessWidget {
  final ForumChat chat;
  final bool isCurrentUser;
  final bool showAvatar;

  const MessageContent({
    super.key,
    required this.chat,
    required this.isCurrentUser,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCurrentUser && showAvatar)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: PawsText(
              chat.users?.username ?? 'Unknown',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PawsColors.primary,
            ),
          ),
        if (chat.imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NetworkImageView(
              chat.imageUrl!,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        if (chat.message != 'Sent an image')
          RichText(
            text: MentionParser.parseMessage(
              text: chat.message,
              baseStyle: TextStyle(
                fontSize: 14,
                color: isCurrentUser ? Colors.white : PawsColors.textPrimary,
              ),
              mentionColor: isCurrentUser ? Colors.white : Colors.black,
              onMentionTapped: (username) {
                // Handle mention tap - could show user profile or scroll to their message
                debugPrint('Mentioned user tapped: $username');
              },
            ),
          ),
        const SizedBox(height: 4),
        PawsText(
          timeago.format(chat.sentAt),
          fontSize: 10,
          color: isCurrentUser ? Colors.white70 : PawsColors.textSecondary,
        ),
      ],
    );
  }
}

class MessageReactions extends StatelessWidget {
  final List<Reaction> reactions;
  final bool isCurrentUser;
  final int reactionCount;
  final String? currentUserId;
  final Function(Reaction reaction, bool hasCurrentUser) onReactionTapped;

  const MessageReactions({
    super.key,
    required this.reactions,
    required this.isCurrentUser,
    required this.reactionCount,
    required this.currentUserId,
    required this.onReactionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -8,
      left: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: PawsColors.textSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...reactions.take(3).map((reaction) {
              final hasCurrentUser = reaction.users.contains(currentUserId);
              return GestureDetector(
                onTap: () => onReactionTapped(reaction, hasCurrentUser),
                child: Text(
                  reaction.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }),
            PawsText(
              reactionCount.toString(),
              fontSize: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
