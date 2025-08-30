import 'package:flutter/material.dart';

import '../../../../core/theme/paws_theme.dart';
import '../../../../core/widgets/text.dart';

class PromotionContainer extends StatelessWidget {
  const PromotionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PawsColors.primaryDark, PawsColors.primary],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PawsText(
            'Find your new best friend today!',
            fontSize: 18,
            color: PawsColors.textLight,
            fontWeight: FontWeight.w500,
          ),
          PawsText(
            'Adopt a loving pet and give them the FURever home they deserve.',
            color: PawsColors.textLight,
          ),
        ],
      ),
    );
  }
}
