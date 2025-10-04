import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart'
    as chat_reactions;
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  bool _isInitialLoad = true;
  List<AvailableUser> _forumMembers = [];
  bool _isLoadingUsers = false;
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupRealtimeChannel();
    _loadInitialData();
    _setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ForumRepository>().setForumById(
          widget.forumId,
          USER_ID ?? "",
        );
      }
    });
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
    _loadForumMembers();
    _markMessagesAsViewed();
  }

  Future<void> _loadForumMembers() async {
    if (_isLoadingUsers) return;

    setState(() {
      _isLoadingUsers = true;
    });

    try {
      debugPrint('Loading forum members for forumId: ${widget.forumId}');
      final result = await ForumProvider().fetchForumMembers(widget.forumId);

      if (result.isSuccess && mounted) {
        debugPrint('Forum members loaded: ${result.value.length} members');
        for (final member in result.value) {
          debugPrint('Member: ${member.username} (${member.id})');
        }
        setState(() {});
      } else {
        debugPrint('Failed to load forum members: ${result.error}');
      }
    } catch (e) {
      debugPrint('Exception loading forum members: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
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

  void _markNewMessagesAsViewed() {
    // Use a slight delay to ensure the new messages are loaded first
    Future.delayed(const Duration(milliseconds: 500), () {
      final userId = USER_ID;
      if (mounted && userId != null && userId.isNotEmpty) {
        try {
          sl<CommonRepository>().markMessagesViewed(
            userId: userId,
            forumId: widget.forumId,
          );
        } catch (e) {
          debugPrint('Failed to mark new messages viewed: $e');
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
              // Refresh the chat list
              context.read<ForumRepository>().setForumChats(widget.forumId);
              // Auto-mark new messages as viewed when they come in via realtime
              _markNewMessagesAsViewed();
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

  Future<bool> _ensureMessageLoaded(int messageId) async {
    final repo = context.read<ForumRepository>();
    const maxAttempts = 10;
    var attempts = 0;

    while (!repo.forumChats.any((chat) => chat.id == messageId)) {
      if (!repo.hasMoreChats) {
        return false;
      }

      if (!repo.isLoadingMoreChats) {
        await repo.loadMoreChats(widget.forumId);
      } else {
        await Future.delayed(const Duration(milliseconds: 120));
      }

      attempts++;
      if (attempts >= maxAttempts) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 60));
    }

    if (!repo.forumChats.any((chat) => chat.id == messageId)) {
      return false;
    }

    if (mounted) {
      await WidgetsBinding.instance.endOfFrame;
    }

    return true;
  }

  Future<bool> _scrollToMessageById(int messageId) async {
    if (!_scrollController.hasClients) return false;

    final repo = context.read<ForumRepository>();
    final forumChats = repo.forumChats;

    final messageIndex = forumChats.indexWhere((chat) => chat.id == messageId);

    if (messageIndex == -1) {
      return false;
    }

    final totalMessages = forumChats.length;
    final reversedIndex = totalMessages - 1 - messageIndex;
    final approximateItemHeight = 80.0;
    var targetPosition = reversedIndex * approximateItemHeight;

    if (_scrollController.position.hasPixels) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      targetPosition = targetPosition.clamp(0.0, maxExtent);
    }

    debugPrint(
      'Scrolling to approximate position: $targetPosition for message at index $messageIndex',
    );

    await _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    for (var attempt = 0; attempt < 6; attempt++) {
      await WidgetsBinding.instance.endOfFrame;

      final key = _chatKeys[messageId.toString()];
      final keyContext = key?.currentContext;
      if (keyContext != null && mounted) {
        await Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
        return true;
      }

      await Future.delayed(const Duration(milliseconds: 80));
    }

    debugPrint('Widget still not visible after scrolling attempts');
    return false;
  }

  Future<void> _handleReplyToTapped(int messageId) async {
    debugPrint('Attempting to scroll to replied message: $messageId');

    final isLoaded = await _ensureMessageLoaded(messageId);

    if (!mounted) return;

    if (!isLoaded) {
      debugPrint(
        'Message with ID $messageId not loaded or no longer available',
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message not found or not loaded yet'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final scrolled = await _scrollToMessageById(messageId);

    if (!mounted) return;

    if (!scrolled) {
      // ignore: use_build_context_synchronously
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

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Check if user scrolled to the top (which means they want to load older messages)
      // Since the list is reversed, top means maximum scroll extent
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent * 0.9) {
        _loadMoreChatsIfNeeded();
      }
    });
  }

  void _loadMoreChatsIfNeeded() {
    if (!mounted) return;
    final repo = context.read<ForumRepository>();
    if (repo.hasMoreChats && !repo.isLoadingMoreChats) {
      repo.loadMoreChats(widget.forumId);
    }
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
    if (forumChats.length == _previousMessageCount) return;

    final shouldScrollToBottom = _isInitialLoad && forumChats.isNotEmpty;
    _previousMessageCount = forumChats.length;

    if (shouldScrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    }

    if (forumChats.isNotEmpty) {
      _isInitialLoad = false;
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
    final mentionUUIDs = _extractMentionsFromMessage(message);

    // Log mentions for debugging
    if (mentionUUIDs.isNotEmpty) {
      debugPrint('Message contains mention UUIDs: $mentionUUIDs');
      // Also log the usernames for easier debugging
      final mentionedUsernames = RegExp(
        r'@(\w+)',
      ).allMatches(message).map((match) => match.group(1)!).toList();
      debugPrint('Mentioned usernames: $mentionedUsernames');
    }

    _messageController.clear();

    // Add to pending messages immediately for better UX
    context.read<ForumRepository>().addPendingChat(message);
    _scrollToBottom();

    setState(() {
      _isSendingMessage = true;
    });
    _markMessagesAsViewed();
    _performSendMessage(message);
  }

  Future<void> _performSendMessage(String message) async {
    try {
      // Extract mentions from the message using the MentionParser
      final mentions = _extractMentionsFromMessage(message);

      await ForumProvider().sendChat(
        sender: USER_ID ?? '',
        message: message,
        forumId: widget.forumId,
        imageFile: _imageFile,
        repliedTo: replyTo?.id,
        mentions: mentions.isNotEmpty ? mentions : null,
      );

      _handleSendSuccess();
    } catch (e) {
      _handleSendError(e, message);
    }
  }

  List<String> _extractMentionsFromMessage(String message) {
    // Use regex to find all @mentions in the message
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(message);

    // Extract usernames from mentions
    final mentionedUsernames = matches.map((match) => match.group(1)!).toList();

    // Convert usernames to UUIDs using forum members list
    final mentionedUUIDs = <String>[];
    for (final username in mentionedUsernames) {
      final user = _forumMembers.firstWhere(
        (user) => user.username == username,
        orElse: () => AvailableUser(id: '', username: ''),
      );
      if (user.id.isNotEmpty) {
        mentionedUUIDs.add(user.id);
      }
    }

    return mentionedUUIDs;
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

  Future<void> removeChat({required int chatId}) async {
    final result = await ForumProvider().removeChat(
      chatId: chatId,
      forumId: widget.forumId,
      sender: USER_ID ?? '',
    );
    if (result.isError) {
      EasyLoading.showError(result.error);
    } else {
      if (mounted) {
        context.read<ForumRepository>().setForumChats(widget.forumId);
      }
    }
  }

  final Map<String, GlobalKey> _chatKeys = {};

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ForumRepository>();
    final forumChats = repo.forumChats;
    final isLoadingChats = repo.isLoadingChats;
    final isLoadingMoreChats = repo.isLoadingMoreChats;
    final pendingChats = repo.pendingChats;
    final forum = repo.forum;
    _forumMembers = (forum?.members ?? []).map((e) {
      return AvailableUser(id: e.id, username: e.username);
    }).toList();
    if (forumChats.isNotEmpty) {
      _processMessages(forumChats);
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(
          forumChats,
          pendingChats,
          isLoadingChats,
          isLoadingMoreChats,
        ),
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
    bool isLoadingMoreChats,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildMessageList(
            forumChats,
            pendingChats,
            isLoadingChats,
            isLoadingMoreChats,
          ),
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
    bool isLoadingMoreChats,
  ) {
    return ChatMessageList(
      forumChats: forumChats,
      pendingChats: pendingChats,
      isLoadingChats: isLoadingChats,
      isLoadingMoreChats: isLoadingMoreChats,
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
      availableUsers: _forumMembers,
      currentUserId: USER_ID,
      onUserMentioned: (user) {
        debugPrint('User mentioned: ${user.username}');
        HapticFeedback.lightImpact();
      },
    );
  }

  void _handleMenuAction(String menuLabel, ForumChat chat) {
    debugPrint('Menu tapped: $menuLabel');
    if (menuLabel == 'Reply') {
      setState(() {
        replyTo = chat;
      });
    }
    if (menuLabel == 'Delete') {
      removeChat(chatId: chat.id);
    }
  }
}
