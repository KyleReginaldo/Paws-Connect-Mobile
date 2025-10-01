// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/favorite/repository/favorite_repository.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

import '../../../../core/router/app_route.gr.dart';
import '../../../../core/supabase/client.dart';

@RoutePage()
class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  void _toggleFavorite() async {
    if (USER_ID == null || (USER_ID?.isEmpty ?? true)) {
      // Not signed in; navigate to sign in
      if (!mounted) return;
      context.router.push(
        SignInRoute(
          onResult: (success) {
            if (!mounted) return;
            if (success) setState(() {});
          },
        ),
      );
      return;
    }

    final current = widget.pet.isFavorite ?? false;
    setState(() => widget.pet.isFavorite = !current);
    try {
      await sl<FavoriteRepository>().toggleFavorite(widget.pet.id);
    } catch (_) {
      if (!mounted) return;
      // Rollback on failure
      setState(() => widget.pet.isFavorite = current);
    }
  }

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
              child: Opacity(
                opacity: 0.9,
                child: NetworkImageView(
                  widget.pet.photo,
                  fit: BoxFit.cover,
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  width: MediaQuery.sizeOf(context).width,
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
                    widget.pet.name,
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
                        widget.pet.rescueAddress,
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
                              widget.pet.gender,
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
                              widget.pet.age.toString(),
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
                              widget.pet.weight,
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
                    children: widget.pet.goodWith
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
                    widget.pet.description.isNotEmpty
                        ? widget.pet.description
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
              context.router.push(CreateAdoptionRoute(petId: widget.pet.id));
            },
            borderRadius: 25,
          ),
        ),
      ),
    );
  }
}
