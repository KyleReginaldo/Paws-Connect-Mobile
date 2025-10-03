import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

class EventContainer extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventContainer({super.key, required this.event, this.onTap});

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:
            MediaQuery.of(context).size.width *
            0.90, // Fixed width for horizontal scroll
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
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PawsColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      const SizedBox(height: 4),
                      PawsText(
                        event.description,
                        fontSize: 12,
                        color: PawsColors.textSecondary,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      PawsText(
                        'Posted ${_formatEventDate(event.createdAt)}',
                        fontSize: 11,
                        color: PawsColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: PawsColors.textSecondary,
                ),
              ],
            ),
            if (event.suggestions != null) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 6,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: event.suggestions!.map((e) {
                  return GlowContainer(
                    glowRadius: 4,
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
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
