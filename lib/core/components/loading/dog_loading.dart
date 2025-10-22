import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_connect/core/widgets/text.dart';

import '../../theme/paws_theme.dart';

class DogLoading extends StatelessWidget {
  final String? message;
  final bool showContainer;

  const DogLoading({super.key, this.message, this.showContainer = true});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LottieBuilder.asset(
          'assets/json/dog_loading.json',
          height: 80,
          width: 80,
          fit: BoxFit.contain,
        ),
        Flexible(
          child: PawsText(
            message ?? 'Walking the dog...',
            color: PawsColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );

    if (!showContainer) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: content,
    );
  }
}
