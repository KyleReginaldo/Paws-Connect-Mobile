import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

import '../../../core/config/result.dart';

class ProfileProvider {
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/users/$userId'),
    );
    final data = jsonDecode(response.body);
    debugPrint('User Profile Data: ${data['data']}'); // Debug print
    if (response.statusCode == 200) {
      final userProfile = UserProfileMapper.fromMap(data['data']);
      return Result.success(userProfile);
    } else {
      return Result.error('Failed to load user profile');
    }
  }
}
