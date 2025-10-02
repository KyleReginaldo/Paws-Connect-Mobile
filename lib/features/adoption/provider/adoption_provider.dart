import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/adoption/models/adoption_model.dart';

import '../../../core/config/result.dart';
import '../../../core/dto/adoption.dto.dart';

class AdoptionProvider {
  Future<Result<String>> submitAdoptionApplication({
    required AdoptionApplicationDTO application,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/adoption'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(application.toMap()),
    );
    if (response.statusCode == 201) {
      return Result.success('Adoption application submitted successfully');
    } else {
      return Result.error('Failed to submit adoption application');
    }
  }

  Future<Result<List<Adoption>>> fetchUserAdoptions(String userId) async {
    debugPrint('calling fetchUserAdoptions for userId: $userId');
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/users/$userId/adoption'),
    );
    debugPrint('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      debugPrint(response.body);

      final data = jsonDecode(response.body);
      List<Adoption> adoptions = [];
      for (var item in data['data']) {
        adoptions.add(AdoptionMapper.fromMap(item));
      }
      return Result.success(adoptions);
    } else {
      return Result.error('Failed to fetch user adoptions');
    }
  }

  Future<Result<Adoption>> fetchAdoptionDetail(int id) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/adoption/$id'),
    );
    if (response.statusCode == 200) {
      debugPrint(response.body);

      final data = jsonDecode(response.body);
      return Result.success(AdoptionMapper.fromMap(data['data']));
    } else {
      return Result.error('Failed to fetch adoption details');
    }
  }
}
