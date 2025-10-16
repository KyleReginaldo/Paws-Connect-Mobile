import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/result.dart';
import '../../../flavors/flavor_config.dart';
import '../models/favorite_model.dart';

class FavoriteProvider {
  Future<Result<List<Favorite>>> fetchFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/favorites/user/$userId'),
    ); // Replace with actual API endpoint

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Favorite> favorites = [];
      for (var item in data['data']) {
        favorites.add(FavoriteMapper.fromMap(item));
      }
      return Result.success(favorites);
    } else {
      return Result.error('Failed to fetch favorites');
    }
  }

  Future<Result<void>> addFavorite(int pet, String user) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/favorites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': user, 'pet': pet}),
    ); // Replace with actual API endpoint

    if (response.statusCode == 201) {
      return Result.success(null);
    } else {
      return Result.error('Failed to add favorite');
    }
  }

  Future<Result<void>> removeFavorite(int favoriteId) async {
    final response = await http.delete(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/favorites/$favoriteId'),
    ); // Replace with actual API endpoint

    if (response.statusCode == 200) {
      return Result.success(null);
    } else {
      return Result.error('Failed to remove favorite');
    }
  }
}
