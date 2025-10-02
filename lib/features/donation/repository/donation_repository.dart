import 'package:flutter/material.dart';
import 'package:paws_connect/features/donation/models/donation_model.dart';

import '../provider/donation_provider.dart';

class DonationRepository extends ChangeNotifier {
  List<Donation>? _donations;
  List<Donation>? get donations => _donations;
  final DonationProvider donationProvider;

  DonationRepository(this.donationProvider);

  Future<void> fetchUserDonations(String userId) async {
    debugPrint('Fetching donations for userId: $userId');
    final result = await donationProvider.fetchUserDonations(userId);
    if (result.isSuccess) {
      _donations = result.value;
      notifyListeners();
    } else {
      _donations = null;
      notifyListeners();
    }
  }

  void reset() {
    _donations = null;
    notifyListeners();
  }
}
