import 'package:flutter/material.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

class PetContainer extends StatelessWidget {
  const PetContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/onboarding_background.jpg',
                  width: MediaQuery.sizeOf(context).width * 0.40,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black26,
                  ),
                  child: PawsText(
                    'Mon, June 23, 2025',
                    fontSize: 12,
                    color: PawsColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          PawsText('Algod James', fontSize: 16, fontWeight: FontWeight.w500),
          PawsText('Age: 1 year(s) old', fontSize: 14),
          PawsText('Breed: Corgi', fontSize: 14),
        ],
      ),
    );
  }
}
