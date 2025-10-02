import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart'
    as chat_reactions;

import '../../../core/components/components.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../models/forum_model.dart';
import 'chat_message_widget.dart';

class ChatMessageList extends StatelessWidget {
  final List<ForumChat> forumChats;
  final List<String> pendingChats;
  final bool isLoadingChats;
  final ScrollController scrollController;
  final Map<String, GlobalKey> chatKeys;
  final chat_reactions.ReactionsController reactionsController;
  final chat_reactions.ChatReactionsConfig reactionsConfig;
  final String? currentUserId;
  final VoidCallback onRefresh;
  final Function(String reaction, int chatId) onReactionAdded;
  final Function(String reaction, int chatId) onReactionRemoved;
  final Function(String menuLabel, ForumChat chat) onMenuItemTapped;
  final Function(int chatId) onLongPress;
  final Function(int chatId) onDoubleTap;
  final Function(int messageId) onReplyToTapped;

  const ChatMessageList({
    super.key,
    required this.forumChats,
    required this.pendingChats,
    required this.isLoadingChats,
    required this.scrollController,
    required this.chatKeys,
    required this.reactionsController,
    required this.reactionsConfig,
    required this.currentUserId,
    required this.onRefresh,
    required this.onReactionAdded,
    required this.onReactionRemoved,
    required this.onMenuItemTapped,
    required this.onLongPress,
    required this.onDoubleTap,
    required this.onReplyToTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingChats && forumChats.isEmpty) {
      return ListView.builder(
        reverse: true,
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => _buildSkeletonMessage(context, index),
      );
    }

    if (forumChats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
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
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Builder(
        builder: (context) {
          final combined = <dynamic>[];
          combined.addAll(forumChats);
          combined.addAll(pendingChats);

          if (combined.isEmpty) {
            return const SizedBox.shrink();
          }

          return ListView.builder(
            controller: scrollController,
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: combined.length,
            itemBuilder: (context, index) {
              final reversedIndex = combined.length - 1 - index;
              final item = combined[reversedIndex];

              if (item is ForumChat) {
                return _buildChatMessage(context, item, reversedIndex);
              }

              // Pending message
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
    );
  }

  Widget _buildChatMessage(
    BuildContext context,
    ForumChat chat,
    int reversedIndex,
  ) {
    // Ensure key exists for this message
    chatKeys.putIfAbsent(chat.id.toString(), () => GlobalKey());

    final isCurrentUser = chat.users?.id == currentUserId;
    final showAvatar =
        reversedIndex == forumChats.length - 1 ||
        (reversedIndex + 1 < forumChats.length
            ? forumChats[reversedIndex + 1].users?.id != chat.users?.id
            : true);

    return ChatMessageWidget(
      chat: chat,
      isCurrentUser: isCurrentUser,
      showAvatar: showAvatar,
      messageKey: chatKeys[chat.id.toString()],
      controller: reactionsController,
      config: reactionsConfig,
      currentUserId: currentUserId,
      onReactionAdded: (reaction) => onReactionAdded(reaction, chat.id),
      onReactionRemoved: (reaction) => onReactionRemoved(reaction, chat.id),
      onMenuItemTapped: (menuLabel) => onMenuItemTapped(menuLabel, chat),
      onLongPress: () => onLongPress(chat.id),
      onDoubleTap: () => onDoubleTap(chat.id),
      onReplyToTapped: onReplyToTapped,
    );
  }

  Widget _buildSkeletonMessage(BuildContext context, int index) {
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
