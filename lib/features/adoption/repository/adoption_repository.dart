import 'package:flutter/material.dart';
import 'package:paws_connect/features/adoption/models/adoption_model.dart';

import '../provider/adoption_provider.dart';

class AdoptionRepository extends ChangeNotifier {
  List<Adoption>? _adoptions;
  Adoption? _adoption;

  List<Adoption>? get adoptions => _adoptions;
  Adoption? get adoption => _adoption;
  final AdoptionProvider adoptionProvider;

  AdoptionRepository({required this.adoptionProvider});

  Future<void> fetchUserAdoptions(String userId) async {
    debugPrint('Fetching adoptions for userId: $userId');
    final result = await adoptionProvider.fetchUserAdoptions(userId);
    if (result.isError) {
      _adoptions = null;
      notifyListeners();
    } else {
      _adoptions = result.value;
      notifyListeners();
    }
  }

  Future<void> fetchAdoptionDetail(int id) async {
    _adoption = null;

    debugPrint('Fetching adoption detail for id: $id');
    final result = await adoptionProvider.fetchAdoptionDetail(id);
    if (result.isError) {
      _adoption = null;
      notifyListeners();
    } else {
      _adoption = result.value;
      notifyListeners();
    }
  }

  void reset() {
    _adoptions = null;
    _adoption = null;
    notifyListeners();
  }
}
