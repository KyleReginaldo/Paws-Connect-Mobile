import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final response = await supabase.storage
          .from('files')
          .upload(
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}',
            File(imageFile.path),
          );
      debugPrint('Uploaded image path: $response');

      final imageUrl = supabase.storage.from('').getPublicUrl(response);
      debugPrint('Uploaded image URL: $imageUrl');
      return imageUrl.replaceAll('10.0.2.2', '127.0.0.1');
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
