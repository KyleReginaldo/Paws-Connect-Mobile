import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user?.userMetadata?['role'] == 3) {
        return Result.success('Sign in successful');
      } else {
        return Result.error('Unauthorized');
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    }
  }

  Future<Result<String>> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    required String username,
  }) async {
    try {
      final url = Uri.parse('${dotenv.get('BASE_URL')}/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'username': username,
          'role': 3,
        }),
      );
      final res = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return Result.success(res['message']);
      } else {
        return Result.error(res['message']);
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    }
  }
}
