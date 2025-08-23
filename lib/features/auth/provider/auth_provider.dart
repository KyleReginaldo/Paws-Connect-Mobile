import 'package:paws_connect/core/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Result.success('Sign in successful');
    } on AuthException catch (e) {
      return Result.error(e.message);
    }
  }
}
