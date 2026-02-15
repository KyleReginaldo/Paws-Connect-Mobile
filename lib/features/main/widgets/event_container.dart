// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

class EventContainer extends StatelessWidget {
  final Event event;
  final Function(String)? onSuggestionTap;
  final Function()? onTap;

  const EventContainer({
    super.key,
    required this.event,
    this.onSuggestionTap,
    this.onTap,
  });

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width:
            MediaQuery.of(context).size.width *
            0.85, // Fixed width for horizontal scroll
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PawsColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PawsText(
              event.title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PawsColors.textPrimary,
              maxLines: 2,
            ),
            Row(
              spacing: 5,
              children: [
                Icon(LucideIcons.globe, size: 12, color: PawsColors.success),
                PawsText(
                  _formatEventDate(event.createdAt),
                  fontSize: 11,
                  color: PawsColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            PawsText(
              event.description,
              fontSize: 12,
              color: PawsColors.textSecondary,
              maxLines: 2,
            ),
            if (event.transformedImages != null &&
                event.transformedImages!.isNotEmpty) ...[
              const SizedBox(height: 4),

              CarouselSlider(
                items: event.transformedImages!.map((image) {
                  return GlowContainer(
                    containerOptions: ContainerOptions(
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.hardEdge,
                    ),
                    gradientColors: [Colors.blue, Colors.purple, Colors.pink],
                    child: NetworkImageView(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 120,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                ),
              ),
            ],
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  LucideIcons.messageCircle,
                  size: 16,
                  color: PawsColors.info,
                ),
                const SizedBox(width: 4),
                PawsText(
                  event.comments?.length.toString() ?? "0",
                  fontSize: 14,
                  color: PawsColors.textSecondary,
                ),
                SizedBox(width: 16),

                Icon(LucideIcons.heart, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                PawsText(
                  "${event.comments?.map((e) => e.likes?.length ?? 0).fold<int>(0, (a, b) => a + b) ?? 0}",
                  fontSize: 14,
                  color: PawsColors.textSecondary,
                ),
                SizedBox(width: 16),

                Icon(LucideIcons.users, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                PawsText(
                  "${event.members?.length ?? 0}",
                  fontSize: 14,
                  color: PawsColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
