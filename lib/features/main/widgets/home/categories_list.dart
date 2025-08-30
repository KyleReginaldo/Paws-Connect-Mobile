import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';

class CategoriesList extends StatelessWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: [
          Container(
            padding: EdgeInsets.all(16),

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PawsColors.primary, width: 2),
            ),
            child: Icon(LucideIcons.cat),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PawsColors.primary, width: 2),
            ),
            child: Icon(LucideIcons.dog),
          ),
        ],
      ),
    );
  }
}
