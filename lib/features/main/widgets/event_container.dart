import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/divider.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

class EventContainer extends StatelessWidget {
  final Event event;
  final Function(String)? onSuggestionTap;

  const EventContainer({super.key, required this.event, this.onSuggestionTap});

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
    return Container(
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
          if (event.images != null && event.images!.isNotEmpty) ...[
            const SizedBox(height: 4),

            CarouselSlider(
              items: event.images!.map((image) {
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

          if (event.suggestions != null && event.suggestions!.isNotEmpty) ...[
            const SizedBox(height: 4),
            PawsDivider(text: 'PawsAI'),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 6,
                children: event.suggestions!.map((e) {
                  return GestureDetector(
                    onTap: () {
                      if (onSuggestionTap != null) {
                        onSuggestionTap!(e);
                      }
                    },
                    child: GlowContainer(
                      glowRadius: 1,
                      containerOptions: ContainerOptions(
                        borderRadius: 25,
                        padding: EdgeInsets.zero,
                      ),
                      gradientColors: [Colors.blue, Colors.purple, Colors.pink],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PawsText(
                          e,
                          fontSize: 10,
                          color: PawsColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
