// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:glow_container/glow_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/events/models/event_model.dart';
import 'package:paws_connect/features/events/provider/event_provider.dart';
import 'package:paws_connect/features/events/repository/event_repository.dart';
import 'package:paws_connect/features/events/widgets/comment_input_field.dart';
import 'package:provider/provider.dart';
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

  Future<void> toogleLike(int commentId) async {
    final response = await EventProvider().toogleLike(
      commentId: commentId,
      userId: USER_ID ?? "",
    );
    if (response.isError) {
      EasyLoading.showToast(
        response.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      EasyLoading.showToast(
        response.value,
        toastPosition: EasyLoadingToastPosition.top,
      );
    }
  }

  Future<void> uploadComment(String content) async {
    final response = await EventProvider().uploadComment(
      content: content,
      userId: USER_ID ?? "",
      eventId: widget.id,
    );
    if (response.isError) {
      EasyLoading.showToast(
        response.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      EasyLoading.showToast(
        response.value,
        toastPosition: EasyLoadingToastPosition.top,
      );
    }
  }

  Future<void> joinEvent() async {
    if (USER_ID == null || USER_ID!.isEmpty) {
      EasyLoading.showToast(
        'Please sign in to join events',
        toastPosition: EasyLoadingToastPosition.top,
      );
      return;
    }

    EasyLoading.show(status: 'Joining event...');

    final error = await context.read<EventRepository>().joinEvent(
      eventId: widget.id,
      userId: USER_ID!,
    );

    EasyLoading.dismiss();

    if (error != null) {
      EasyLoading.showToast(error, toastPosition: EasyLoadingToastPosition.top);
    } else {
      EasyLoading.showToast(
        'Successfully joined the event!',
        toastPosition: EasyLoadingToastPosition.top,
      );
    }
  }

  Future<void> leaveEvent() async {
    if (USER_ID == null || USER_ID!.isEmpty) return;

    EasyLoading.show(status: 'Leaving event...');

    final error = await context.read<EventRepository>().leaveEvent(
      eventId: widget.id,
      userId: USER_ID!,
    );

    EasyLoading.dismiss();

    if (error != null) {
      EasyLoading.showToast(error, toastPosition: EasyLoadingToastPosition.top);
    } else {
      EasyLoading.showToast(
        'Successfully left the event!',
        toastPosition: EasyLoadingToastPosition.top,
      );
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
          if (event.images != null && event.images!.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: event.images!.map((image) {
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
                        enableInfiniteScroll: event.images!.length > 1,
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
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
              title: PawsText(
                event.title,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                  SizedBox(height: 16),
                  PawsText(
                    'About this Event',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 12),
                  PawsText(event.description, fontSize: 16),
                  SizedBox(height: 24),

                  // Enhanced Event Members Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PawsColors.primary.withValues(alpha: 0.05),
                          PawsColors.primary.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: PawsColors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PawsColors.primary.withValues(alpha: 0.08),
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
                                size: 24,
                                color: PawsColors.primary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PawsText(
                                  'Event Members',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: PawsColors.primary,
                                ),
                                SizedBox(height: 2),
                                PawsText(
                                  '${event.memberCount} ${event.memberCount == 1 ? 'person has' : 'people have'} joined',
                                  fontSize: 13,
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
                          SizedBox(height: 20),
                          PawsText(
                            'Members',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PawsColors.textPrimary,
                          ),
                          SizedBox(height: 12),

                          // Members List
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: event.members!.length > 6
                                  ? 200
                                  : double.infinity,
                            ),
                            child: event.members!.length <= 6
                                ? _buildMembersGrid(event.members!)
                                : _buildMembersScrollableList(event.members!),
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
                                ? ElevatedButton.icon(
                                    onPressed: leaveEvent,
                                    icon: Icon(LucideIcons.userMinus, size: 20),
                                    label: Text(
                                      'Leave Event',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor: Colors.red.shade600
                                          .withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: joinEvent,
                                    icon: Icon(LucideIcons.userPlus, size: 20),
                                    label: Text(
                                      'Join Event',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PawsColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor: PawsColors.primary
                                          .withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
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
                        PawsText(
                          '(Not clickable yet)',
                          fontSize: 12,
                          color: PawsColors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: event.suggestions!
                          .map(
                            (suggestion) => GlowContainer(
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
                              child: PawsText(suggestion, fontSize: 10),
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
                              backgroundImage: NetworkImage(
                                e.user.profileImageLink,
                              ),
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
                                          toogleLike(e.id);
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
  Widget _buildMembersGrid(List<EventMember> members) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: members.map((member) => _buildMemberItem(member)).toList(),
    );
  }

  // Helper method to build scrollable members list for larger lists
  Widget _buildMembersScrollableList(List<EventMember> members) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: members.map((member) => _buildMemberItem(member)).toList(),
      ),
    );
  }

  // Helper method to build individual member item
  Widget _buildMemberItem(EventMember member) {
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
                  child: NetworkImageView(
                    member.user.profileImageLink,
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
