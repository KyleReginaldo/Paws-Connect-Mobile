import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../features/forum/models/forum_model.dart';
import '../../theme/paws_theme.dart';

class MentionableTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onSubmitted;
  final List<AvailableUser> availableUsers;
  final String? currentUserId;
  final Function(AvailableUser)? onUserMentioned;

  const MentionableTextField({
    super.key,
    required this.controller,
    this.hintText = 'Type a message',
    this.onChanged,
    this.onSubmitted,
    this.availableUsers = const [],
    this.currentUserId,
    this.onUserMentioned,
  });

  @override
  State<MentionableTextField> createState() => _MentionableTextFieldState();
}

class _MentionableTextFieldState extends State<MentionableTextField> {
  final FocusNode _focusNode = FocusNode();
  List<AvailableUser> _filteredUsers = [];
  bool _showMentionPicker = false;
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    debugPrint(
      'MentionableTextField initialized with ${widget.availableUsers.length} users',
    );
  }

  @override
  void didUpdateWidget(MentionableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableUsers.length != widget.availableUsers.length) {
      debugPrint(
        'Available users updated: ${widget.availableUsers.length} users',
      );
      for (final user in widget.availableUsers) {
        debugPrint('  - ${user.username} (${user.id})');
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.baseOffset == -1) return;

    _checkForMention(text, selection.baseOffset);
    widget.onChanged?.call(text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _hideMentionPicker();
    }
  }

  void _checkForMention(String text, int cursorPosition) {
    debugPrint(
      'Checking for mention: text="$text", cursor=$cursorPosition, availableUsers=${widget.availableUsers.length}',
    );

    // Find the last @ symbol before cursor
    int atIndex = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        break;
      }
      if (text[i] == ' ' || text[i] == '\n') {
        break; // Stop if we hit a space or newline
      }
    }

    debugPrint('Found @ at index: $atIndex');

    if (atIndex != -1) {
      // Extract the query after @
      final query = text.substring(atIndex + 1, cursorPosition).toLowerCase();
      debugPrint('Query after @: "$query"');

      // Filter users excluding current user
      final filtered = widget.availableUsers
          .where(
            (user) =>
                user.id != widget.currentUserId &&
                user.username.toLowerCase().contains(query),
          )
          .toList();

      debugPrint('Filtered users: ${filtered.length}');

      // Show users if we have any available
      if (widget.availableUsers.isNotEmpty) {
        _mentionStartIndex = atIndex;
        _filteredUsers = query.isEmpty
            ? widget.availableUsers
                  .where((user) => user.id != widget.currentUserId)
                  .toList()
            : filtered;
        _showMentionPicker = true;
        debugPrint('Setting state to show ${_filteredUsers.length} users');
        setState(() {}); // Trigger rebuild to show mention picker
      } else {
        debugPrint('No users available, hiding picker');
        _hideMentionPicker();
      }
    } else {
      _hideMentionPicker();
    }
  }

  /*
  void _showOverlay() {
    debugPrint(
      '_showOverlay called: showPicker=$_showMentionPicker, filteredUsers=${_filteredUsers.length}',
    );
    _removeOverlay();

    if (!_showMentionPicker || _filteredUsers.isEmpty) {
      debugPrint(
        'Not showing overlay: showPicker=$_showMentionPicker, filteredUsers=${_filteredUsers.length}',
      );
      return;
    }

    debugPrint('Creating overlay with ${_filteredUsers.length} users');

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 40), // Show below the text field
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PawsColors.border),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _buildUserItem(user);
                },
              ),
            ),
          ),
        ),
      ),
    );

    debugPrint('Inserting overlay into context');
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildUserItem(AvailableUser user) {
    return InkWell(
      onTap: () => _selectUser(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: user.profileImageLink != null
                  ? NetworkImage(user.profileImageLink!)
                  : null,
              child: user.profileImageLink == null
                  ? Text(
                      user.username.isNotEmpty 
                          ? user.username[0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectUser(AvailableUser user) {
    final text = widget.controller.text;
    final beforeMention = text.substring(0, _mentionStartIndex);
    final afterCursor = text.substring(widget.controller.selection.baseOffset);
    
    final newText = '$beforeMention@${user.username} $afterCursor';
    final newCursorPosition = beforeMention.length + user.username.length + 2;
    
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: newCursorPosition,
    );
    
    widget.onUserMentioned?.call(user);
    _hideMentionPicker();
    
    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }
  */
  Widget _buildMentionPicker() {
    if (!_showMentionPicker || _filteredUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _buildUserItem(user);
        },
      ),
    );
  }

  Widget _buildUserItem(AvailableUser user) {
    return InkWell(
      onTap: () => _selectUser(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: user.profileImageLink != null
                  ? NetworkImage(user.profileImageLink!)
                  : null,
              backgroundColor: PawsColors.primary.withValues(alpha: 0.1),
              child: user.profileImageLink == null
                  ? Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PawsColors.primary,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.alternate_email,
              size: 16,
              color: PawsColors.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _selectUser(AvailableUser user) {
    final text = widget.controller.text;
    final beforeMention = text.substring(0, _mentionStartIndex);
    final afterCursor = text.substring(widget.controller.selection.baseOffset);

    final newText = '$beforeMention@${user.username} $afterCursor';
    final newCursorPosition = beforeMention.length + user.username.length + 2;

    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: newCursorPosition,
    );

    widget.onUserMentioned?.call(user);
    _hideMentionPicker();

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _hideMentionPicker() {
    setState(() {
      _showMentionPicker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Beautiful mention picker
        _buildMentionPicker(),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onSubmitted: (_) => widget.onSubmitted?.call(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          ),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
