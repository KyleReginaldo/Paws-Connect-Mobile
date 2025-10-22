import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/adoption/models/adoption_model.dart';
import 'package:paws_connect/flavors/flavor_config.dart';

import '../../../core/config/result.dart';
import '../../../core/dto/adoption.dto.dart';

class AdoptionProvider {
  Future<Result<String>> submitAdoptionApplication({
    required AdoptionApplicationDTO application,
  }) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/adoption'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(application.toMap()),
    );
    if (response.statusCode == 201) {
      return Result.success('Adoption application submitted successfully');
    } else {
      return Result.error('Failed to submit adoption application');
    }
  }

  Future<Result<String>> cancelAdoption({
    required String userId,
    required int petId,
  }) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/adoption/cancel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pet': petId, 'user': userId}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Result.success('Adoption application cancelled successfully');
    } else {
      return Result.error('Failed to cancel adoption application');
    }
  }

  Future<Result<List<Adoption>>> fetchUserAdoptions(String userId) async {
    debugPrint('calling fetchUserAdoptions for userId: $userId');
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/$userId/adoption'),
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
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/adoption/$id'),
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
