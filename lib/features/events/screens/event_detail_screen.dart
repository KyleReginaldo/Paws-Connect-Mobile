// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:glow_container/glow_container.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/services/loading_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/events/models/event_model.dart';
import 'package:paws_connect/features/events/provider/event_provider.dart';
import 'package:paws_connect/features/events/repository/event_repository.dart';
import 'package:paws_connect/features/events/widgets/comment_input_field.dart';
import 'package:provider/provider.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../dependency.dart';

@RoutePage()
class EventDetailScreen extends StatefulWidget implements AutoRouteWrapper {
  final int id;
  const EventDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EventRepository>(),
      child: this,
    );
  }
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late RealtimeChannel commentChannel;

  // Helper method to download image from URL and save as local file
  Future<File?> downloadImageToFile(String imageUrl) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Create a unique filename
        final fileName =
            'event_image_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageUrl)}';
        final file = File(path.join(tempDir.path, fileName));

        // Write the image bytes to file
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
    return null;
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _toggleCommentLike(int commentId) async {
    final response = await EventProvider().toogleLike(
      commentId: commentId,
      userId: USER_ID ?? "",
    );
    if (response.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.value),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> uploadComment(String content) async {
    final response = await EventProvider().uploadComment(
      content: content,
      userId: USER_ID ?? "",
      eventId: widget.id,
    );
    if (response.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.value),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> joinEvent() async {
    if (USER_ID == null || USER_ID!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to join events'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      await LoadingService.showWhileExecuting(
        context,
        joinEventOperation(),
        message: 'Joining event...',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the event!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> joinEventOperation() async {
    await context.read<EventRepository>().joinEvent(
      eventId: widget.id,
      userId: USER_ID!,
    );
  }

  Future<void> leaveEventOperation() async {
    await context.read<EventRepository>().leaveEvent(
      eventId: widget.id,
      userId: USER_ID!,
    );
  }

  Future<void> leaveEvent() async {
    if (USER_ID == null || USER_ID!.isEmpty) return;

    try {
      await LoadingService.showWhileExecuting(
        context,
        leaveEventOperation(),
        message: 'Leaving event...',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left the event!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    commentChannel = supabase.channel(
      'public:event_comments:event=eq.${widget.id}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventRepository>().fetchEventById(eventId: widget.id);
    });
    listenToChanges();
    super.initState();
  }

  void listenToChanges() {
    commentChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'event_comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'event',
            value: widget.id,
          ),
          callback: (payload) {
            // Check if widget is still mounted before accessing context
            debugPrint('Comment change detected: $payload');
            if (mounted) {
              context.read<EventRepository>().reloadComments(
                eventId: widget.id,
              );
            }
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final event = context.watch<EventRepository>().event;
    final isLoading = context.watch<EventRepository>().singleEventLoading;
    debugPrint('comments: ${event?.comments?.length}');
    if (isLoading || event == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Fixed image section (not in app bar)
          if (event.transformedImages != null &&
              event.transformedImages!.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: event.transformedImages!.map((image) {
                        return NetworkImageView(
                          image,
                          fit: BoxFit.cover,
                          width: MediaQuery.sizeOf(context).width,
                          height: 250,
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 250.0,
                        viewportFraction: 1,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 4),
                        enableInfiniteScroll:
                            event.transformedImages!.length > 1,
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                LucideIcons.facebook,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                try {
                                  File? imageFile;

                                  // Download image if available
                                  if (event.transformedImages != null &&
                                      event.transformedImages!.isNotEmpty &&
                                      event
                                          .transformedImages!
                                          .first
                                          .isNotEmpty) {
                                    debugPrint(
                                      'Downloading image: ${event.transformedImages!.first}',
                                    );

                                    imageFile = await downloadImageToFile(
                                      event.transformedImages!.first,
                                    );

                                    if (imageFile != null) {
                                      debugPrint(
                                        'Image downloaded to: ${imageFile.path}',
                                      );
                                    } else {
                                      debugPrint(
                                        'Failed to download image, sharing without media',
                                      );
                                    }
                                  }

                                  await SocialSharingPlus.shareToSocialMedia(
                                    SocialPlatform.facebook,
                                    '${event.title}\n\n${event.description}',
                                    media: imageFile?.path,
                                    isOpenBrowser: true,
                                  );
                                } catch (e) {
                                  debugPrint('Error sharing to Facebook: $e');

                                  // Fallback to sharing without media if there's an error
                                  try {
                                    await SocialSharingPlus.shareToSocialMedia(
                                      SocialPlatform.facebook,
                                      event.title,
                                      isOpenBrowser: true,
                                    );
                                  } catch (fallbackError) {
                                    debugPrint(
                                      'Fallback sharing also failed: $fallbackError',
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Title overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: PawsText(
                        event.title,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Simple app bar for when there are no images
          if (event.images == null || event.images!.isEmpty)
            SliverAppBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              pinned: true,
              backgroundColor: PawsColors.primary,
              foregroundColor: Colors.white,
            ),

          // Sliver content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PawsText(
                    'About this event',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: PawsColors.textPrimary,
                  ),
                  SizedBox(height: 8),
                  PawsText(
                    event.description,
                    fontSize: 14,
                    color: PawsColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  // Enhanced Event Members Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PawsColors.textSecondary.withValues(alpha: 0.05),
                          PawsColors.textSecondary.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: PawsColors.textSecondary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PawsColors.textSecondary.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: PawsColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                LucideIcons.users,
                                size: 16,
                                color: PawsColors.primary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PawsText(
                                  'Members',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: PawsColors.primary,
                                ),
                                SizedBox(height: 2),
                                PawsText(
                                  '${event.memberCount} ${event.memberCount == 1 ? 'person has' : 'people have'} joined',
                                  fontSize: 12,
                                  color: PawsColors.textSecondary,
                                ),
                              ],
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: PawsColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: PawsColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.userCheck,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  PawsText(
                                    '${event.memberCount}',
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Members Display Section
                        if (event.members != null &&
                            event.members!.isNotEmpty) ...[
                          SizedBox(height: 10),
                          PawsText(
                            'Members',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PawsColors.textPrimary,
                          ),
                          SizedBox(height: 8),

                          // Members List
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: event.members!.length > 6
                                  ? 200
                                  : double.infinity,
                            ),
                            child: event.members!.length <= 6
                                ? buildMembersGrid(event.members!)
                                : buildMembersScrollableList(event.members!),
                          ),

                          // Show more indicator if there are many members
                          if (event.members!.length > 6) ...[
                            SizedBox(height: 8),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Scroll to see all members',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],

                        // Join/Leave Button Section
                        SizedBox(height: 20),
                        if (USER_ID != null && USER_ID!.isNotEmpty) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: event.isUserMember(USER_ID!)
                                ? PawsElevatedButton(
                                    label: 'Leave Event',
                                    onPressed: leaveEvent,
                                    icon: LucideIcons.userMinus,
                                    backgroundColor: Colors.red,
                                    borderRadius: 25,
                                    size: 14,
                                    padding: EdgeInsets.symmetric(vertical: 0),
                                  )
                                : PawsElevatedButton(
                                    label: 'Join Event',
                                    onPressed: joinEvent,
                                    icon: LucideIcons.userPlus,
                                    borderRadius: 25,
                                    size: 14,
                                    padding: EdgeInsets.symmetric(vertical: 0),
                                  ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.info,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PawsText(
                                        'Sign in required',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                      SizedBox(height: 2),
                                      PawsText(
                                        'Please sign in to join this event',
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Event metadata
                  Row(
                    children: [
                      Icon(LucideIcons.clock12, size: 16),
                      SizedBox(width: 8),
                      PawsText(
                        'Created: ${_formatDate(event.createdAt)}',
                        fontSize: 14,
                        color: PawsColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (event.startingDate != null) ...[
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 16),
                        SizedBox(width: 8),
                        PawsText(
                          'Starting: ${DateFormat('MMM dd, yyyy').format(event.startingDate!)}',
                          fontSize: 14,
                          color: PawsColors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                  if (event.endedAt != null) ...[
                    Row(
                      children: [
                        Icon(LucideIcons.clock10, size: 16),
                        SizedBox(width: 8),
                        PawsText(
                          'Ended: ${DateFormat('MMM dd, yyyy').format(event.endedAt!)}',
                          fontSize: 14,
                          color: PawsColors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(LucideIcons.shieldUser, size: 20),
                      SizedBox(width: 8),
                      PawsText(
                        'Posted by Admin',
                        fontSize: 14,
                        color: PawsColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Suggestions section
                  if (event.suggestions != null &&
                      event.suggestions!.isNotEmpty) ...[
                    Row(
                      spacing: 5,
                      children: [
                        PawsText(
                          'Suggestions',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: PawsColors.primary,
                        ),
                        PawsText(
                          'Powered by AI',
                          fontSize: 12,
                          color: PawsColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: event.suggestions!
                          .map(
                            (suggestion) => GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(),
                                  builder: (_) {
                                    return SuggestionModal(
                                      suggestion: suggestion,
                                      eventContext:
                                          '${event.title}, ${event.description}',
                                    );
                                  },
                                );
                              },
                              child: GlowContainer(
                                containerOptions: ContainerOptions(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  borderRadius: 20,
                                ),
                                gradientColors: [
                                  Colors.purple,
                                  Colors.blue,
                                  Colors.pink,
                                ],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PawsText(suggestion, fontSize: 10),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.touch_app,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 16),

                    // Comments section
                  ],
                  if (event.comments != null && event.comments!.isNotEmpty) ...[
                    PawsText(
                      'Comments (${event.comments!.length})',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 16),
                    ...event.comments!.map((e) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: PawsColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: e.user.profileImageLink != null
                                  ? NetworkImage(e.user.profileImageLink!)
                                  : AssetImage('assets/images/user.png'),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 5,
                                    children: [
                                      PawsText(
                                        e.user.username,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      PawsText(
                                        _formatDate(e.createdAt),
                                        fontSize: 12,
                                        color: PawsColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                  PawsText(e.content, fontSize: 14),
                                  Row(
                                    spacing: 8,
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          _toggleCommentLike(e.id);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            e.likes?.any(
                                                      (like) => like == USER_ID,
                                                    ) ??
                                                    false
                                                ? Icons.favorite
                                                : Icons.favorite_outline,
                                            size: 16,
                                            color:
                                                e.likes?.any(
                                                      (like) => like == USER_ID,
                                                    ) ??
                                                    false
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      PawsText('${e.likes?.length ?? 0}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: CommentInputField(
        onSubmit: (content) {
          uploadComment(content);
        },
      ),
    );
  }

  // Helper method to build members grid for smaller lists
  Widget buildMembersGrid(List<EventMember> members) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: members.map((member) => buildMemberItem(member)).toList(),
    );
  }

  // Helper method to build scrollable members list for larger lists
  Widget buildMembersScrollableList(List<EventMember> members) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: members.map((member) => buildMemberItem(member)).toList(),
      ),
    );
  }

  // Helper method to build individual member item
  Widget buildMemberItem(EventMember member) {
    return Container(
      constraints: BoxConstraints(minWidth: 100, maxWidth: 120),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PawsColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PawsColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: member.user.profileImageLink != null
                      ? NetworkImageView(
                          member.user.profileImageLink!,
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        )
                      : Image.asset(
                          'assets/images/user.png',
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        ),
                ),
              ),
              // Online indicator (current user gets a green dot)
              if (member.user.id == USER_ID)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),

          // Username
          Text(
            member.user.username,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),

          // Join date
          Text(
            'Joined ${_formatDate(member.joinedAt)}',
            style: TextStyle(fontSize: 10, color: PawsColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SuggestionModal extends StatefulWidget {
  final String suggestion;
  final String eventContext;

  const SuggestionModal({
    super.key,
    required this.suggestion,
    required this.eventContext,
  });

  @override
  State<SuggestionModal> createState() => _SuggestionModalState();
}

class _SuggestionModalState extends State<SuggestionModal> {
  String? suggestionCompletion;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    generateSuggestion();
  }

  void generateSuggestion() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await Gemini.instance
          .prompt(
            safetySettings: [
              SafetySetting(
                category: SafetyCategory.harassment,
                threshold: SafetyThreshold.blockLowAndAbove,
              ),
            ],
            parts: [
              Part.text(
                'Context: You are providing information for a pet adoption/animal welfare organization located at "Blk 4, 23 Officers Avenue, Bacoor, Cavite". '
                'This organization specializes in pet adoption services, animal shelter operations, fundraising campaigns, donation drives, community forums, community outreach programs, and various pet-related events.\n\n'
                'Based on the event: "${widget.eventContext}", provide detailed, helpful information about: "${widget.suggestion}". '
                'If the question relates to location or "where", mention that the organization is located at Blk 4, 23 Officers Avenue, Bacoor, Cavite. '
                'Consider aspects like adoption procedures, shelter services, volunteer opportunities, donation needs, event logistics, pet care requirements, and community involvement. '
                'Please provide a clear, informative response that would be helpful for someone interested in this pet welfare event or topic. '
                'Format your response in markdown for better readability with appropriate headings, bullet points, and emphasis.',
              ),
            ],
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Request timed out',
              Duration(seconds: 30),
            ),
          );

      if (mounted) {
        setState(() {
          suggestionCompletion = response?.output ?? 'No response generated.';
          isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              'Request timed out. Please check your internet connection and try again.';
          isLoading = false;
        });
      }
      debugPrint('Gemini timeout: $e');
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = getGeminiErrorMessage(e);
          isLoading = false;
        });
      }
      debugPrint('Gemini API error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.70,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(),
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: PawsText(
                    widget.suggestion,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 20),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (isLoading)
              buildSkeletonLoader()
            else if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            'Error generating suggestion',
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    PawsText(
                      errorMessage!,
                      fontSize: 12,
                      color: Colors.red.shade600,
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: generateSuggestion,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PawsColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: PawsText(
                          'Try Again',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              GptMarkdown(
                suggestionCompletion ?? 'No suggestions available.',
                style: TextStyle(fontSize: 14, color: PawsColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSkeletonLoader() {
    return AnimatedBuilder(
      animation: getShimmerAnimation(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Generation Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🤖 AI is analyzing "${widget.suggestion}"...',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Title skeleton
            buildShimmerContainer(16, double.infinity),
            SizedBox(height: 12),

            // Paragraph skeletons with varying widths
            ...List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: buildShimmerContainer(14, getRandomWidth(index)),
              ),
            ),

            SizedBox(height: 16),

            // Bullet points skeleton
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildShimmerContainer(6, 6, isCircle: true, topMargin: 4),
                    SizedBox(width: 8),
                    Expanded(
                      child: buildShimmerContainer(14, getBulletWidth(index)),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Footer skeleton
            buildShimmerContainer(14, MediaQuery.sizeOf(context).width * 0.6),
          ],
        );
      },
    );
  }

  Widget buildShimmerContainer(
    double height,
    double width, {
    bool isCircle = false,
    double topMargin = 0,
  }) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: isCircle ? null : BorderRadius.circular(4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  Animation<double> getShimmerAnimation() {
    return AlwaysStoppedAnimation(0.0);
  }

  double getRandomWidth(int index) {
    final widths = [
      double.infinity,
      MediaQuery.sizeOf(context).width * 0.9,
      MediaQuery.sizeOf(context).width * 0.75,
      double.infinity,
      MediaQuery.sizeOf(context).width * 0.65,
    ];
    return widths[index % widths.length];
  }

  double getBulletWidth(int index) {
    final widths = [
      MediaQuery.sizeOf(context).width * 0.8,
      MediaQuery.sizeOf(context).width * 0.9,
      MediaQuery.sizeOf(context).width * 0.7,
      MediaQuery.sizeOf(context).width * 0.85,
    ];
    return widths[index % widths.length];
  }

  String getGeminiErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('api key') ||
        errorString.contains('authentication')) {
      return 'Authentication error. Please contact support.';
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (errorString.contains('safety') ||
        errorString.contains('blocked')) {
      return 'Content was blocked by safety filters. Please try a different request.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('invalid') ||
        errorString.contains('malformed')) {
      return 'Invalid request. Please try again.';
    } else if (errorString.contains('server') ||
        errorString.contains('503') ||
        errorString.contains('502')) {
      return 'Server temporarily unavailable. Please try again in a moment.';
    } else {
      return 'AI service is currently unavailable. Please try again later.';
    }
  }
}
