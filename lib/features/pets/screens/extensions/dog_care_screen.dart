import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';

@RoutePage()
class DogCareScreen extends StatelessWidget {
  const DogCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'How to Care of Dogs',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: PawsColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Section(
              icon: LucideIcons.bone,
              title: 'Nutrition',
              points: [
                'Feed high-quality food appropriate for age, size, and activity level.',
                'Provide fresh water at all times and avoid cooked bones.',
                'Introduce new foods gradually to avoid stomach upset.',
              ],
            ),
            SizedBox(height: 16),
            _Section(
              icon: LucideIcons.bath,
              title: 'Grooming & Hygiene',
              points: [
                'Brush regularly and bathe as needed based on coat type.',
                'Trim nails, clean ears, and brush teeth routinely.',
                'Use flea/tick prevention as advised by a vet.',
              ],
            ),
            SizedBox(height: 16),
            _Section(
              icon: LucideIcons.stethoscope,
              title: 'Health & Exercise',
              points: [
                'Schedule vet checkups, vaccines, and heartworm prevention.',
                'Provide daily exercise and mental stimulation.',
                'Spay/neuter to promote health and reduce roaming.',
              ],
            ),
            SizedBox(height: 16),
            _Section(
              icon: LucideIcons.shieldCheck,
              title: 'Training & Safety',
              points: [
                'Use positive reinforcement training and socialization.',
                'Microchip and use a collar with ID tag.',
                'Secure your yard/home; supervise around hazards.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> points;
  const _Section({
    required this.icon,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PawsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PawsColors.primary, size: 18),
              const SizedBox(width: 8),
              PawsText(
                title,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: PawsColors.textSecondary),
                  ),
                  Expanded(
                    child: PawsText(
                      p,
                      color: PawsColors.textSecondary,
                      fontSize: 14,
                    ),
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
