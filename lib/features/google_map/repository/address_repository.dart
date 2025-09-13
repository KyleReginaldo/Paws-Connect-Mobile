import 'package:flutter/widgets.dart';
import 'package:paws_connect/features/google_map/models/address_model.dart';

import '../provider/address_provider.dart';

class AddressRepository extends ChangeNotifier {
  final AddressProvider _addressProvider;

  AddressRepository(this._addressProvider);

  Address? _defaultAddress;
  Address? get defaultAddress => _defaultAddress;
  List<Address>? _addresses;
  List<Address>? get addresses => _addresses;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> fetchDefaultAddress(String userId) async {
    _isLoading = true;
    notifyListeners();
    final result = await _addressProvider.fetchDefaultAddress(userId);
    if (result.isSuccess) {
      _defaultAddress = result.value;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } else {
      _defaultAddress = null;
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllAddresses(String userId) async {
    _isLoading = true;
    notifyListeners();
    final result = await _addressProvider.fetchAllAddresses(userId);
    if (result.isSuccess) {
      _addresses = result.value;
      _isLoading = false;
      notifyListeners();
    } else {
      _addresses = null;
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    }
  }
}
