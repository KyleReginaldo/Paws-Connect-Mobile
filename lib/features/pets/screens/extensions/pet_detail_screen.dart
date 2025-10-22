// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/enum/user.enum.dart';
import 'package:paws_connect/core/services/loading_service.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/adoption/provider/adoption_provider.dart';
import 'package:paws_connect/features/favorite/repository/favorite_repository.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';
import 'package:paws_connect/features/pets/provider/pet_provider.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_route.gr.dart';

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
  // Realtime channels for this pet's changes and its adoptions
  late RealtimeChannel petChannel;
  late RealtimeChannel pollChannel;

  late RealtimeChannel adoptionChannel;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
      context.read<PetRepository>().fetchPetById(widget.pet.id);
      context.read<PetRepository>().getPoll(widget.pet.id);
      _initializeRealtime();
    });
  }

  void _initializeRealtime() {
    // Listen for updates on this specific pet row
    petChannel = supabase.channel('public:pets:id=eq.${widget.pet.id}');
    petChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pets',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.pet.id,
          ),
          callback: (_) {
            if (!mounted) return;
            context.read<PetRepository>().fetchPetById(widget.pet.id);
          },
        )
        .subscribe();
    pollChannel = supabase.channel('public:poll:pet=eq.${widget.pet.id}');
    pollChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'poll',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'pet',
            value: widget.pet.id,
          ),
          callback: (_) {
            if (!mounted) return;
            context.read<PetRepository>().getPoll(widget.pet.id);
          },
        )
        .subscribe();

    // Listen for adoption applications/changes for this pet
    adoptionChannel = supabase.channel(
      'public:adoption:pet=eq.${widget.pet.id}',
    );
    adoptionChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'adoption',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'pet',
            value: widget.pet.id,
          ),
          callback: (_) {
            if (!mounted) return;
            context.read<PetRepository>().fetchPetById(widget.pet.id);
          },
        )
        .subscribe();
  }

  // Friendly formatters
  // _formatDateTime removed in favor of _formatAddedAt

  String _formatAddedAt(DateTime dt) {
    // Friendly date like: Oct 20, 2025 · 3:42 PM
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[dt.month - 1];
    return '$m ${dt.day}, ${dt.year}';
  }

  Future<void> cancelAdoption() async {
    // Execute API call while showing loading; this expects a Future, not a callback
    final result = await LoadingService.showWhileExecuting(
      context,
      AdoptionProvider().cancelAdoption(
        userId: USER_ID ?? '',
        petId: widget.pet.id,
      ),
    );

    if (!mounted) return;

    // Show feedback and refresh pet data
    if (result.isError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adoption application cancelled successfully'),
        ),
      );
      context.read<PetRepository>().fetchPetById(widget.pet.id);
    }
  }

  Future<void> _confirmCancelAdoption() async {
    if (!mounted) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cancel adoption?'),
          content: Text(
            'Are you sure you want to cancel your adoption application for ${widget.pet.name.isEmpty ? 'No name' : widget.pet.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep Application'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: PawsColors.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel Application'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await cancelAdoption();
    }
  }
  // Deprecated row layout kept removed in favor of card grid UI

  Widget _buildDetailsGrid(Pet pet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        const double spacing = 12;
        // 2 columns by default on phones
        final double tileWidth = (totalWidth - spacing) / 2;

        Widget tile(
          IconData icon,
          String label,
          String value, {
          Color? iconBg,
          Color? iconColor,
        }) {
          if (value.trim().isEmpty) return const SizedBox.shrink();
          return Container(
            width: tileWidth,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PawsColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (iconBg ?? PawsColors.primary).withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: iconColor ?? PawsColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PawsText(
                        label,
                        fontSize: 12,
                        color: PawsColors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      PawsText(
                        value,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PawsColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        Widget boolTile(
          IconData icon,
          String label,
          bool value, {
          Color? trueColor,
          Color? falseColor,
        }) {
          final bool yes = value;
          final Color bg = (yes
              ? (trueColor ?? PawsColors.success)
              : (falseColor ?? PawsColors.error));
          return Container(
            width: tileWidth,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PawsColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: bg.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: bg),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PawsText(
                        label,
                        fontSize: 12,
                        color: PawsColors.textSecondary,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: bg.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: bg.withValues(alpha: 0.25)),
                        ),
                        child: PawsText(
                          yes ? 'Yes' : 'No',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: bg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        Widget sectionHeader(String title, IconData icon) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Row(
              children: [
                Icon(icon, size: 16, color: PawsColors.primary),
                const SizedBox(width: 8),
                PawsText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PawsColors.textPrimary,
                ),
              ],
            ),
          );
        }

        final basics = [
          tile(Icons.badge, 'ID', pet.id.toString()),
          tile(Icons.event, 'Added At', _formatAddedAt(pet.createdAt)),
          tile(Icons.category, 'Type', pet.type),
          tile(Icons.label, 'Breed', pet.breed),
          tile(Icons.cake, 'Date of Birth', _formatAddedAt(pet.dateOfBirth)),
          tile(Icons.straighten, 'Size', pet.size),
          tile(Icons.palette, 'Color', pet.color ?? ''),
        ];

        final health = [
          boolTile(Icons.health_and_safety, 'Vaccinated', pet.isVaccinated),
          // Use gender-aware label for spay/neuter
          () {
            final genderLower = pet.gender.toLowerCase();
            final label = genderLower.contains('female')
                ? 'Spayed'
                : genderLower.contains('male')
                ? 'Neutered'
                : 'Spayed/Neutered';
            return boolTile(Icons.content_cut, label, pet.isSpayedOrNeutured);
          }(),
          boolTile(Icons.school, 'Trained', pet.isTrained),
          tile(Icons.favorite, 'Health Status', pet.healthStatus),
          tile(Icons.warning_amber, 'Special Needs', pet.specialNeeds),
        ];

        final adoption = [
          tile(
            Icons.verified,
            'Adopted',
            pet.adopted != null
                ? 'Yes${pet.adopted!.user.userIdentification != null ? ' by ${pet.adopted!.user.userIdentification!.firstName} ${pet.adopted!.user.userIdentification!.lastName}' : ''}'
                : 'No',
          ),
          tile(
            Icons.volunteer_activism,
            'Applications',
            (pet.adoption?.length ?? 0).toString(),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionHeader('Basics', Icons.pets),
            Wrap(spacing: spacing, runSpacing: spacing, children: basics),
            sectionHeader('Health & Care', Icons.local_hospital),
            Wrap(spacing: spacing, runSpacing: spacing, children: health),
            sectionHeader('Adoption', Icons.volunteer_activism),
            Wrap(spacing: spacing, runSpacing: spacing, children: adoption),
          ],
        );
      },
    );
  }

  Widget _buildAttributesCard(Pet pet) {
    IconData genderIcon = Icons.wc;
    final genderLower = pet.gender.toLowerCase();
    if (genderLower.contains('male')) genderIcon = Icons.male;
    if (genderLower.contains('female')) genderIcon = Icons.female;
    // Gender-aware spay/neuter text
    final String spayNeuterText = pet.isSpayedOrNeutured
        ? (genderLower.contains('female')
              ? 'Spayed'
              : genderLower.contains('male')
              ? 'Neutered'
              : 'Fixed')
        : (genderLower.contains('female')
              ? 'Not Spayed'
              : genderLower.contains('male')
              ? 'Not Neutered'
              : 'Intact');

    Widget attr(IconData icon, String label) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: PawsColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: PawsColors.primary),
            ),
            const SizedBox(height: 6),
            PawsText(label, fontSize: 12, color: PawsColors.textPrimary),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: PawsColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          attr(
            Icons.health_and_safety,
            pet.isVaccinated ? 'Vaccinated' : 'Not Vaccinated',
          ),
          attr(genderIcon, pet.gender),
          attr(Icons.verified, spayNeuterText),
          attr(Icons.monitor_weight, pet.weight),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Unsubscribe realtime channels
    petChannel.unsubscribe();
    adoptionChannel.unsubscribe();
    pollChannel.unsubscribe();
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
    // Attributes card shows key facts in a compact row
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
            context.read<PetRepository>().getPoll(widget.pet.id);
          },
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
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
                          pet.name.isEmpty ? 'No name' : pet.name,
                          fontSize: 18,
                          color: pet.name.isEmpty
                              ? PawsColors.textSecondary
                              : PawsColors.textPrimary,
                        ),

                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 15,
                              color: PawsColors.primaryDark,
                            ),
                            const SizedBox(width: 6),
                            PawsText(
                              pet.rescueAddress,
                              fontSize: 15,
                              color: PawsColors.textSecondary,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        if ((pet.name.isEmpty) && USER_ID != null)
                          _PollCard(petId: widget.pet.id),
                        SizedBox(height: 18),
                        _buildAttributesCard(pet),
                        SizedBox(height: 8),
                        PawsText('Good with:'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pet.goodWith
                              .map(
                                (e) => Chip(
                                  label: PawsText(
                                    e,
                                    fontSize: 12,
                                    color: PawsColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: PawsColors.primary),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  backgroundColor: PawsColors.primary
                                      .withValues(alpha: 0.1),
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
                                    '${pet.name.isEmpty ? 'No name' : pet.name} has been adopted!',
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
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
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
                                        pet.adopted!.user.id ==
                                            adoption.user.id)
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

                        // All details section
                        Divider(thickness: 2, color: PawsColors.border),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.info,
                              size: 18,
                              color: PawsColors.primary,
                            ),
                            SizedBox(width: 8),
                            PawsText(
                              'All Pet Details',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PawsColors.textPrimary,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _buildDetailsGrid(pet),
                      ],
                    ),
                  ),
                ],
              ),
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

              PawsElevatedButton(
                label:
                    (pet.adopted == null &&
                        (pet.adoption ?? []).any((e) => e.user.id == USER_ID))
                    ? 'Cancel Adoption'
                    : 'Adopt Now',
                backgroundColor:
                    (!(pet.adoption ?? []).any((e) => e.user.id == USER_ID)) &&
                        pet.adopted == null &&
                        user != null &&
                        user.status == UserStatus.FULLY_VERIFIED
                    ? PawsColors.primary
                    : (pet.adopted == null &&
                          (pet.adoption ?? []).any((e) => e.user.id == USER_ID))
                    ? PawsColors.error
                    : PawsColors.disabled,
                onPressed:
                    (pet.adopted == null &&
                        (pet.adoption ?? []).any((e) => e.user.id == USER_ID))
                    // User already applied -> confirm then cancel
                    ? () => _confirmCancelAdoption()
                    // Else if eligible -> allow adoption
                    : ((!(pet.adoption ?? []).any(
                            (e) => e.user.id == USER_ID,
                          )) &&
                          pet.adopted == null &&
                          user != null &&
                          user.status == UserStatus.FULLY_VERIFIED)
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

class _PollCard extends StatefulWidget {
  final int petId;
  const _PollCard({required this.petId});

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  int? _votingPollId;
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _vote(Poll poll) async {
    if (_votingPollId != null) return; // prevent multi-tap
    setState(() => _votingPollId = poll.id);
    try {
      await supabase.rpc(
        'toggle_pet_name_vote',
        params: {'p_poll_row_id': poll.id, 'p_user_id': USER_ID ?? ''},
      );
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      debugPrint('$e');
    } finally {
      if (mounted) setState(() => _votingPollId = null);
    }
  }

  Future<void> _addSuggestion() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await PetProvider().addPoll(
        pet: widget.petId,
        suggestedName: text,
        createdBy: USER_ID ?? '',
      );
      if (!mounted) return;
      if (result.isSuccess) {
        _controller.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Suggested name added')));
        context.read<PetRepository>().getPoll(widget.petId);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add suggestion: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future removeSuggestion(int pollId) async {
    final result = await PetProvider().deletePollSuggestion(pollId: pollId);

    if (!mounted) return;
    if (result.isSuccess) {
      _controller.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Suggested name removed')));
      context.read<PetRepository>().getPoll(widget.petId);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Poll> polls = context.watch<PetRepository>().poll ?? <Poll>[];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PawsColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Icon(LucideIcons.vote, size: 18, color: PawsColors.primary),
              const SizedBox(width: 8),
              PawsText(
                'Help name this pet',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Suggest a name',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: PawsColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PawsColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PawsColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _addSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Suggest'),
                ),
              ),
            ],
          ),
          if (polls.isNotEmpty)
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: polls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final p = polls[index];
                final isVoting = _votingPollId == p.id;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: PawsColors.surface,
                    border: Border.all(color: PawsColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PawsText(
                              p.suggestedName,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: PawsColors.textPrimary,
                            ),
                            const SizedBox(height: 2),
                            PawsText(
                              '${p.votes?.length ?? 0} votes',
                              fontSize: 12,
                              color: PawsColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 34,
                        child: OutlinedButton(
                          onPressed: isVoting ? null : () => _vote(p),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: PawsColors.primary),
                            foregroundColor: PawsColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: isVoting
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      PawsColors.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  (p.votes ?? []).any((e) => e == USER_ID)
                                      ? 'Unvote'
                                      : 'Vote',
                                ),
                        ),
                      ),
                      if (p.createdBy == USER_ID) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            debugPrint('Delete poll ${p.id}');
                            removeSuggestion(p.id);
                          },
                          child: Icon(
                            LucideIcons.x,
                            size: 18,
                            color: PawsColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
