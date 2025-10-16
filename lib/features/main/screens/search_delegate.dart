import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';
// Removed provider dependency; delegate receives repository directly

class PetSearchDelegate extends SearchDelegate<Pet?> {
  final PetRepository repo;
  final String? userId;
  PetSearchDelegate({required this.repo, this.userId});

  static const _minQueryLength = 2;
  bool _requestedOnce = false; // avoid duplicate call right after clear

  // Popular search suggestions
  static const List<String> _popularSearches = [
    'dog',
    'cat',
    'puppy',
    'kitten',
    'small breed',
    'large breed',
    'golden retriever',
    'labrador',
    'persian cat',
    'siamese',
    'rescue',
  ];

  // Quick filter options
  static const List<String> _quickFilters = [
    'Dogs',
    'Cats',
    'Puppies',
    'Senior',
    'Small',
    'Large',
    'Special needs',
  ];

  @override
  String? get searchFieldLabel => 'Search pets by name, breed, or type';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: PawsColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = '';
            repo.clearSearch();
            _requestedOnce = false;
            showSuggestions(context);
          },
        ),
      // Filter button
      IconButton(
        icon: const Icon(Icons.tune, color: Colors.white),
        onPressed: () => _showFilterDialog(context),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  void _trigger() {
    if (query.trim().length < _minQueryLength) {
      repo.clearSearch();
      return;
    }
    repo.searchPets(query.trim(), userId: userId ?? USER_ID);
  }

  @override
  Widget buildResults(BuildContext context) {
    _trigger();
    return _buildResultList(context, isResults: true);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (!_requestedOnce && query.trim().length >= _minQueryLength) {
      _requestedOnce = true;
      _trigger();
    } else if (query.trim().length < _minQueryLength) {
      _requestedOnce = false;
    }

    // Show suggestions when no query or short query
    if (query.trim().isEmpty) {
      return _buildSuggestionsView(context);
    }

    return _buildResultList(context, isResults: false);
  }

  Widget _buildResultList(BuildContext context, {required bool isResults}) {
    final searching = repo.isSearching;
    final results = repo.searchResults;

    if (query.trim().isEmpty) {
      return _Hint(message: 'Start typing to search pets');
    }
    if (query.trim().length < _minQueryLength) {
      return _Hint(message: 'Type at least $_minQueryLength characters');
    }
    if (searching && (results == null || results.isEmpty)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (results == null) {
      return const SizedBox();
    }
    if (results.isEmpty) {
      return _buildNoResultsView(context);
    }
    return Column(
      children: [
        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: PawsColors.background,
          child: Text(
            '${results.length} pet${results.length == 1 ? '' : 's'} found',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: PawsColors.textSecondary),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, index) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final pet = results[index];
              return _buildPetListTile(context, pet);
            },
          ),
        ),
      ],
    );
  }

  // Build suggestions view with popular searches and quick filters
  Widget _buildSuggestionsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick filters
          Text(
            'Quick Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickFilters.map((filter) {
              return ActionChip(
                label: Text(filter),
                onPressed: () {
                  query = filter.toLowerCase();
                  showResults(context);
                },
                backgroundColor: PawsColors.background,
                labelStyle: const TextStyle(color: PawsColors.textPrimary),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Popular searches
          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._popularSearches.map((search) {
            return ListTile(
              leading: const Icon(
                Icons.search,
                size: 20,
                color: PawsColors.textSecondary,
              ),
              title: Text(search),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                query = search;
                showResults(context);
              },
            );
          }),

          const SizedBox(height: 16),
          const _Hint(
            message:
                'Start typing to search for specific pets by name, breed, or characteristics',
          ),
        ],
      ),
    );
  }

  // Build enhanced pet list tile
  Widget _buildPetListTile(BuildContext context, Pet pet) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Hero(
        tag: 'pet-${pet.id}',
        child: CircleAvatar(
          radius: 28,
          backgroundImage: pet.transformedPhotos.isNotEmpty
              ? NetworkImage(pet.transformedPhotos.first)
              : null,
          backgroundColor: PawsColors.background,
          child: pet.transformedPhotos.isEmpty
              ? const Icon(Icons.pets, color: PawsColors.textSecondary)
              : null,
        ),
      ),
      title: Text(
        pet.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: PawsColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${pet.breed} • ${pet.gender} • ${pet.age} ${pet.age == 1 ? 'year' : 'years'} old',
            style: const TextStyle(color: PawsColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(pet.type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pet.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (pet.specialNeeds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PawsColors.info,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SPECIAL NEEDS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        (pet.isFavorite ?? false) ? Icons.favorite : Icons.favorite_border,
        color: (pet.isFavorite ?? false)
            ? PawsColors.error
            : PawsColors.textSecondary,
      ),
      onTap: () {
        close(context, pet);
        context.router.push(PetDetailRoute(pet: pet));
      },
    );
  }

  // Build no results view
  Widget _buildNoResultsView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: PawsColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No pets found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PawsColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for different terms like "dog", "cat", or a specific breed.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: PawsColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PawsColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter functionality coming soon!'),
            SizedBox(height: 16),
            Text('You\'ll be able to filter by:'),
            SizedBox(height: 8),
            Text('• Pet type (Dog, Cat, etc.)'),
            Text('• Age range'),
            Text('• Size'),
            Text('• Special needs'),
            Text('• Location distance'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to get type color
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return PawsColors.primary;
      case 'cat':
        return PawsColors.secondary;
      case 'bird':
        return PawsColors.info;
      case 'rabbit':
        return PawsColors.success;
      default:
        return PawsColors.textSecondary;
    }
  }
}

class _Hint extends StatelessWidget {
  final String message;
  const _Hint({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: PawsColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
