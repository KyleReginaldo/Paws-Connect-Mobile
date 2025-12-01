import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:paws_connect/core/services/supabase_service.dart';

import '../../../core/config/result.dart';
import '../../../core/supabase/client.dart';
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

  Future<Result<String>> toggleFavorite(int petId) async {
    final userId = USER_ID;
    if (userId == null || userId.isEmpty) {
      return Result.error('User not logged in');
    }
    final result = await supabase
        .from('favorites')
        .select()
        .eq('user', userId)
        .eq('pet', petId);
    if (result.isEmpty) {
      // Add to favorites
      await supabase.from('favorites').insert({'pet': petId, 'user': userId});
      return Result.success('Added to favorites');
    } else {
      await supabase
          .from('favorites')
          .delete()
          .eq('user', userId)
          .eq('pet', petId);
      return Result.success('Removed from favorites');
    }
  }
}
