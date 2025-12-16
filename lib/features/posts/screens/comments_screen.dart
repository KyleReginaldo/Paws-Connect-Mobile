import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/image_carousel.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/posts/provider/posts_provider.dart';
import 'package:paws_connect/features/posts/repository/posts_repository.dart';
import 'package:paws_connect/flavors/flavor_config.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class CommentsScreen extends StatefulWidget implements AutoRouteWrapper {
  const CommentsScreen({super.key, required this.post});

  final Post post;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<PostsRepository>(),
      child: this,
    );
  }
}

class _CommentsScreenState extends State<CommentsScreen> {
  late TextEditingController _commentController;
  late FocusNode _focusNode;
  bool _isSubmitting = false;
  String? _currentUsername;
  String? _currentProfileImage;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _focusNode = FocusNode();
    _fetchCurrentUserInfo();
  }

  Future<void> _fetchCurrentUserInfo() async {
    final userId = USER_ID;
    if (userId == null) return;

    try {
      final result = await supabase
          .from('users')
          .select('username, profile_image_link')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _currentUsername = result['username'] as String?;
          _currentProfileImage = result['profile_image_link'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitComment() async {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment')),
      );
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await sl<PostsRepository>().addComment(
        postId: widget.post.id,
        userId: userId,
        comment: comment,
        username: _currentUsername,
        profileImage: _currentProfileImage,
      );
      _commentController.clear();
      _focusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const PawsText(
          'Comments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PostsRepository>(
              builder: (context, repo, _) {
                // Find the updated post from repository
                final updatedPost = repo.posts.firstWhere(
                  (p) => p.id == widget.post.id,
                  orElse: () => widget.post,
                );
                final comments = updatedPost.comments ?? [];

                return CustomScrollView(
                  slivers: [
                    // Post preview card
                    SliverToBoxAdapter(child: _PostPreview(post: widget.post)),
                    // Comments list or empty view
                    if (comments.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyCommentsView(),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final comment = comments[index];
                          return _CommentItem(
                            comment: comment,
                            commentIndex: index,
                            postId: updatedPost.id,
                          );
                        }, childCount: comments.length),
                      ),
                  ],
                );
              },
            ),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: scheme.outlineVariant, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _currentProfileImage != null
                      ? CircleAvatar(
                          radius: 18,
                          backgroundImage: CachedNetworkImageProvider(
                            _currentProfileImage!.transformedUrl,
                          ),
                        )
                      : CircleAvatar(
                          radius: 18,
                          backgroundColor: scheme.surfaceContainerHighest,
                          child: const Icon(Icons.person, size: 18),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      maxLines: null,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: scheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: scheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: scheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _handleSubmitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _handleSubmitComment,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          )
                        : Icon(LucideIcons.send, color: scheme.primary),
                    tooltip: 'Send',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostPreview extends StatelessWidget {
  final Post post;
  const _PostPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final created = post.createdAt != null
        ? DateTime.tryParse(post.createdAt!)
        : null;
    final relative = created != null
        ? 'Humanity for Animals • ${timeago.format(created)}'
        : '';
    final author = 'PawsConnect';
    final caption = post.description.trim();
    final images = post.images ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                ClipOval(
                  child: NetworkImageView(
                    FlavorConfig.instance.logoUrl,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relative,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (images.isNotEmpty) ImageCarousel(images: images),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: _ExpandableText(
              title: post.title,
              description: caption,
              links: post.links ?? [],
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final int commentIndex;
  final int postId;

  const _CommentItem({
    required this.comment,
    required this.commentIndex,
    required this.postId,
  });

  Future<void> _handleDeleteComment(BuildContext context) async {
    final userId = comment['user_id'] as String?;
    final currentUserId = USER_ID;

    // Only allow deletion if it's the user's own comment
    if (userId != currentUserId) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await sl<PostsRepository>().deleteComment(
        postId: postId,
        commentIndex: commentIndex,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final username = comment['username'] as String? ?? 'Unknown User';
    final profileImage = comment['profile_image'] as String?;
    final commentText = comment['comment'] as String? ?? '';
    final createdAt = comment['created_at'] as String?;
    final userId = comment['user_id'] as String?;
    final currentUserId = USER_ID;
    final isOwnComment = userId == currentUserId;
    final relative = createdAt != null
        ? timeago.format(DateTime.parse(createdAt))
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileImage != null
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    profileImage.transformedUrl,
                  ),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isOwnComment)
                            InkWell(
                              onTap: () => _handleDeleteComment(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  LucideIcons.trash2,
                                  size: 16,
                                  color: scheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(commentText, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (relative.isNotEmpty)
                  Text(
                    relative,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Removed: Now using ImageCarousel from core/widgets

class _ExpandableText extends StatefulWidget {
  final String title;
  final String description;
  final List<String> links;
  final int maxLines;
  const _ExpandableText({
    required this.title,
    required this.description,
    required this.links,
    required this.maxLines,
  });
  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: RichText(
        maxLines: _expanded ? null : widget.maxLines,
        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            height: 1.4,
          ),
          children: [
            // Title (Author name)
            TextSpan(
              text: widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            // Space after title
            const TextSpan(text: ' '),
            // Description
            TextSpan(
              text: widget.description,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            // Links (if present)
            if (widget.links.isNotEmpty) ...{
              const TextSpan(text: '\n'),
              for (var link in widget.links) ...[
                TextSpan(
                  text: link,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(link));
                    },
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                if (link != widget.links.last) const TextSpan(text: '\n'),
              ],
            },
          ],
        ),
      ),
    );
  }
}

class _EmptyCommentsView extends StatelessWidget {
  const _EmptyCommentsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(
            LucideIcons.messageCircle,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          PawsText(
            'No comments yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          PawsText(
            'Be the first to comment!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
