// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/features/adoption/models/adoption_model.dart';

import '../../../../core/router/app_route.gr.dart';
import '../../../../core/theme/paws_theme.dart';
import '../../../../core/widgets/button.dart';
import '../../../../core/widgets/text.dart';

class AdoptionOverview extends StatelessWidget {
  final List<Adoption> adoptions;
  const AdoptionOverview({super.key, required this.adoptions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PawsColors.primary, PawsColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/grid.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PawsText(
                  'Your adoptions',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                PawsText(
                  'You currently have ${adoptions.length} adoption${adoptions.length > 1 ? 's' : ''}',
                  fontSize: 13,
                  color: Colors.white,
                ),
                PawsElevatedButton(
                  label: 'View adoptions',
                  isFullWidth: false,
                  onPressed: () {
                    context.router.push(const AdoptionHistoryRoute());
                  },
                  backgroundColor: Colors.white,
                  borderRadius: 8,
                  foregroundColor: PawsColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  icon: LucideIcons.arrowRight,
                  size: 13,
                ),
              ],
            ),
          ),
          Image.asset('assets/images/adopt.png', height: 100),
        ],
      ),
    );
  }
}
