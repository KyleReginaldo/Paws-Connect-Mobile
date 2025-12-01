// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/flavors/flavor_config.dart';
import 'package:provider/provider.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/supabase/client.dart';
import '../../../core/widgets/text.dart';
import '../provider/posts_provider.dart';
import '../repository/posts_repository.dart';

@RoutePage()
class PostsScreen extends StatefulWidget implements AutoRouteWrapper {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<PostsRepository>(),
      child: this,
    );
  }
}

class _PostsScreenState extends State<PostsScreen> {
  late ScrollController _scrollController;
  late RealtimeChannel postsChannel;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsRepository>().fetchPosts();
      listenToChanges();
    });
  }

  void listenToChanges() async {
    postsChannel = supabase.channel('public:posts');
    postsChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            context.read<PostsRepository>().fetchPosts(refresh: true);
          },
        )
        .subscribe();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final repo = context.read<PostsRepository>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (repo.hasMorePosts && !repo.isLoadingMorePosts) {
        repo.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<PostsRepository>().fetchPosts(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const PawsText(
          'Feed',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Consumer<PostsRepository>(
        builder: (context, repo, _) {
          if (repo.isLoadingPosts && repo.posts.isEmpty) {
            return const _LoadingView();
          }
          if (repo.errorMessage.isNotEmpty && repo.posts.isEmpty) {
            return _ErrorView(
              message: repo.errorMessage,
              onRetry: () => repo.fetchPosts(refresh: true),
            );
          }
          if (repo.posts.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: repo.posts.length + (repo.isLoadingMorePosts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < repo.posts.length) {
                  final post = repo.posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _PostCard(post: post),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late TextEditingController _commentController;
  String? _currentUsername;
  String? _currentProfileImage;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
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
    super.dispose();
  }

  void _handleLike() {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to like posts')),
      );
      return;
    }
    context.read<PostsRepository>().toggleReaction(
      postId: widget.post.id,
      userId: userId,
    );
  }

  void _handleComment() {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment')),
      );
      return;
    }
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    context.read<PostsRepository>().addComment(
      postId: widget.post.id,
      userId: userId,
      comment: comment,
      username: _currentUsername,
      profileImage: _currentProfileImage,
    );
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleShare() async {
    try {
      final post = widget.post;
      final title = post.title.isNotEmpty ? post.title : 'PawsConnect';
      final description = post.description;
      final links = post.links?.isNotEmpty == true
          ? '\n${post.links!.join('\n')}'
          : '';

      final shareText = '$title\n\n$description$links';

      // Use social_sharing_plus for Facebook sharing with images
      if (post.images?.isNotEmpty == true) {
        final imageUrl = post.images!.first.transformedUrl;
        await SocialSharingPlus.shareToSocialMedia(
          SocialPlatform.facebook,
          shareText,
          media: imageUrl,
          isOpenBrowser: true,
        );
      } else {
        // Fallback to text sharing if no images
        await SocialSharingPlus.shareToSocialMedia(
          SocialPlatform.facebook,
          shareText,
          isOpenBrowser: true,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Can\'t share post, please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final created = widget.post.createdAt != null
        ? DateTime.tryParse(widget.post.createdAt!)
        : null;
    final relative = created != null
        ? 'Tails of Freedom • ${timeago.format(created)}'
        : '';

    final author = 'PawsConnect';
    final caption = widget.post.description.trim();
    final images = widget.post.images ?? [];
    final userId = USER_ID;
    final hasReacted = userId != null
        ? widget.post.hasUserReacted(userId)
        : false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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

          if (images.isNotEmpty) _PostImagesCarousel(images: images),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: _ExpandableText(
              title: widget.post.title,
              description: caption,
              links: widget.post.links ?? [],
              maxLines: 3,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if ((widget.post.reactions?.length ?? 0) > 0)
                      _CountPill(
                        icon: LucideIcons.pawPrint,
                        count: widget.post.reactions!.length,
                        color: scheme.primary,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.reactions?.length ?? 0} ${(widget.post.reactions?.length ?? 0) <= 1 ? 'like' : 'likes'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${widget.post.comments?.length ?? 0} ${(widget.post.comments?.length ?? 0) <= 1 ? 'comment' : 'comments'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _IconAction(
                  icon: hasReacted
                      ? LucideIcons.pawPrint
                      : LucideIcons.pawPrint,
                  label: 'Like',
                  onTap: _handleLike,
                  isActive: hasReacted,
                ),
                _IconAction(
                  icon: LucideIcons.messageCircle,
                  label: 'Comment',
                  onTap: () {
                    context.router.push(CommentsRoute(post: widget.post));
                  },
                ),
                _IconAction(
                  icon: LucideIcons.share2,
                  label: 'Share',
                  onTap: _handleShare,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    onTap: () {
                      context.router.push(CommentsRoute(post: widget.post));
                    },
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      isDense: true,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onSubmitted: (_) => _handleComment(),
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

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isActive ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostImagesCarousel extends StatefulWidget {
  final List<String> images;
  const _PostImagesCarousel({required this.images});
  @override
  State<_PostImagesCarousel> createState() => _PostImagesCarouselState();
}

class _PostImagesCarouselState extends State<_PostImagesCarousel> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final scheme = Theme.of(context).colorScheme;
    final count = images.length;
    final height = MediaQuery.of(context).size.width * 0.4;
    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            itemCount: count,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final url = images[i];
              return Image.network(
                url.transformedUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              );
            },
          ),
        ),
        if (count > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8.0),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _PostCardSkeleton(),
      ),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  const _PostCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                const SkeletonCircle(size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 120, height: 14),
                      const SizedBox(height: 6),
                      SkeletonLine(width: 180, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image skeleton
          Container(
            height: MediaQuery.of(context).size.width * 0.4,
            color: Colors.grey[300],
          ),

          // Content skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonLine(width: double.infinity, height: 12),
                const SizedBox(height: 6),
                SkeletonLine(width: 200, height: 12),
              ],
            ),
          ),

          // Stats skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(width: 80, height: 12),
                SkeletonLine(width: 80, height: 12),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SkeletonLine(width: 60, height: 12),
                SkeletonLine(width: 80, height: 12),
                SkeletonLine(width: 60, height: 12),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comment input skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SkeletonLine(width: double.infinity, height: 36, radius: 24),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const Icon(LucideIcons.folderX, size: 64),
          PawsText(
            'No posts yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          PawsText(
            'Posts you create will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            PawsText(
              'Failed to load posts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            PawsText(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCcw),
              label: const PawsText('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  const _CountPill({
    required this.icon,
    required this.count,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
