import 'package:flutter/widgets.dart';

import '../models/fundraising_model.dart';
import '../provider/fundraising_provider.dart';

class FundraisingRepository extends ChangeNotifier {
  final FundraisingProvider _provider;

  FundraisingRepository(this._provider);
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  List<Fundraising>? _fundraisings;
  Fundraising? _fundraising;
  String? _errorMessage;
  List<Fundraising>? get fundraisings => _fundraisings;
  Fundraising? get fundraising => _fundraising;
  String? get errorMessage => _errorMessage;
  void fetchFundraisings() async {
    _isLoading = true;
    notifyListeners();
    final result = await _provider.fetchFundraisings();
    if (result.isSuccess) {
      _fundraisings = result.value;
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    }
  }

  void fetchFundraisingById(int id) async {
    _isLoading = true;
    notifyListeners();
    final result = await _provider.fetchFundraisingById(id);
    if (result.isSuccess) {
      _fundraising = result.value;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    }
  }
}
