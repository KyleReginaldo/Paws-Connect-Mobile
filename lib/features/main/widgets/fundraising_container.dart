import 'package:flutter/material.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

class FundraisingContainer extends StatelessWidget {
  const FundraisingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.90,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/onboarding_background.jpg',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PawsText(
                      'For food of our dogs and cats',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    PawsText(
                      'Every penny counts',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    PawsText('10% target reached', fontSize: 14),
                    PawsText('12 hours left', fontSize: 14),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PawsText('Raised: \$100', fontWeight: FontWeight.w500),
              PawsText(
                'Goal: \$1000',
                color: PawsColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: 0.1,
            backgroundColor: PawsColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}
