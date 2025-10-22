import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

import '../../../flavors/flavor_config.dart';

class PetProvider {
  Future<Result<List<Pet>>> fetchPets({
    String? userId,
    String? type,
    String? breed,
    String? gender,
    String? size,
    int? ageMin,
    int? ageMax,
    bool? isVaccinated,
    bool? isSpayedOrNeutered,
    bool? isTrained,
    String? healthStatus,
    String? requestStatus,
    String? goodWith,
    String? location,
  }) async {
    final Map<String, String> queryParams = {};

    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (breed != null && breed.isNotEmpty) queryParams['breed'] = breed;
    if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
    if (size != null && size.isNotEmpty) queryParams['size'] = size;
    if (ageMin != null) queryParams['age_min'] = ageMin.toString();
    if (ageMax != null) queryParams['age_max'] = ageMax.toString();
    if (isVaccinated != null) {
      queryParams['is_vaccinated'] = isVaccinated.toString();
    }
    if (isSpayedOrNeutered != null) {
      queryParams['is_spayed_or_neutured'] = isSpayedOrNeutered.toString();
    }
    if (isTrained != null) queryParams['is_trained'] = isTrained.toString();
    if (healthStatus != null && healthStatus.isNotEmpty) {
      queryParams['health_status'] = healthStatus;
    }
    if (requestStatus != null && requestStatus.isNotEmpty) {
      queryParams['request_status'] = requestStatus;
    }
    if (goodWith != null && goodWith.isNotEmpty) {
      queryParams['good_with'] = goodWith;
    }
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    if (userId != null && userId.isNotEmpty) queryParams['user'] = userId;

    final uri = Uri.parse(
      '${FlavorConfig.instance.apiBaseUrl}/pets',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<Pet> pets = [];
      final data = jsonDecode(response.body);
      data['data'].forEach((petData) {
        pets.add(PetMapper.fromMap(petData));
      });
      return Result.success(pets);
    } else {
      return Result.error(
        'Failed to fetch pets. Server returned ${response.statusCode}',
      );
    }
  }

  Future<Result<List<Pet>>> fetchRecentPets({String? userId}) async {
    final uri = Uri.parse('${FlavorConfig.instance.apiBaseUrl}/pets/recent')
        .replace(
          queryParameters: userId != null && userId.isNotEmpty
              ? {'user': userId}
              : null,
        );
    final response = await http.get(uri);
    debugPrint('recent pets: $response');

    if (response.statusCode == 200) {
      List<Pet> pets = [];
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        data['data'].forEach((petData) {
          pets.add(PetMapper.fromMap(petData));
        });
        return Result.success(pets);
      } else {
        return Result.error('No recent pets found');
      }
    } else {
      return Result.error(
        'Failed to fetch pets. Server returned ${response.statusCode}',
      );
    }
  }

  Future<Result<Pet>> fetchPetById(int petId, {String? userId}) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final uri = Uri.parse('${FlavorConfig.instance.apiBaseUrl}/pets/$petId')
          .replace(
            queryParameters: userId != null && userId.isNotEmpty
                ? {'user': userId}
                : null,
          );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final pet = PetMapper.fromMap(data['data']);
          return Result.success(pet);
        } else {
          return Result.error('Pet not found');
        }
      } else {
        return Result.error(
          'Failed to fetch pet. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to fetch pet: ${e.toString()}');
    }
  }

  Future<Result<List<Pet>>> searchPets(String query, {String? userId}) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      if (query.trim().isEmpty) {
        return Result.success([]); // empty query returns empty list quickly
      }
      final params = <String, String>{'search': query.trim()};
      if (userId != null && userId.isNotEmpty) params['user'] = userId;

      final uri = Uri.parse(
        '${FlavorConfig.instance.apiBaseUrl}/pets',
      ).replace(queryParameters: params);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = <Pet>[];
        if (data['data'] is List) {
          for (final petData in data['data']) {
            list.add(PetMapper.fromMap(petData));
          }
        }
        return Result.success(list);
      } else {
        return Result.error(
          'Search failed. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Search failed: $e');
    }
  }

  Future<Result<bool>> deletePet(int petId) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      final uri = Uri.parse('${FlavorConfig.instance.apiBaseUrl}/pets/$petId');
      final response = await http.delete(uri);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success(true);
      }
      final data = jsonDecode(response.body);
      return Result.error(
        data is Map && data['message'] != null
            ? data['message']
            : 'Failed to delete pet (status ${response.statusCode})',
      );
    } catch (e) {
      return Result.error('Failed to delete pet: $e');
    }
  }

  Future<Result<List<Poll>>> fetchPetNamePoll(int petId) async {
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/poll?pet_id=$petId'),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<Poll> polls = [];
      for (var item in data['data']) {
        polls.add(PollMapper.fromMap(item));
      }
      return Result.success(polls);
    } else {
      return Result.error('Failed to get pet poll');
    }
  }

  Future<Result<String>> addPoll({
    required int pet,
    required String suggestedName,
    required String createdBy,
  }) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/poll'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pet': pet,
        'suggested_name': suggestedName,
        'created_by': createdBy,
      }),
    );
    if (response.statusCode == 201) {
      return Result.success('Suggested name added');
    } else {
      return Result.error('Failed to add the suggested name');
    }
  }

  Future<Result<String>> deletePollSuggestion({required int pollId}) async {
    final response = await http.delete(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/poll/$pollId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return Result.success('Suggested name removed');
    } else {
      return Result.error('Failed to remove the suggested name');
    }
  }
}
