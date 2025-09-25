import 'package:flutter/material.dart';
import 'package:paws_connect/features/favorite/models/favorite_model.dart';
import 'package:paws_connect/features/favorite/provider/favorite_provider.dart';

class FavoriteRepository extends ChangeNotifier {
  final FavoriteProvider provider;

  FavoriteRepository({required this.provider});

  List<Favorite>? _favorites;
  List<Favorite>? get favorites => _favorites;

  void getFavorites(String userId) async {
    final result = await provider.fetchFavorites(userId);
    if (result.isError) {
      _favorites = null;
      notifyListeners();
    } else {
      _favorites = result.value;
      notifyListeners();
    }
  }
}
