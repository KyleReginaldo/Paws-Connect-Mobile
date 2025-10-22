import 'package:flutter/widgets.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';
import 'package:paws_connect/features/pets/provider/pet_provider.dart';

class PetRepository extends ChangeNotifier {
  final PetProvider _petProvider;
  List<Poll>? _poll;
  List<Poll>? get poll => _poll;
  String? _errorMessage;
  List<Pet>? _pets;
  Pet? _pet;
  List<Pet>? _recentPets;
  bool _isLoading = false;

  // Filter state
  String? _selectedType;
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedSize;
  int? _ageMin;
  int? _ageMax;
  bool? _isVaccinated;
  bool? _isSpayedOrNeutered;
  bool? _isTrained;
  String? _selectedHealthStatus;
  String? _selectedRequestStatus;
  String? _selectedGoodWith;
  String? _selectedLocation;

  // Getters
  bool get isLoading => _isLoading;
  List<Pet>? get pets => _pets;
  Pet? get pet => _pet;
  List<Pet>? get recentPets => _recentPets;
  String? get errorMessage => _errorMessage;

  // Filter getters
  String? get selectedType => _selectedType;
  String? get selectedBreed => _selectedBreed;
  String? get selectedGender => _selectedGender;
  String? get selectedSize => _selectedSize;
  int? get ageMin => _ageMin;
  int? get ageMax => _ageMax;
  bool? get isVaccinated => _isVaccinated;
  bool? get isSpayedOrNeutered => _isSpayedOrNeutered;
  bool? get isTrained => _isTrained;
  String? get selectedHealthStatus => _selectedHealthStatus;
  String? get selectedRequestStatus => _selectedRequestStatus;
  String? get selectedGoodWith => _selectedGoodWith;
  String? get selectedLocation => _selectedLocation;

  PetRepository(this._petProvider);

  void fetchPets({
    String? userId,
    String? type,
    String? breed,
    String? gender,
    String? size,
    int? ageMin,
    int? ageMax,
    bool? isVaccinated,
    bool? isSpayedOrNeutered,
    bool? isTrained,
    String? healthStatus,
    String? requestStatus,
    String? goodWith,
    String? location,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _petProvider.fetchPets(
      type: type,
      breed: breed,
      gender: gender,
      size: size,
      ageMin: ageMin,
      ageMax: ageMax,
      isVaccinated: isVaccinated,
      isSpayedOrNeutered: isSpayedOrNeutered,
      isTrained: isTrained,
      healthStatus: healthStatus,
      requestStatus: requestStatus,
      goodWith: goodWith,
      location: location,
      userId: userId,
    );

    if (result.isSuccess) {
      _pets = result.value;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    }
  }

  // SEARCH
  List<Pet>? _searchResults;
  bool _isSearching = false;
  List<Pet>? get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  Future<void> searchPets(String query, {String? userId}) async {
    _isSearching = true;
    notifyListeners();
    final res = await _petProvider.searchPets(query, userId: userId);
    if (res.isSuccess) {
      _searchResults = res.value;
    } else {
      _searchResults = [];
      _errorMessage = res.error;
    }
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = null;
    notifyListeners();
  }

  // DELETE
  Future<bool> deletePet(int id) async {
    final res = await _petProvider.deletePet(id);
    if (res.isSuccess) {
      // Remove from cached lists
      _pets?.removeWhere((p) => p.id == id);
      _recentPets?.removeWhere((p) => p.id == id);
      _searchResults?.removeWhere((p) => p.id == id);
      if (_pet?.id == id) _pet = null;
      notifyListeners();
      return true;
    }
    _errorMessage = res.error;
    notifyListeners();
    return false;
  }

  Future<void> fetchRecentPets({String? userId}) async {
    _isLoading = true;
    notifyListeners();
    final result = await _petProvider.fetchRecentPets(userId: userId);
    if (result.isSuccess) {
      _recentPets = result.value;
      _isLoading = false;
      notifyListeners();
    } else {
      _recentPets = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refetchRecentPets({String? userId}) async {
    final result = await _petProvider.fetchRecentPets(userId: userId);
    if (result.isSuccess) {
      _recentPets = result.value;
      _isLoading = false;
      notifyListeners();
    } else {
      _recentPets = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void fetchPetById(int id, {String? userId}) async {
    _isLoading = true;
    notifyListeners();
    final result = await _petProvider.fetchPetById(id, userId: userId);
    if (result.isSuccess) {
      _pet = result.value;
      _isLoading = false;
      notifyListeners();
    } else {
      _pet = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to fetch pets with current filter state
  void fetchPetsWithFilters() {
    fetchPets(
      type: _selectedType,
      breed: _selectedBreed,
      gender: _selectedGender,
      size: _selectedSize?.toLowerCase(),
      ageMin: _ageMin,
      ageMax: _ageMax,
      isVaccinated: _isVaccinated,
      isSpayedOrNeutered: _isSpayedOrNeutered,
      isTrained: _isTrained,
      healthStatus: _selectedHealthStatus,
      requestStatus: _selectedRequestStatus,
      goodWith: _selectedGoodWith,
      location: _selectedLocation,
    );
  }

  // Filter update methods
  void updateTypeFilter(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void updateGenderFilter(String? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void updateSizeFilter(String? size) {
    _selectedSize = size;
    notifyListeners();
  }

  void updateAgeFilter({int? min, int? max}) {
    _ageMin = min;
    _ageMax = max;
    notifyListeners();
  }

  void updateVaccinatedFilter(bool? isVaccinated) {
    _isVaccinated = isVaccinated;
    notifyListeners();
  }

  void updateLocationFilter(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedType = null;
    _selectedBreed = null;
    _selectedGender = null;
    _selectedSize = null;
    _ageMin = null;
    _ageMax = null;
    _isVaccinated = null;
    _isSpayedOrNeutered = null;
    _isTrained = null;
    _selectedHealthStatus = null;
    _selectedRequestStatus = null;
    _selectedGoodWith = null;
    _selectedLocation = null;
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _selectedType != null ||
        _selectedBreed != null ||
        _selectedGender != null ||
        _selectedSize != null ||
        _ageMin != null ||
        _ageMax != null ||
        _isVaccinated != null ||
        _isSpayedOrNeutered != null ||
        _isTrained != null ||
        _selectedHealthStatus != null ||
        _selectedRequestStatus != null ||
        _selectedGoodWith != null ||
        _selectedLocation != null;
  }

  // Clear all cached data and filters when signing out
  void reset() {
    _errorMessage = null;
    _pets = null;
    _pet = null;
    _recentPets = null;
    _isLoading = false;
    clearAllFilters();
    // clearAllFilters already notifies; no extra notify needed
  }

  // Optimistically update favorite flag for a pet in local caches
  void updatePetFavorite(int petId, bool isFav) {
    bool changed = false;
    if (_recentPets != null) {
      for (var i = 0; i < _recentPets!.length; i++) {
        if (_recentPets![i].id == petId) {
          _recentPets![i].isFavorite = isFav;
          changed = true;
          break;
        }
      }
    }
    if (_pets != null) {
      for (var i = 0; i < _pets!.length; i++) {
        if (_pets![i].id == petId) {
          _pets![i].isFavorite = isFav;
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  void getPoll(int petId) async {
    final result = await _petProvider.fetchPetNamePoll(petId);
    if (result.isError) {
      _poll = null;
      notifyListeners();
    } else {
      _poll = result.value;
      notifyListeners();
    }
  }
}
