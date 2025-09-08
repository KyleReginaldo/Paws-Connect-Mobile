import 'package:flutter/widgets.dart';
import 'package:paws_connect/features/pets/provider/pet_provider.dart';

class PetRepository extends ChangeNotifier {
  final PetProvider _petProvider;
  String? _errorMessage;
  List? _pets;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List? get pets => _pets;
  String? get errorMessage => _errorMessage;
  PetRepository(this._petProvider);
  void fetchPets() async {
    _isLoading = true;
    notifyListeners();
    final result = await _petProvider.fetchPets();
    if (result.isSuccess) {
      _pets = result.value;
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    }
  }
}
