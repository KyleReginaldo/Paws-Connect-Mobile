// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:glow_container/glow_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/events/provider/event_provider.dart';
import 'package:paws_connect/features/events/repository/event_repository.dart';
import 'package:provider/provider.dart';

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

  Future<void> likeComment(int commentId) async {
    final response = await EventProvider().likeComment(commentId: commentId);
    if (response.isError) {
      EasyLoading.showToast(
        response.error,
        toastPosition: EasyLoadingToastPosition.top,
      );
    } else {
      EasyLoading.showToast(
        'Comment liked!',
        toastPosition: EasyLoadingToastPosition.top,
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch event details using widget.id
      // Example: context.read<EventRepository>().fetchEventDetails(widget.id);
      context.read<EventRepository>().fetchEventById(eventId: widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = context.watch<EventRepository>().event;
    final isLoading = context.watch<EventRepository>().singleEventLoading;
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
                    if (event.comments != null &&
                        event.comments!.isNotEmpty) ...[
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
                              Column(
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
                                  SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      likeComment(e.id);
                                    },
                                    child: Icon(LucideIcons.thumbsUp, size: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
