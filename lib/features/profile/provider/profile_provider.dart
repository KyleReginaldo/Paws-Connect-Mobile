import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

import '../../../core/config/result.dart';

class ProfileProvider {
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/users/$userId'),
      );
      final data = jsonDecode(response.body);
      debugPrint('user [data]: ${data['data']}');
      // debugPrint('User Profile Data: ${data['data']}'); // Commented to reduce console spam
      if (response.statusCode == 200) {
        final userProfile = UserProfileMapper.fromMap(data['data']);
        return Result.success(userProfile);
      } else {
        return Result.error(
          'Failed to load user profile. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to load user profile: ${e.toString()}');
    }
  }

  Future<Result<List<UserProfile>>> fetchUsers() async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/users'),
      );
      final data = jsonDecode(response.body);
      // debugPrint('User Profile Data: ${data['data']}'); // Commented to reduce console spam
      if (response.statusCode == 200) {
        List<UserProfile> users = [];
        data['data'].forEach((user) {
          users.add(UserProfileMapper.fromMap(user));
        });
        return Result.success(users);
      } else {
        return Result.error(
          'Failed to load user profile. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to load user profile: ${e.toString()}');
    }
  }

  Future<Result<String>> updateUserProfile({
    required String userId,
    XFile? image,
    String? username,
  }) async {
    // Check internet connectivity first
    String? profileImageLink;
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }
    try {
      debugPrint('Image: $image');
      debugPrint('Username: $username');
      if (image != null) {
        debugPrint('Uploading image: ${image.path}');
        final fileName =
            '${DateTime.now().microsecondsSinceEpoch.toString()}_${image.name}';

        try {
          final uploadResult = await supabase.storage
              .from('files')
              .upload(fileName, File(image.path));
          debugPrint('Upload result: $uploadResult');

          // Get the public URL using the correct bucket and file path
          profileImageLink = supabase.storage
              .from('files')
              .getPublicUrl(fileName);
          debugPrint('Uploaded image URL: $profileImageLink');
        } catch (uploadError) {
          debugPrint('Upload error: $uploadError');
          return Result.error(
            'Failed to upload image: ${uploadError.toString()}',
          );
        }
      }
      final response = await http.put(
        Uri.parse('${dotenv.get('BASE_URL')}/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (username != null) 'username': username,
          if (profileImageLink != null) 'profile_image_link': profileImageLink,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        debugPrint('Profile updated successfully');
        return Result.success('Profile updated successfully');
      } else {
        debugPrint(
          'Failed to update profile. Server returned ${response.statusCode}',
        );
        debugPrint('Response body: ${response.body}');
        return Result.error(
          data['error'] ??
              'Failed to update profile. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to update profile: ${e.toString()}');
    }
  }
}
