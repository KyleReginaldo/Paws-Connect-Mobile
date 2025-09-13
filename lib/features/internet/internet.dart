import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  late final StreamSubscription<InternetStatus> sub;

  InternetProvider() {
    sub = InternetConnection().onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}
