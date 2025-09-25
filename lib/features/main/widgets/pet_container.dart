// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

class PetContainer extends StatelessWidget {
  final Pet pet;
  final Function(int petId)? onFavoriteToggle;
  const PetContainer({super.key, required this.pet, this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            context.router.push(PetDetailRoute(pet: pet));
          },
          child: Container(
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
                      child: Image.network(
                        pet.photo,
                        width: MediaQuery.sizeOf(context).width * 0.40,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black26,
                        ),
                        child: PawsText(
                          DateFormat('MMM dd, yyyy').format(pet.createdAt),
                          fontSize: 12,
                          color: PawsColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                PawsText(pet.name, fontSize: 16, fontWeight: FontWeight.w500),
                PawsText('Age: ${pet.age} year(s) old', fontSize: 14),
                PawsText('Breed: ${pet.breed}', fontSize: 14),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton.filled(
            style: ButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(
                PawsColors.primary.withValues(alpha: 0.2),
              ),
            ),
            onPressed: onFavoriteToggle != null
                ? () {
                    onFavoriteToggle!(pet.id);
                  }
                : null,
            icon: Icon(
              pet.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
              color: PawsColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
