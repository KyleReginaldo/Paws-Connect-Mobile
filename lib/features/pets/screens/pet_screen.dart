import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/favorite/repository/favorite_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../../../dependency.dart';
import '../repository/pet_repository.dart';

@RoutePage()
class PetScreen extends StatefulWidget implements AutoRouteWrapper {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<PetRepository>(),
      child: this,
    );
  }
}

class _PetScreenState extends State<PetScreen> {
  @override
  void initState() {
    super.initState();
    // Defer fetching pets until after the first frame is drawn to avoid
    // calling notifyListeners (which triggers widget rebuilds) during the
    // ancestor widget build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use read instead of watch to avoid registering this callback as a listener
      // and to ensure we only call fetch once after mount.
      final repo = context.read<PetRepository>();
      repo.fetchPets(userId: USER_ID);
    });
  }

  void _showFilterBottomSheet() {
    final repo = context.read<PetRepository>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(repository: repo),
    );
  }

  void _toggleFavorite(int petId, bool isCurrentlyFavorite) async {
    if (USER_ID == null || (USER_ID?.isEmpty ?? true)) {
      if (!mounted) return;
      context.router.push(
        SignInRoute(
          onResult: (success) {
            if (!mounted) return;
            if (success) {
              // Refresh pets to reflect favorites after sign-in
              context.read<PetRepository>().fetchPets(userId: USER_ID);
            }
          },
        ),
      );
      return;
    }

    final repo = context.read<PetRepository>();
    // Avoid duplicate optimistic flip; FavoriteRepository manages it
    try {
      await sl<FavoriteRepository>().toggleFavorite(petId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isCurrentlyFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
        ),
      );
    } catch (e) {
      // Rollback in case repository optimistic failed
      repo.updatePetFavorite(petId, isCurrentlyFavorite);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<PetRepository>();
    final pets = repo.pets;
    final isLoading = repo.isLoading;
    final hasActiveFilters = repo.hasActiveFilters;

    return Scaffold(
      appBar: AppBar(
        title: const PawsText(
          'Pet',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: Icon(
                  Icons.filter_list,
                  color: hasActiveFilters ? PawsColors.primary : Colors.grey,
                ),
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: PawsColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pets == null || pets.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                final repo = context.read<PetRepository>();
                repo.fetchPets(userId: USER_ID);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth;
                    // minimal desired item width (adjustable)
                    const double minItemWidth = 160;
                    const double spacing = 12;
                    final int columns = (maxWidth / (minItemWidth + spacing))
                        .floor()
                        .clamp(1, 4);
                    final double itemWidth =
                        (maxWidth - (columns - 1) * spacing) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: List.generate(pets.length, (index) {
                        final pet = pets[index];
                        return SizedBox(
                          width: itemWidth,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    context.router.push(
                                      PetDetailRoute(pet: pet),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Image area with fixed aspect ratio
                                      AspectRatio(
                                        aspectRatio: 4 / 3,
                                        child: NetworkImageView(
                                          pet.photos.first,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          enableTapToView: false,
                                        ),
                                      ),
                                      // Text content
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          8,
                                          12,
                                          12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            PawsText(
                                              pet.name,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            PawsText(
                                              pet.breed,
                                              fontSize: 12,
                                              color: PawsColors.textSecondary,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
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
                                  onPressed: () {
                                    _toggleFavorite(
                                      pet.id,
                                      pet.isFavorite ?? false,
                                    );
                                  },
                                  icon: Icon(
                                    pet.isFavorite ?? false
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: PawsColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final repo = context.read<PetRepository>();
    final hasActiveFilters = repo.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PawsColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets,
                size: 72,
                color: PawsColors.primary.withOpacity(0.6),
              ),
            ),

            SizedBox(height: 24),

            PawsText(
              hasActiveFilters
                  ? 'No pets match your filters'
                  : 'No pets available',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            PawsText(
              hasActiveFilters
                  ? 'Try adjusting your search criteria to see more pets'
                  : 'Check back later for new furry friends looking for homes',
              fontSize: 14,
              color: PawsColors.textSecondary,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            if (hasActiveFilters)
              ElevatedButton.icon(
                onPressed: () {
                  repo.clearAllFilters();
                  repo.fetchPets(userId: USER_ID);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawsColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: Icon(Icons.clear_all),
                label: PawsText(
                  'Clear Filters',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  final repo = context.read<PetRepository>();
                  repo.fetchPets(userId: USER_ID);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: PawsColors.primary),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: Icon(Icons.refresh, color: PawsColors.primary),
                label: PawsText(
                  'Refresh',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PawsColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final PetRepository repository;

  const _FilterBottomSheet({required this.repository});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? selectedType;
  late String? selectedGender;
  late String? selectedSize;
  late bool? isVaccinated;

  @override
  void initState() {
    super.initState();
    selectedType = widget.repository.selectedType;
    selectedGender = widget.repository.selectedGender;
    selectedSize = widget.repository.selectedSize;
    isVaccinated = widget.repository.isVaccinated;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PawsText(
                    'Filter Pets',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PawsColors.textPrimary,
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: PawsColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      'Pet Type',
                      Icons.pets,
                      _buildOptionGrid(['Dog', 'Cat'], selectedType, (value) {
                        setState(
                          () => selectedType = selectedType == value
                              ? null
                              : value,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildFilterSection(
                      'Gender',
                      Icons.wc,
                      _buildOptionGrid(['Male', 'Female'], selectedGender, (
                        value,
                      ) {
                        setState(
                          () => selectedGender = selectedGender == value
                              ? null
                              : value,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildFilterSection(
                      'Size',
                      Icons.straighten,
                      _buildOptionGrid(
                        ['Small', 'Medium', 'Large'],
                        selectedSize,
                        (value) {
                          setState(
                            () => selectedSize = selectedSize == value
                                ? null
                                : value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFilterSection(
                      'Vaccination Status',
                      Icons.medical_services_outlined,
                      _buildToggleOption('Vaccinated', isVaccinated, (value) {
                        setState(
                          () => isVaccinated = isVaccinated == value
                              ? null
                              : value,
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: PawsColors.primary, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: PawsText(
                        'Cancel',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PawsColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawsColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedType = null;
      selectedGender = null;
      selectedSize = null;
      isVaccinated = null;
    });
  }

  void _applyFilters() {
    widget.repository.updateTypeFilter(selectedType);
    widget.repository.updateGenderFilter(selectedGender);
    widget.repository.updateSizeFilter(selectedSize);
    widget.repository.updateVaccinatedFilter(isVaccinated);

    Navigator.pop(context);
    widget.repository.fetchPetsWithFilters();
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: PawsColors.primary),
            SizedBox(width: 8),
            PawsText(
              title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
            ),
          ],
        ),
        SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildOptionGrid(
    List<String> options,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedValue == option;

        return InkWell(
          onTap: () => onChanged(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? PawsColors.primary : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? PawsColors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: PawsText(
                option,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : PawsColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleOption(
    String label,
    bool? value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onChanged(true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: value == true ? PawsColors.primary : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value == true ? PawsColors.primary : Colors.grey[300]!,
                  width: value == true ? 2 : 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: value == true ? Colors.white : Colors.grey[400],
                    ),
                    SizedBox(width: 6),
                    PawsText(
                      'Yes',
                      fontSize: 14,
                      fontWeight: value == true
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: value == true
                          ? Colors.white
                          : PawsColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => onChanged(false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: value == false ? Colors.red : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value == false ? Colors.red : Colors.grey[300]!,
                  width: value == false ? 2 : 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 18,
                      color: value == false ? Colors.white : Colors.grey[400],
                    ),
                    SizedBox(width: 6),
                    PawsText(
                      'No',
                      fontSize: 14,
                      fontWeight: value == false
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: value == false
                          ? Colors.white
                          : PawsColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
