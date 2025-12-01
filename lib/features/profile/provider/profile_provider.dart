import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/features/profile/models/user_profile_model.dart';

import '../../../core/config/result.dart';
import '../../../flavors/flavor_config.dart';

class ProfileProvider {
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    // Check internet connectivity first
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/$userId'),
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
  }

  Future<Result<List<UserProfile>>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users'),
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
  }

  Future<Result<String>> updateUserProfile({
    required String userId,
    XFile? image,
    String? username,
  }) async {
    // Check internet connectivity first
    String? profileImageLink;
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
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (username != null) 'username': username,
        if (profileImageLink != null)
          'profile_image_link': profileImageLink.replaceAll(
            '10.0.2.2',
            '127.0.0.1',
          ),
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
  }

  Future<Result<String>> submitIdVerification({
    required String userId,
    required String idNumber,
    required XFile idAttachment,
    required String firstName,
    required String lastName,
    String? middleInitial,
    required String address,
    required DateTime dateOfBirth,
    required String idType,
  }) async {
    // Check internet connectivity first

    late String idAttachmentUrl;
    debugPrint('Uploading ID attachment: ${idAttachment.path}');
    final fileName =
        'identification_${DateTime.now().microsecondsSinceEpoch.toString()}';

    try {
      final uploadResult = await supabase.storage
          .from('files')
          .upload(
            'user_identification/$fileName.${idAttachment.name.split('.').last}',
            File(idAttachment.path),
          );
      debugPrint('Upload result: $uploadResult');

      idAttachmentUrl = supabase.storage
          .from('files')
          .getPublicUrl(uploadResult.replaceFirst('files/', ""));
      debugPrint('Uploaded ID attachment URL: $idAttachmentUrl');
    } catch (uploadError) {
      debugPrint('Upload error: $uploadError');
      return Result.error(
        'Failed to upload ID attachment: ${uploadError.toString()}',
      );
    }
    try {
      final response = await http.post(
        Uri.parse(
          '${FlavorConfig.instance.apiBaseUrl}/users/$userId/id-verification',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_number': idNumber,
          'id_type': idType,
          'id_attachment_url': idAttachmentUrl.replaceAll(
            '10.0.2.2',
            '127.0.0.1',
          ),
          'first_name': firstName,
          'last_name': lastName,
          if (middleInitial != null) 'middle_initial': middleInitial,
          'address': address,
          'date_of_birth': dateOfBirth.toIso8601String().split(
            'T',
          )[0], // Format as YYYY-MM-DD
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('ID verification submitted successfully');
        return Result.success('ID verification submitted successfully');
      } else {
        debugPrint(
          'Failed to submit ID verification. Server returned ${response.statusCode}',
        );
        debugPrint('Response body: ${response.body}');
        return Result.error(
          data['error'] ??
              'Failed to submit ID verification. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to submit ID verification: ${e.toString()}');
    }
  }

  Future<Result<String>> uploadHouseImages(
    String userId,
    List<XFile> images,
  ) async {
    // Check internet connectivity first

    List<String> imageUrls = [];
    try {
      for (var image in images) {
        debugPrint('Uploading house image: ${image.path}');
        final fileName =
            'house_${DateTime.now().microsecondsSinceEpoch.toString()}_${image.name}';

        try {
          final uploadResult = await supabase.storage
              .from('files')
              .upload(fileName, File(image.path));
          debugPrint('Upload result: $uploadResult');

          // Get the public URL using the correct bucket and file path
          final imageUrl = supabase.storage
              .from('files')
              .getPublicUrl(fileName);
          imageUrls.add(imageUrl.replaceAll('10.0.2.2', '127.0.0.1'));
          debugPrint('Uploaded house image URL: $imageUrl');
        } catch (uploadError) {
          debugPrint('Upload error: $uploadError');
          return Result.error(
            'Failed to upload house image: ${uploadError.toString()}',
          );
        }
      }

      debugPrint(
        'Uploading ${imageUrls.length} house images for user: $userId',
      );
      debugPrint('API URL: ${FlavorConfig.instance.apiBaseUrl}/users/$userId');
      debugPrint('Request body: ${jsonEncode({'house_images': imageUrls})}');

      final response = await http.put(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'house_images': imageUrls}),
      );

      debugPrint('House images upload response status: ${response.statusCode}');
      debugPrint('House images upload response body: ${response.body}');
      debugPrint('House images upload response headers: ${response.headers}');

      if (response.body.isEmpty) {
        debugPrint('Warning: Empty response body received');
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Result.success('House images uploaded successfully');
        } else {
          return Result.error(
            'Failed to upload house images. Server returned ${response.statusCode} with empty body',
          );
        }
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        debugPrint('Failed to parse JSON response: $e');
        debugPrint('Raw response body: ${response.body}');
        return Result.error('Invalid response from server: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('House images uploaded successfully');
        return Result.success('House images uploaded successfully');
      } else {
        debugPrint(
          'Failed to upload house images. Server returned ${response.statusCode}',
        );
        debugPrint('Response body: ${response.body}');
        return Result.error(
          data.containsKey('error')
              ? data['error']
              : 'Failed to upload house images. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to upload house images: ${e.toString()}');
    }
  }
}
