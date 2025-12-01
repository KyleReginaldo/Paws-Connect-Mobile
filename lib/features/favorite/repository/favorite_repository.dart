import 'package:flutter/material.dart';
import 'package:paws_connect/features/favorite/models/favorite_model.dart';
import 'package:paws_connect/features/favorite/provider/favorite_provider.dart';

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

  // Optimistically remove favorite from local list and return it for revert
  Favorite? removeFavoriteLocally(int petId) {
    if (_favorites == null) return null;

    final index = _favorites!.indexWhere((f) => f.pet.id == petId);
    if (index == -1) return null;
    final removed = _favorites!.removeAt(index);
    notifyListeners();
    return removed;
  }

  // Add favorite back to local list (for revert on error)
  void addFavoriteLocally(Favorite favorite) {
    if (_favorites == null) {
      _favorites = [favorite];
    } else {
      _favorites!.add(favorite);
    }
    notifyListeners();
  }

  void reset() {
    _favorites = null;
    notifyListeners();
  }
}
