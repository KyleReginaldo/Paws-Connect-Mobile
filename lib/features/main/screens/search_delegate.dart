import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';

import '../../../core/router/app_route.gr.dart';
// Removed provider dependency; delegate receives repository directly

class PetSearchDelegate extends SearchDelegate<Pet?> {
  final PetRepository repo;
  final String? userId;
  PetSearchDelegate({required this.repo, this.userId});

  static const _minQueryLength = 2;
  bool _requestedOnce = false; // avoid duplicate call right after clear

  @override
  String? get searchFieldLabel => 'Search pets';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            repo.clearSearch();
            _requestedOnce = false;
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
      return _Hint(message: 'No pets found for "$query"');
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final pet = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(pet.photos.first),
            backgroundColor: Colors.grey.shade200,
          ),
          title: Text(pet.name),
          subtitle: Text(pet.breed),
          trailing: Icon(
            (pet.isFavorite ?? false) ? Icons.favorite : Icons.favorite_border,
            color: (pet.isFavorite ?? false) ? Colors.redAccent : null,
          ),
          onTap: () {
            close(context, pet);
            context.router.push(PetDetailRoute(pet: pet));
          },
        );
      },
    );
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
