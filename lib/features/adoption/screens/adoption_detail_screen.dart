// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:provider/provider.dart';

import '../../../dependency.dart';
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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(PawsColors.primary),
          ),
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
                _buildAdoptionHeader(adoption),
                const SizedBox(height: 20),
                _buildApplicantCard(adoption),
                const SizedBox(height: 16),
                _buildHouseholdDetailsCard(adoption),
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
                items: adoption.pets.photos.map((e) {
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
                  autoPlay: adoption.pets.photos.length > 1,
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
                        adoption.pets.name,
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
                  '${adoption.pets.breed} • ${adoption.pets.age} year${adoption.pets.age > 1 ? 's' : ''} old',
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
          _buildInfoRow('Type of Residence', adoption.typeOfResidence),
          const SizedBox(height: 12),
          _buildInfoRow('Is Renting', adoption.isRenting ? 'Yes' : 'No'),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Household Members',
            adoption.numberOfHouseholdMembers.toString(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Has Children',
            adoption.hasChildrenInHome ? 'Yes' : 'No',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Has Other Pets',
            adoption.hasOtherPetsInHome ? 'Yes' : 'No',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Has Outdoor Space',
            adoption.haveOutdoorSpace ? 'Yes' : 'No',
          ),
          if (adoption.isRenting) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Landlord Permission',
              adoption.havePermissionFromLandlord ? 'Yes' : 'No',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetDetailsCard(pet) {
    return _buildCard(
      title: 'Pet Information',
      icon: LucideIcons.heart,
      child: Column(
        children: [
          _buildInfoRow('Name', pet.name),
          const SizedBox(height: 12),
          _buildInfoRow('Breed', pet.breed),
          const SizedBox(height: 12),
          _buildInfoRow('Age', '${pet.age} year${pet.age > 1 ? 's' : ''} old'),
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
}
