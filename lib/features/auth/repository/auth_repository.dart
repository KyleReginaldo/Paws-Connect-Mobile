import 'package:flutter/material.dart';
import 'package:paws_connect/core/services/supabase_service.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository extends ChangeNotifier {
  final AuthProvider _authProvider;
  String? _errorMessage;
  User? _user;

  String? get errorMessage => _errorMessage;
  User? get user => _user;

  AuthRepository(this._authProvider);

  void init() async {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _user = data.session!.user;
        Future.microtask(() => notifyListeners());
      } else {
        _user = null;
        Future.microtask(() => notifyListeners());
      }
    });
  }

  Future<void> signOut() async {
    _user = null;
    USER_ID = null;
    notifyListeners();
    await _authProvider.signOut();
  }
}
