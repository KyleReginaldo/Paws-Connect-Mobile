import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

class PetProvider {
  Future<Result<List<Pet>>> fetchPets() async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/pets'),
    );
    if (response.statusCode == 200) {
      List<Pet> pets = [];
      final data = jsonDecode(response.body);
      data['data'].forEach((petData) {
        pets.add(PetMapper.fromMap(petData));
      });
      return Result.success(pets);
    } else {
      return Result.error('Failed to fetch pets');
    }
  }
}
