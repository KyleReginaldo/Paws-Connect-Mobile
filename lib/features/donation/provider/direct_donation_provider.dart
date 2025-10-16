import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/services/supabase_service.dart';

import '../../../flavors/flavor_config.dart';

class DirectDonationProvider {
  /// Upload screenshot to Supabase storage and create donation
  Future<Result<String>> createDirectDonation({
    required String donor,
    required int amount,
    required int fundraising,
    required String message,
    required String referenceNumber,
    required XFile screenshot,
    required bool isAnonymous,
  }) async {
    try {
      // First, upload the screenshot to Supabase storage
      final screenshotUrl = await _uploadScreenshot(screenshot);
      if (screenshotUrl == null) {
        return Result.error('Failed to upload screenshot');
      }

      // Create donation with screenshot URL
      final response = await http.post(
        Uri.parse('${FlavorConfig.instance.apiBaseUrl}/donations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "donor": donor,
          "amount": amount,
          "fundraising": fundraising,
          "message": message,
          "reference_number": referenceNumber,
          "screenshot": screenshotUrl,
          "is_anonymous": isAnonymous,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.success(
          'Donation submitted successfully! It will be reviewed and processed.',
        );
      } else {
        debugPrint('Donation creation failed: $data');
        final errorMessage =
            'Failed to upload donation, please try again later.';
        return Result.error(errorMessage);
      }
    } catch (e) {
      return Result.error('Failed to create donation: ${e.toString()}');
    }
  }

  /// Upload screenshot to Supabase storage
  Future<String?> _uploadScreenshot(XFile screenshot) async {
    try {
      final fileName =
          'donations/${DateTime.now().microsecondsSinceEpoch.toString()}_${screenshot.name}';

      final uploadResult = await supabase.storage
          .from('files')
          .upload(fileName, File(screenshot.path));

      if (uploadResult.isNotEmpty) {
        // Get the public URL
        final screenshotUrl = supabase.storage
            .from('files')
            .getPublicUrl(fileName);
        return screenshotUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading screenshot: $e');
      return null;
    }
  }
}
