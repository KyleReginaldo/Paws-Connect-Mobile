// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../dependency.dart';
import '../../pets/models/pet_model.dart';
import '../../profile/models/user_profile_model.dart';
import '../models/adoption_model.dart';

@RoutePage()
class AdoptionDetailScreen extends StatefulWidget implements AutoRouteWrapper {
  final int id;
  const AdoptionDetailScreen({super.key, required this.id});

  @override
  State<AdoptionDetailScreen> createState() => _AdoptionDetailScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<AdoptionRepository>(),
      child: this,
    );
  }
}

class _AdoptionDetailScreenState extends State<AdoptionDetailScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdoptionRepository>().fetchAdoptionDetail(widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final adoption = context.select((AdoptionRepository bloc) => bloc.adoption);

    return Scaffold(
      backgroundColor: PawsColors.background,
      body: adoption == null
          ? _buildLoadingState()
          : _buildContent(context, adoption),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          PawsText(
            'Loading adoption details...',
            color: PawsColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, adoption) {
    return CustomScrollView(
      slivers: [
        // App Bar with Pet Image
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: PawsColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeroSection(adoption),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (adoption.adoptionForm != null) ...{
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open adoption form link
                      launchUrl(Uri.parse(adoption.adoptionForm!));
                    },
                    icon: const Icon(LucideIcons.fileText),
                    label: const Text('View Adoption Form'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawsColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                },

                _buildAdoptionHeader(adoption),
                const SizedBox(height: 20),
                _buildApplicantCard(adoption),
                const SizedBox(height: 16),
                _buildHouseholdDetailsCard(adoption),
                const SizedBox(height: 16),
                _buildAdoptionDetailsCard(adoption),
                const SizedBox(height: 16),
                _buildPetDetailsCard(adoption.pets),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(Adoption adoption) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Stack(
            children: [
              CarouselSlider(
                items: adoption.pets.transformedPhotos.map((e) {
                  return NetworkImageView(
                    width: MediaQuery.sizeOf(context).width,
                    e,
                    fit: BoxFit.cover,
                    enableTapToView: false,
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 280,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  autoPlay: adoption.pets.transformedPhotos.length > 1,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PawsColors.textPrimary.withValues(alpha: 0),
                        PawsColors.textPrimary.withValues(alpha: 0.3),
                        PawsColors.textPrimary.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PawsText(
                        adoption.pets.name ?? "Unnamed Pet",
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    _buildStatusBadge(adoption.status),
                  ],
                ),
                const SizedBox(height: 4),
                PawsText(
                  '${adoption.pets.breed} • ${adoption.pets.age}',
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: PawsText(
        status.capitalize(),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAdoptionHeader(adoption) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.clipboard, color: PawsColors.primary, size: 20),
              const SizedBox(width: 8),
              PawsText(
                'Adoption Application',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PawsText(
                'Application ID: ',
                fontSize: 14,
                color: PawsColors.textSecondary,
              ),
              PawsText(
                '#${adoption.id.toString().padLeft(6, '0')}',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              PawsText(
                'Submitted: ',
                fontSize: 14,
                color: PawsColors.textSecondary,
              ),
              PawsText(
                DateFormat('MMM dd, yyyy • hh:mm a').format(adoption.createdAt),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Adoption adoption) {
    return _buildCard(
      title: 'Applicant Information',
      icon: LucideIcons.user,
      child: Column(
        children: [
          _buildInfoRow('Username', adoption.users.username),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Application Status',
            adoption.status.capitalize(),
            valueColor: adoption.status.color,
          ),
          const SizedBox(height: 16),
          _buildHouseImagesSection(adoption.users),
        ],
      ),
    );
  }

  Widget _buildHouseholdDetailsCard(adoption) {
    return _buildCard(
      title: 'Household Details',
      icon: LucideIcons.house,
      child: Column(
        children: [
          _buildInfoRow(
            'Type of Residence',
            adoption.typeOfResidence ?? 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Is Renting',
            adoption.isRenting != null
                ? (adoption.isRenting! ? 'Yes' : 'No')
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Household Members',
            adoption.numberOfHouseholdMembers?.toString() ?? 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Has Children',
            adoption.hasChildrenInHome != null
                ? (adoption.hasChildrenInHome! ? 'Yes' : 'No')
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Has Other Pets',
            adoption.hasOtherPetsInHome != null
                ? (adoption.hasOtherPetsInHome! ? 'Yes' : 'No')
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Has Outdoor Space',
            adoption.haveOutdoorSpace != null
                ? (adoption.haveOutdoorSpace! ? 'Yes' : 'No')
                : 'Not specified',
          ),
          if (adoption.isRenting == true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Landlord Permission',
              adoption.havePermissionFromLandlord != null
                  ? (adoption.havePermissionFromLandlord! ? 'Yes' : 'No')
                  : 'Not specified',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdoptionDetailsCard(Adoption adoption) {
    // Only show if at least one new field has data
    final hasAdoptionDetails =
        adoption.reasonForAdopting?.isNotEmpty == true ||
        adoption.willingToVisitShelter != null ||
        adoption.willingToVisitAgain != null ||
        adoption.adoptingForSelf != null ||
        adoption.howCanYouGiveFurReverHome?.isNotEmpty == true ||
        adoption.whereDidYouHearAboutUs?.isNotEmpty == true;

    if (!hasAdoptionDetails) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      title: 'Adoption Details',
      icon: LucideIcons.clipboard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (adoption.reasonForAdopting?.isNotEmpty == true) ...[
            _buildInfoRow('Reason for Adopting', adoption.reasonForAdopting!),
            if (adoption.adoptingForSelf != null ||
                adoption.willingToVisitShelter != null ||
                adoption.willingToVisitAgain != null ||
                adoption.howCanYouGiveFurReverHome?.isNotEmpty == true ||
                adoption.whereDidYouHearAboutUs?.isNotEmpty == true)
              const SizedBox(height: 12),
          ],
          if (adoption.adoptingForSelf != null) ...[
            _buildInfoRow(
              'Adopting for Self',
              adoption.adoptingForSelf! ? 'Yes' : 'No',
            ),
            if (adoption.willingToVisitShelter != null ||
                adoption.willingToVisitAgain != null ||
                adoption.howCanYouGiveFurReverHome?.isNotEmpty == true ||
                adoption.whereDidYouHearAboutUs?.isNotEmpty == true)
              const SizedBox(height: 12),
          ],
          if (adoption.willingToVisitShelter != null) ...[
            _buildInfoRow(
              'Willing to Visit Shelter',
              adoption.willingToVisitShelter! ? 'Yes' : 'No',
            ),
            if (adoption.willingToVisitAgain != null ||
                adoption.howCanYouGiveFurReverHome?.isNotEmpty == true ||
                adoption.whereDidYouHearAboutUs?.isNotEmpty == true)
              const SizedBox(height: 12),
          ],
          if (adoption.willingToVisitAgain != null) ...[
            _buildInfoRow(
              'Willing to Visit Again',
              adoption.willingToVisitAgain! ? 'Yes' : 'No',
            ),
            if (adoption.howCanYouGiveFurReverHome?.isNotEmpty == true ||
                adoption.whereDidYouHearAboutUs?.isNotEmpty == true)
              const SizedBox(height: 12),
          ],
          if (adoption.howCanYouGiveFurReverHome?.isNotEmpty == true) ...[
            _buildInfoRow(
              'How Give Fur-ever Home',
              adoption.howCanYouGiveFurReverHome!,
            ),
            if (adoption.whereDidYouHearAboutUs?.isNotEmpty == true)
              const SizedBox(height: 12),
          ],
          if (adoption.whereDidYouHearAboutUs?.isNotEmpty == true) ...[
            _buildInfoRow(
              'Where Heard About Us',
              adoption.whereDidYouHearAboutUs!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetDetailsCard(Pet pet) {
    return _buildCard(
      title: 'Pet Information',
      icon: LucideIcons.heart,
      child: Column(
        children: [
          _buildInfoRow(
            'Name',
            pet.name?.isEmpty ?? true
                ? 'Unnamed Pet'
                : pet.name?.isEmpty ?? true
                ? 'Unnamed Pet'
                : pet.name?.isEmpty ?? true
                ? 'Unnamed Pet'
                : pet.name ?? 'Unnamed Pet',
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Breed', pet.breed),
          const SizedBox(height: 12),
          _buildInfoRow('Age', pet.age),
          const SizedBox(height: 12),
          _buildInfoRow('Gender', pet.gender),
          const SizedBox(height: 12),
          _buildInfoRow('Size', pet.size),
          const SizedBox(height: 12),
          _buildInfoRow('Weight', pet.weight),
          const SizedBox(height: 12),
          _buildInfoRow('Vaccinated', pet.isVaccinated ? 'Yes' : 'No'),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Spayed/Neutered',
            pet.isSpayedOrNeutured ? 'Yes' : 'No',
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Health Status', pet.healthStatus),
          if (pet.specialNeeds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Special Needs', pet.specialNeeds),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PawsColors.primary, size: 20),
              const SizedBox(width: 8),
              PawsText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PawsColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: PawsText(label, fontSize: 14, color: PawsColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: PawsText(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? PawsColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHouseImagesSection(UserProfile user) {
    if (user.houseImages == null || user.houseImages!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.house,
                color: PawsColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              PawsText(
                'House Images',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PawsColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.imageOff, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                PawsText(
                  'No house images provided',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.house, color: PawsColors.primary, size: 16),
            const SizedBox(width: 8),
            PawsText(
              'House Images (${user.houseImages!.length})',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PawsColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: user.houseImages!.length,
            itemBuilder: (context, index) {
              final imageUrl = user.houseImages![index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    // Show full screen image
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: NetworkImageView(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              right: 16,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageView(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
