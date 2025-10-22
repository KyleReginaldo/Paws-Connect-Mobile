// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/favorite/repository/favorite_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;

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
    PawsBottomSheet.show(
      context: context,
      child: _FilterBottomSheet(repository: repo),
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
        backgroundColor: Colors.white,
        title: const Text(
          'Pets',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: PawsColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            decoration: const BoxDecoration(color: Colors.white),
            child: _QuickFiltersBar(repo: repo),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: Icon(
                  LucideIcons.funnel,
                  color: hasActiveFilters
                      ? PawsColors.primary
                      : PawsColors.textSecondary,
                  size: 20,
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
          PopupMenuButton<String>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            icon: const Icon(
              LucideIcons.info,
              size: 20,
              color: PawsColors.textSecondary,
            ),
            onSelected: (value) {
              if (value == 'cat') {
                context.router.push(CatCareRoute());
              } else if (value == 'dog') {
                context.router.push(DogCareRoute());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'cat',
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      LucideIcons.cat,
                      size: 20,
                      color: PawsColors.textSecondary,
                    ),
                    Text('How to care of cats'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'dog',
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      LucideIcons.dog,
                      size: 20,
                      color: PawsColors.textSecondary,
                    ),
                    Text('How to care of dogs'),
                  ],
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
          : RefreshTrigger(
              onRefresh: () async {
                final repo = context.read<PetRepository>();
                repo.fetchPets(userId: USER_ID);
              },
              child: MasonryGridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // or make this dynamic if you like
                    ),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () =>
                              context.router.push(PetDetailRoute(pet: pet)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AspectRatio(
                                aspectRatio: 4 / 3,
                                child: NetworkImageView(
                                  pet.transformedPhotos.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  enableTapToView: false,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  12,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PawsText(
                                      pet.name.isEmpty
                                          ? 'No name'
                                          : pet.name.isEmpty
                                          ? 'No name'
                                          : pet.name.isEmpty
                                          ? 'No name'
                                          : pet.name,
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
                          onPressed: () =>
                              _toggleFavorite(pet.id, pet.isFavorite ?? false),
                          icon: Icon(
                            pet.isFavorite ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: PawsColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                color: PawsColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets,
                size: 72,
                color: PawsColors.primary.withValues(alpha: 0.6),
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

class _QuickFiltersBar extends StatelessWidget {
  final PetRepository repo;
  const _QuickFiltersBar({required this.repo});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _QuickChip(
        label: 'Dogs',
        icon: LucideIcons.dog,
        selected: repo.selectedType == 'Dog',
        onTap: () => _toggleType(context, 'Dog'),
      ),
      _QuickChip(
        label: 'Cats',
        icon: LucideIcons.cat,
        selected: repo.selectedType == 'Cat',
        onTap: () => _toggleType(context, 'Cat'),
      ),
      _QuickChip(
        label: 'Male',
        icon: LucideIcons.mars,
        selected: repo.selectedGender == 'Male',
        onTap: () => _toggleGender(context, 'Male'),
      ),
      _QuickChip(
        label: 'Female',
        icon: LucideIcons.venus,
        selected: repo.selectedGender == 'Female',
        onTap: () => _toggleGender(context, 'Female'),
      ),
      _QuickChip(
        label: 'Vaccinated',
        icon: LucideIcons.shieldCheck,
        selected: repo.isVaccinated == true,
        onTap: () => _toggleVaccinated(context),
      ),
      if (repo.hasActiveFilters)
        TextButton.icon(
          onPressed: () {
            final r = context.read<PetRepository>();
            r.updateTypeFilter(null);
            r.updateGenderFilter(null);
            r.updateSizeFilter(null);
            r.updateVaccinatedFilter(null);
            r.fetchPetsWithFilters();
          },
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear'),
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.expand((w) => [w, const SizedBox(width: 8)]).toList()
          ..removeLast(),
      ),
    );
  }

  void _toggleType(BuildContext context, String type) {
    final r = context.read<PetRepository>();
    final newValue = r.selectedType == type ? null : type;
    r.updateTypeFilter(newValue);
    r.fetchPetsWithFilters();
  }

  void _toggleGender(BuildContext context, String gender) {
    final r = context.read<PetRepository>();
    final newValue = r.selectedGender == gender ? null : gender;
    r.updateGenderFilter(newValue);
    r.fetchPetsWithFilters();
  }

  void _toggleVaccinated(BuildContext context) {
    final r = context.read<PetRepository>();
    final newValue = r.isVaccinated == true ? null : true;
    r.updateVaccinatedFilter(newValue);
    r.fetchPetsWithFilters();
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? PawsColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? PawsColors.primary : PawsColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: PawsColors.primary),
              const SizedBox(width: 6),
            ],
            Icon(
              icon,
              size: 14,
              color: selected ? PawsColors.primary : PawsColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? PawsColors.primary : PawsColors.textSecondary,
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
    final theme = shadcn.Theme.of(context);
    final hasActiveFilters =
        selectedType != null ||
        selectedGender != null ||
        selectedSize != null ||
        isVaccinated != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium drag handle with sophisticated glow

        // Enhanced header with animation
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Pets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.foreground,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Find your perfect companion',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PawsColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PawsColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Active filters applied',
                          style: TextStyle(
                            fontSize: 12,
                            color: PawsColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.border.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: shadcn.Button.ghost(
                  onPressed: _clearAllFilters,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.rotateCcw,
                        size: 14,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      const Text('Clear All'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Elegant divider with gradient
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                theme.colorScheme.border.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Filter Content with better spacing
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShadcnFilterSection(
                  'Pet Type',
                  Icons.pets_outlined,
                  _buildShadcnChipGroup(['Dog', 'Cat'], selectedType, (value) {
                    setState(
                      () => selectedType = selectedType == value ? null : value,
                    );
                  }),
                ),
                const SizedBox(height: 24),

                _buildShadcnFilterSection(
                  'Gender',
                  Icons.wc_outlined,
                  _buildShadcnChipGroup(['Male', 'Female'], selectedGender, (
                    value,
                  ) {
                    setState(
                      () => selectedGender = selectedGender == value
                          ? null
                          : value,
                    );
                  }),
                ),
                const SizedBox(height: 24),

                _buildShadcnFilterSection(
                  'Size',
                  Icons.straighten_outlined,
                  _buildShadcnChipGroup(
                    ['Small', 'Medium', 'Large'],
                    selectedSize,
                    (value) {
                      setState(
                        () =>
                            selectedSize = selectedSize == value ? null : value,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                _buildShadcnFilterSection(
                  'Vaccination Status',
                  Icons.medical_services_outlined,
                  _buildShadcnToggleGroup(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Modern bottom actions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.colorScheme.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: PawsColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: PawsColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildShadcnFilterSection(
    String title,
    IconData icon,
    Widget content,
  ) {
    final theme = shadcn.Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildShadcnChipGroup(
    List<String> options,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    final theme = shadcn.Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        PawsColors.primary,
                        PawsColors.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : theme.colorScheme.background,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? PawsColors.primary
                    : theme.colorScheme.border.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: PawsColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(LucideIcons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.foreground,
                    letterSpacing: isSelected ? 0.2 : 0,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShadcnToggleGroup() {
    final theme = shadcn.Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(
              () => isVaccinated = isVaccinated == true ? null : true,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isVaccinated == true
                    ? LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isVaccinated == true ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isVaccinated == true
                    ? [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isVaccinated == true
                          ? LucideIcons.check
                          : LucideIcons.circle,
                      key: ValueKey(isVaccinated == true),
                      size: 18,
                      color: isVaccinated == true
                          ? Colors.white
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isVaccinated == true
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isVaccinated == true
                          ? Colors.white
                          : theme.colorScheme.foreground,
                      letterSpacing: isVaccinated == true ? 0.2 : 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(
              () => isVaccinated = isVaccinated == false ? null : false,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isVaccinated == false
                    ? LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isVaccinated == false ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isVaccinated == false
                    ? [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isVaccinated == false
                          ? LucideIcons.x
                          : LucideIcons.circle,
                      key: ValueKey(isVaccinated == false),
                      size: 18,
                      color: isVaccinated == false
                          ? Colors.white
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isVaccinated == false
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isVaccinated == false
                          ? Colors.white
                          : theme.colorScheme.foreground,
                      letterSpacing: isVaccinated == false ? 0.2 : 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
