import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/widgets/state_views.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/posts/provider/posts_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class ReactionsScreen extends StatefulWidget {
  const ReactionsScreen({super.key, required this.post});

  final Post post;

  @override
  State<ReactionsScreen> createState() => _ReactionsScreenState();
}

class _ReactionsScreenState extends State<ReactionsScreen> {
  List<ReactionUser>? _reactionUsers;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReactionUsers();
  }

  Future<void> _fetchReactionUsers() async {
    if (widget.post.reactions == null || widget.post.reactions!.isEmpty) {
      setState(() {
        _reactionUsers = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userIds = widget.post.reactions!
          .map((r) => r['user_id'] as String)
          .toList();

      final response = await supabase
          .from('users')
          .select('id, username, profile_image_link')
          .inFilter('id', userIds);

      final users = <ReactionUser>[];
      for (final reaction in widget.post.reactions!) {
        final userId = reaction['user_id'] as String;
        final createdAt = reaction['created_at'] as String;

        final userData = response.firstWhere(
          (user) => user['id'] == userId,
          orElse: () => {
            'id': userId,
            'username': 'Unknown User',
            'profile_image_link': null,
          },
        );

        users.add(
          ReactionUser(
            userId: userId,
            username: userData['username'] as String? ?? 'Unknown User',
            profileImage: userData['profile_image_link'] as String?,
            reactedAt: DateTime.parse(createdAt),
          ),
        );
      }

      // Sort by most recent reaction first
      users.sort((a, b) => b.reactedAt.compareTo(a.reactedAt));

      setState(() {
        _reactionUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
        title: PawsText(
          'Reactions',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(theme, scheme),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme scheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        title: 'Failed to load reactions',
        message: _errorMessage!,
        onRetry: _fetchReactionUsers,
      );
    }

    if (_reactionUsers == null || _reactionUsers!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.pawPrint,
              size: 64,
              color: scheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            PawsText(
              'No reactions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            PawsText(
              'Be the first to react to this post',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _reactionUsers!.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _reactionUsers![index];
        return _ReactionUserTile(user: user);
      },
    );
  }
}

class _ReactionUserTile extends StatelessWidget {
  final ReactionUser user;

  const _ReactionUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: user.profileImage != null
          ? CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(
                user.profileImage!.transformedUrl,
              ),
            )
          : CircleAvatar(
              radius: 24,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Icon(Icons.person, color: scheme.onSurfaceVariant),
            ),
      title: PawsText(
        user.username,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: PawsText(
        timeago.format(user.reactedAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(LucideIcons.pawPrint, color: scheme.primary, size: 20),
    );
  }
}

class ReactionUser {
  final String userId;
  final String username;
  final String? profileImage;
  final DateTime reactedAt;

  ReactionUser({
    required this.userId,
    required this.username,
    required this.profileImage,
    required this.reactedAt,
  });
}
