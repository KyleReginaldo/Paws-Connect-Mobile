import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/favorite/models/favorite_model.dart';
import 'package:paws_connect/features/favorite/provider/favorite_provider.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';

class FavoriteRepository extends ChangeNotifier {
  final FavoriteProvider provider;

  FavoriteRepository({required this.provider});

  List<Favorite>? _favorites;
  List<Favorite>? get favorites => _favorites;

  Future<void> getFavorites(String userId) async {
    final result = await provider.fetchFavorites(userId);
    if (result.isError) {
      _favorites = null;
      notifyListeners();
    } else {
      _favorites = result.value;
      notifyListeners();
    }
  }

  void reset() {
    _favorites = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(int petId) async {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) return;

    // Determine current state
    final isCurrentlyFav = _favorites?.any((f) => f.pet.id == petId) ?? false;

    // Optimistic UI update for pet lists only once here
    sl<PetRepository>().updatePetFavorite(petId, !isCurrentlyFav);

    if (isCurrentlyFav) {
      // Find favorite id
      final fav = _favorites?.firstWhere((f) => f.pet.id == petId);
      if (fav == null) return;
      final res = await provider.removeFavorite(fav.id);
      if (res.isError) {
        // rollback
        sl<PetRepository>().updatePetFavorite(petId, true);
        return;
      }
    } else {
      final res = await provider.addFavorite(petId, userId);
      if (res.isError) {
        // rollback
        sl<PetRepository>().updatePetFavorite(petId, false);
        return;
      }
    }

    // Refresh favorites list quietly
    await getFavorites(userId);
    // After refresh, ensure pet repository list still reflects favorite status
    final stillFav = _favorites?.any((f) => f.pet.id == petId) ?? false;
    sl<PetRepository>().updatePetFavorite(petId, stillFav);
  }
}
