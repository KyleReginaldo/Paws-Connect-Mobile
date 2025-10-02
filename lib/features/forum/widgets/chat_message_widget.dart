import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart'
    as chat_reactions;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/components/components.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../models/forum_model.dart';

class ChatMessageWidget extends StatelessWidget {
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
    this.onReplyToTapped,
  });

  @override
  Widget build(BuildContext context) {
    int reactionCount = 0;
    chat.reactions?.forEach((reaction) {
      reactionCount += reaction.users.length;
    });

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
                    imageUrl: null,
                    initials: chat.users?.username,
                    size: 32,
                  )
                : const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (chat.repliedTo != null)
                  ReplyIndicator(
                    repliedMessage: chat.repliedTo!,
                    onTap: () => onReplyToTapped?.call(chat.repliedTo!.id),
                  ),
                chat_reactions.ChatMessageWrapper(
                  key: messageKey,
                  messageId: chat.id.toString(),
                  controller: controller,
                  config: config,
                  onReactionAdded: onReactionAdded,
                  onReactionRemoved: onReactionRemoved,
                  onMenuItemTapped: (menu) => onMenuItemTapped(menu.label),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ChatBubble(
                        isMe: isCurrentUser,
                        color: isCurrentUser
                            ? PawsColors.primary
                            : PawsColors.border,
                        child: MessageContent(
                          chat: chat,
                          isCurrentUser: isCurrentUser,
                          showAvatar: showAvatar,
                        ),
                      ),
                      if (chat.reactions != null && chat.reactions!.isNotEmpty)
                        MessageReactions(
                          reactions: chat.reactions!,
                          isCurrentUser: isCurrentUser,
                          reactionCount: reactionCount,
                          currentUserId: currentUserId,
                          onReactionTapped: (reaction, hasCurrentUser) {
                            if (hasCurrentUser) {
                              onReactionRemoved(reaction.emoji);
                            } else {
                              onReactionAdded(reaction.emoji);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
        ],
      ),
    );
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
                color: PawsColors.primary.withOpacity(0.3),
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
        PawsText(
          chat.message,
          fontSize: 14,
          color: isCurrentUser ? Colors.white : PawsColors.textPrimary,
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
      right: isCurrentUser ? 8 : null,
      left: !isCurrentUser ? 8 : null,
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
