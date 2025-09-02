import 'package:flutter/material.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository extends ChangeNotifier {
  final AuthProvider _authProvider;
  String? _errorMessage;
  User? _user;

  String? get errorMessage => _errorMessage;
  User? get user => _user;

  AuthRepository(this._authProvider);

  // void signIn({required String email, required String password}) async {
  //   final result = await _authProvider.signIn(email: email, password: password);
  //   if (result.isError) {
  //     _errorMessage = result.error;
  //     notifyListeners();
  //   }
  // }

  void init() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _user = data.session!.user;
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }
}
