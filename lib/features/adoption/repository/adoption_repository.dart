import 'package:flutter/material.dart';
import 'package:paws_connect/features/adoption/models/adoption_model.dart';

import '../provider/adoption_provider.dart';

class AdoptionRepository extends ChangeNotifier {
  List<Adoption>? _adoptions;

  List<Adoption>? get adoptions => _adoptions;
  final AdoptionProvider adoptionProvider;

  AdoptionRepository({required this.adoptionProvider});

  void fetchUserAdoptions(String userId) async {
    final result = await adoptionProvider.fetchUserAdoptions(userId);
    if (result.isError) {
      _adoptions = null;
      notifyListeners();
    } else {
      _adoptions = result.value;
      notifyListeners();
    }
  }
}
