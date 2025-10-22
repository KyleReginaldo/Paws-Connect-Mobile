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
          'How to Care for Cats',
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
          children: [
            _CustomAccordionItem(
              icon: LucideIcons.eggFried,
              title: 'Nutrition',
              points: [
                'Provide a balanced diet appropriate for age and health.',
                'Fresh water should be available at all times.',
                'Avoid giving onions, garlic, chocolate, and bones.',
              ],
            ),
            const SizedBox(height: 8),
            _CustomAccordionItem(
              icon: LucideIcons.showerHead,
              title: 'Grooming & Litter',
              points: [
                'Brush weekly to reduce shedding and hairballs.',
                'Scoop litter daily and clean the box regularly.',
                'Provide one litter box per cat plus one extra.',
              ],
            ),
            const SizedBox(height: 8),
            _CustomAccordionItem(
              icon: LucideIcons.stethoscope,
              title: 'Health',
              points: [
                'Schedule annual vet checkups and vaccinations.',
                'Use flea/tick prevention as recommended by a vet.',
                'Spay/neuter to promote health and reduce roaming.',
              ],
            ),
            const SizedBox(height: 8),
            _CustomAccordionItem(
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

class _CustomAccordionItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<String> points;

  const _CustomAccordionItem({
    required this.icon,
    required this.title,
    required this.points,
  });

  @override
  State<_CustomAccordionItem> createState() => _CustomAccordionItemState();
}

class _CustomAccordionItemState extends State<_CustomAccordionItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PawsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header/Trigger
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: PawsColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PawsText(
                      widget.title,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PawsColors.textPrimary,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      LucideIcons.chevronDown,
                      color: PawsColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: PawsColors.border, height: 1),
                  const SizedBox(height: 12),
                  ...widget.points.map(
                    (point) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: PawsColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PawsText(
                              point,
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
            ),
          ),
        ],
      ),
    );
  }
}
