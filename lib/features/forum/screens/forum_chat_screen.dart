import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart'
    as chat_reactions;
import 'package:image_picker/image_picker.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/components/components.dart';
import '../../../core/repository/common_repository.dart';
import '../../../core/router/app_route.gr.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../models/forum_model.dart';
import '../repository/forum_repository.dart';
import '../widgets/chat_message_list.dart';

/// Forum chat screen that displays real-time messages and reactions.
///
/// Features:
/// - Real-time message synchronization
/// - Reaction system with haptic feedback
/// - Message navigation and replies
/// - Image sharing capabilities
/// - GlobalKey-based message navigation
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
  ForumChat? replyTo;
  XFile? _imageFile;
  int _previousMessageCount = 0;
  late RealtimeChannel chatChannel;
  bool _isSendingMessage = false;
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupRealtimeChannel();
    _loadInitialData();
  }

  void _initializeControllers() {
    _controller = chat_reactions.ReactionsController(
      currentUserId: USER_ID ?? '',
    );
    _controller.addListener(_onReactionChanged);
  }

  void _setupRealtimeChannel() {
    chatChannel = supabase.channel(
      'public:forum_chats:forum=eq.${widget.forumId}',
    );
    listenToChanges();
  }

  void _loadInitialData() {
    _loadChats();
    _markMessagesAsViewed();
  }

  void _markMessagesAsViewed() {
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
            if (mounted) {
              context.read<ForumRepository>().setForumChats(widget.forumId);
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    chatChannel.unsubscribe();
    _controller.removeListener(_onReactionChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _scrollToMessageById(int messageId) async {
    final repo = context.read<ForumRepository>();
    final forumChats = repo.forumChats;

    final messageIndex = forumChats.indexWhere((chat) => chat.id == messageId);

    if (messageIndex == -1) {
      debugPrint('Message with ID $messageId not found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message not found'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final totalMessages = forumChats.length;
    final reversedIndex = totalMessages - 1 - messageIndex;
    final approximateItemHeight = 80.0;
    final targetPosition = reversedIndex * approximateItemHeight;

    debugPrint(
      'Scrolling to approximate position: $targetPosition for message at index $messageIndex',
    );

    await _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      final key = _chatKeys[messageId.toString()];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      } else {
        debugPrint('Widget still not visible after scrolling');
      }
    });
  }

  void _handleReplyToTapped(int messageId) {
    debugPrint('keys: ${_chatKeys.keys}');

    final key = _chatKeys[messageId.toString()];
    debugPrint('Replied to: $messageId');
    debugPrint('Key: $key');
    debugPrint('Available keys: ${_chatKeys.keys.toList()}');

    if (key != null) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      } else {
        debugPrint('Widget not visible, scrolling to approximate position');
        _scrollToMessageById(messageId);
      }
    } else {
      debugPrint('Key not found for message ID: $messageId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message not found or not loaded yet'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onReactionChanged() {
    debugPrint('Reactions updated');
  }

  Future<void> sendReactionToBackend({
    required int chatId,
    required String reaction,
    required bool isAdding,
  }) async {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) return;

    try {
      final provider = ForumProvider();
      final result = isAdding
          ? await provider.addReaction(
              forumId: widget.forumId,
              chatId: chatId,
              reaction: reaction,
              userId: userId,
            )
          : await provider.removeReaction(
              forumId: widget.forumId,
              chatId: chatId,
              reaction: reaction,
              userId: userId,
            );

      if (result.isError) {
        _handleReactionError(isAdding, result.error);
      } else {
        _handleReactionSuccess(isAdding, reaction);
      }
    } catch (e) {
      debugPrint('Error sending reaction to backend: $e');
    }
  }

  void _handleReactionError(bool isAdding, dynamic error) {
    debugPrint('Failed to ${isAdding ? 'add' : 'remove'} reaction: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${isAdding ? 'add' : 'remove'} reaction'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleReactionSuccess(bool isAdding, String reaction) {
    debugPrint(
      'Successfully ${isAdding ? 'added' : 'removed'} reaction: $reaction',
    );
    if (mounted) {
      context.read<ForumRepository>().setForumChats(widget.forumId);
    }
  }

  Map<String, List<String>> _convertReactions(List<Reaction>? reactions) {
    if (reactions == null || reactions.isEmpty) return {};

    final Map<String, List<String>> result = {};
    for (final reaction in reactions) {
      result[reaction.emoji] = reaction.users;
    }
    return result;
  }

  void _initializeReactions(List<ForumChat> chats) {
    for (final chat in chats) {
      if (chat.reactions != null && chat.reactions!.isNotEmpty) {
        final reactions = _convertReactions(chat.reactions);
        _addReactionsToController(chat.id.toString(), reactions);
      }
    }
  }

  void _addReactionsToController(
    String chatId,
    Map<String, List<String>> reactions,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        for (final entry in reactions.entries) {
          _controller.addReaction(chatId, entry.key);
        }
      }
    });
  }

  void _processMessages(List<ForumChat> forumChats) {
    _initializeMessageKeys(forumChats);
    _initializeReactions(forumChats);
    _updateMessageCount(forumChats);
  }

  void _initializeMessageKeys(List<ForumChat> forumChats) {
    for (ForumChat chat in forumChats) {
      _chatKeys.putIfAbsent(chat.id.toString(), () {
        debugPrint('Creating GlobalKey for message ID: ${chat.id}');
        return GlobalKey();
      });
    }
  }

  void _updateMessageCount(List<ForumChat> forumChats) {
    if (forumChats.length != _previousMessageCount) {
      _previousMessageCount = forumChats.length;
      if (forumChats.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom();
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
    if (_messageController.text.trim().isEmpty || _isSendingMessage) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Add to pending messages immediately for better UX
    context.read<ForumRepository>().addPendingChat(message);
    _scrollToBottom();

    setState(() {
      _isSendingMessage = true;
    });

    _performSendMessage(message);
  }

  Future<void> _performSendMessage(String message) async {
    try {
      await ForumProvider().sendChat(
        sender: USER_ID ?? '',
        message: message,
        forumId: widget.forumId,
        imageFile: _imageFile,
        repliedTo: replyTo?.id,
      );

      _handleSendSuccess();
    } catch (e) {
      _handleSendError(e, message);
    }
  }

  void _handleSendSuccess() {
    if (mounted) {
      setState(() {
        _imageFile = null;
        _isSendingMessage = false;
        replyTo = null;
      });
      context.read<ForumRepository>().setForumChats(widget.forumId);
    }
  }

  void _handleSendError(dynamic error, String message) {
    debugPrint('Failed to send message: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Restore the message in the text field
      _messageController.text = message;

      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  final Map<String, GlobalKey> _chatKeys = {};

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ForumRepository>();
    final forumChats = repo.forumChats;
    final isLoadingChats = repo.isLoadingChats;
    final pendingChats = repo.pendingChats;

    if (forumChats.isNotEmpty) {
      _processMessages(forumChats);
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(forumChats, pendingChats, isLoadingChats),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          onPressed: () =>
              context.router.push(ForumSettingsRoute(forumId: widget.forumId)),
          icon: const Icon(Icons.info),
          color: PawsColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildBody(
    List<ForumChat> forumChats,
    List<String> pendingChats,
    bool isLoadingChats,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildMessageList(forumChats, pendingChats, isLoadingChats),
        ),
        if (replyTo != null) _buildReplyIndicator(),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageList(
    List<ForumChat> forumChats,
    List<String> pendingChats,
    bool isLoadingChats,
  ) {
    return ChatMessageList(
      forumChats: forumChats,
      pendingChats: pendingChats,
      isLoadingChats: isLoadingChats,
      scrollController: _scrollController,
      chatKeys: _chatKeys,
      reactionsController: _controller,
      reactionsConfig: chat_reactions.ChatReactionsConfig(
        enableHapticFeedback: true,
        maxReactionsToShow: 3,
        enableDoubleTap: true,
      ),
      currentUserId: USER_ID,
      onRefresh: _loadChats,
      onReactionAdded: (reaction, chatId) => sendReactionToBackend(
        chatId: chatId,
        reaction: reaction,
        isAdding: true,
      ),
      onReactionRemoved: (reaction, chatId) => sendReactionToBackend(
        chatId: chatId,
        reaction: reaction,
        isAdding: false,
      ),
      onMenuItemTapped: _handleMenuAction,
      onLongPress: (chatId) =>
          sendReactionToBackend(chatId: chatId, reaction: "👍", isAdding: true),
      onDoubleTap: (chatId) =>
          sendReactionToBackend(chatId: chatId, reaction: "❤️", isAdding: true),
      onReplyToTapped: _handleReplyToTapped,
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: PawsColors.border,
        border: const Border(
          top: BorderSide(color: PawsColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PawsText(
            'Replying to:',
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          PawsText(replyTo!.message, fontSize: 16),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return MessageInputBar(
      controller: _messageController,
      isSending: _isSendingMessage,
      onPickImage: _pickImage,
      onSend: _sendMessage,
      previewImage: _imageFile != null ? File(_imageFile!.path) : null,
      onRemovePreview: () => setState(() => _imageFile = null),
    );
  }

  void _handleMenuAction(String menuLabel, ForumChat chat) {
    debugPrint('Menu tapped: $menuLabel');
    if (menuLabel == 'Reply') {
      setState(() {
        replyTo = chat;
      });
    }
  }
}
