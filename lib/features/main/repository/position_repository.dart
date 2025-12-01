import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionRepository extends ChangeNotifier {
  Position? _currentPositionLive;
  Position? get currentPositionLive => _currentPositionLive;

  void setCurrentPosition(Position position) {
    _currentPositionLive = position;
    notifyListeners();
  }
}
