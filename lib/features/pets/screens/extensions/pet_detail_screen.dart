// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

import '../../../../core/router/app_route.gr.dart';

@RoutePage()
class PetDetailScreen extends StatelessWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: PawsText(
            'Pet Details',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              height: MediaQuery.sizeOf(context).height * 0.3,
              width: MediaQuery.sizeOf(context).width,
              child: Image.network(
                pet.photo,
                fit: BoxFit.cover,
                opacity: Animation.fromValueListenable(
                  AlwaysStoppedAnimation(0.9),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PawsText(
                    pet.name,
                    fontSize: 18,
                    color: PawsColors.textPrimary,
                  ),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 15,
                        color: PawsColors.primaryDark,
                      ),
                      PawsText(
                        pet.rescueAddress,
                        fontSize: 15,
                        color: PawsColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.3 - 26,
                        padding: EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 16,
                          right: 24,
                        ),
                        decoration: BoxDecoration(
                          color: PawsColors.info.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PawsText('Gender', fontSize: 16),
                            PawsText(
                              pet.gender,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.3 - 26,

                        padding: EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 16,
                          right: 24,
                        ),
                        decoration: BoxDecoration(
                          color: PawsColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PawsText('Age', fontSize: 16),
                            PawsText(
                              pet.age.toString(),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.3 - 26,

                        padding: EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 16,
                          right: 24,
                        ),
                        decoration: BoxDecoration(
                          color: PawsColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PawsText('Weight', fontSize: 16),
                            PawsText(
                              pet.weight,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  PawsText('Good with:'),
                  Row(
                    children: pet.goodWith
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: PawsText(
                                e,
                                fontSize: 12,
                                color: PawsColors.textLight,
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: PawsColors.primary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: PawsColors.primary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Divider(thickness: 2, color: PawsColors.border),
                  PawsText('Description'),
                  SizedBox(height: 5),
                  PawsText(
                    pet.description.isNotEmpty
                        ? pet.description
                        : 'No description available',
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PawsElevatedButton(
            label: 'Adopt Now',
            onPressed: () {
              context.router.push(CreateAdoptionRoute(petId: pet.id));
            },
            borderRadius: 25,
          ),
        ),
      ),
    );
  }
}
