// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/enum/user.enum.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/favorite/repository/favorite_repository.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;

import '../../../../core/router/app_route.gr.dart';
import '../../../../core/supabase/client.dart';

@RoutePage()
class PetDetailScreen extends StatefulWidget implements AutoRouteWrapper {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<PetRepository>()),
      ],
      child: this,
    );
  }
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
      context.read<PetRepository>().fetchPetById(widget.pet.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleFavorite() async {
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

  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to format status
  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      default:
        return status;
    }
  }

  Widget _buildImageCarousel(Pet pet) {
    final images = pet.transformedPhotos.isNotEmpty
        ? pet.transformedPhotos
        : [''];

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.3,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.transparent, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Opacity(
                opacity: 0.9,
                child: NetworkImageView(
                  images[index],
                  fit: BoxFit.cover,
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  width: MediaQuery.sizeOf(context).width,
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PawsText(
                  '${_currentPage + 1}/${images.length}',
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select(
      (ProfileRepository profileRepo) => profileRepo.userProfile,
    );
    final pet =
        context.select((PetRepository petRepo) => petRepo.pet) ?? widget.pet;
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Pet Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: RefreshTrigger(
          onRefresh: () async {
            context.read<PetRepository>().fetchPetById(widget.pet.id);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _buildImageCarousel(pet),
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
                      SizedBox(height: 16),
                      if (pet.adopted != null) ...[
                        Divider(thickness: 2, color: PawsColors.border),

                        Column(
                          spacing: 4,
                          children: [
                            Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PawsText('☺️'),
                                PawsText(
                                  '${pet.name} has been adopted!',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PawsColors.success,
                                ),
                                PawsText('☺️'),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PawsText('🎉'),

                                PawsText(
                                  'by ${pet.adopted!.user.userIdentification?.firstName} ${pet.adopted!.user.userIdentification?.lastName}',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: PawsColors.success,
                                ),
                                PawsText('🎉'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],

                      // Adoptions Section
                      if (pet.adopted == null &&
                          pet.adoption != null &&
                          pet.adoption!.isNotEmpty) ...[
                        Divider(thickness: 2, color: PawsColors.border),

                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.heart,
                              size: 18,
                              color: PawsColors.primary,
                            ),
                            SizedBox(width: 8),
                            PawsText(
                              'Adoption Applications (${pet.adoption!.length})',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PawsColors.textPrimary,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pet.adoption!.length,
                          itemBuilder: (context, index) {
                            final adoption = pet.adoption![index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // User Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: PawsColors.primary
                                        .withValues(alpha: 0.1),
                                    backgroundImage:
                                        adoption.user.profileImageLink != null
                                        ? NetworkImage(
                                            adoption.user.profileImageLink!,
                                          )
                                        : null,
                                    child:
                                        adoption.user.profileImageLink == null
                                        ? Icon(
                                            LucideIcons.user,
                                            color: PawsColors.primary,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 12),

                                  // User Info
                                  if (pet.adopted != null &&
                                      pet.adopted!.user.id == adoption.user.id)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PawsText(
                                            '${pet.adopted!.user.userIdentification?.firstName} ${pet.adopted!.user.userIdentification?.lastName}',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: PawsColors.textPrimary,
                                          ),
                                          SizedBox(height: 2),
                                          PawsText(
                                            'Applied ${_formatDate(adoption.createdAt)}',
                                            fontSize: 12,
                                            color: PawsColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Status Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        adoption.status,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: PawsText(
                                      _formatStatus(adoption.status),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(adoption.status),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                      ] else if (widget.pet.adopted == null &&
                          widget.pet.adoption != null) ...[
                        Divider(thickness: 2, color: PawsColors.border),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.heart,
                              size: 18,
                              color: PawsColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            PawsText(
                              'No adoption applications yet',
                              fontSize: 14,
                              color: PawsColors.textSecondary,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user == null)
                PawsText(
                  'You need to be signed in to adopt a pet.',
                  fontSize: 12,
                  color: PawsColors.error,
                ),
              if (user?.status == UserStatus.PENDING ||
                  user?.status == UserStatus.INDEFINITE)
                PawsText(
                  'You need to be a fully verified user to adopt a pet.',
                  fontSize: 12,
                  color: PawsColors.error,
                ),
              if (pet.adopted == null &&
                  (pet.adoption ?? []).any((e) => e.user.id == USER_ID))
                PawsText(
                  'You have already applied to adopt this pet.',
                  fontSize: 12,
                  color: PawsColors.error,
                ),
              PawsElevatedButton(
                label: 'Adopt Now',
                backgroundColor:
                    (!(pet.adoption ?? []).any((e) => e.user.id == USER_ID)) &&
                        pet.adopted == null &&
                        user != null &&
                        user.status == UserStatus.FULLY_VERIFIED
                    ? PawsColors.primary
                    : PawsColors.disabled,
                onPressed:
                    (!(pet.adoption ?? []).any((e) => e.user.id == USER_ID)) &&
                        pet.adopted == null &&
                        user != null &&
                        user.status == UserStatus.FULLY_VERIFIED
                    ? () {
                        context.router.push(
                          CreateAdoptionRoute(petId: widget.pet.id),
                        );
                      }
                    : null,
                borderRadius: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
