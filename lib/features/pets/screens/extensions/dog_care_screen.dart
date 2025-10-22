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
          'How to Care for Dogs',
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
              icon: LucideIcons.bone,
              title: 'Nutrition',
              points: [
                'Feed high-quality food appropriate for age, size, and activity level.',
                'Provide fresh water at all times and avoid cooked bones.',
                'Introduce new foods gradually to avoid stomach upset.',
              ],
            ),
            const SizedBox(height: 8),
            _CustomAccordionItem(
              icon: LucideIcons.bath,
              title: 'Grooming & Hygiene',
              points: [
                'Brush regularly and bathe as needed based on coat type.',
                'Trim nails, clean ears, and brush teeth routinely.',
                'Use flea/tick prevention as advised by a vet.',
              ],
            ),
            const SizedBox(height: 8),
            _CustomAccordionItem(
              icon: LucideIcons.stethoscope,
              title: 'Health & Exercise',
              points: [
                'Schedule vet checkups, vaccines, and heartworm prevention.',
                'Provide daily exercise and mental stimulation.',
                'Spay/neuter to promote health and reduce roaming.',
              ],
            ),
            const SizedBox(height: 8),
            _CustomAccordionItem(
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
