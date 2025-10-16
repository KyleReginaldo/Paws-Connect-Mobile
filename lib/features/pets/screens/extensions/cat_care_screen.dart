import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';

@RoutePage()
class CatCareScreen extends StatelessWidget {
  const CatCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'How to Care of Cats',
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
              icon: LucideIcons.eggFried,
              title: 'Nutrition',
              points: [
                'Provide a balanced diet appropriate for age and health.',
                'Fresh water should be available at all times.',
                'Avoid giving onions, garlic, chocolate, and bones.',
              ],
            ),
            SizedBox(height: 16),
            _Section(
              icon: LucideIcons.showerHead,
              title: 'Grooming & Litter',
              points: [
                'Brush weekly to reduce shedding and hairballs.',
                'Scoop litter daily and clean the box regularly.',
                'Provide one litter box per cat plus one extra.',
              ],
            ),
            SizedBox(height: 16),
            _Section(
              icon: LucideIcons.stethoscope,
              title: 'Health',
              points: [
                'Schedule annual vet checkups and vaccinations.',
                'Use flea/tick prevention as recommended by a vet.',
                'Spay/neuter to promote health and reduce roaming.',
              ],
            ),
            SizedBox(height: 16),
            _Section(
              icon: LucideIcons.cable,
              title: 'Enrichment & Safety',
              points: [
                'Provide scratching posts, toys, and window perches.',
                'Keep toxic plants/chemicals out of reach.',
                'Microchip and use a secure collar with ID tag.',
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
