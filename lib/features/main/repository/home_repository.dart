import 'package:flutter/widgets.dart';

import '../provider/home_provider.dart';

class HomeRepository extends ChangeNotifier {
  // Implementation of HomeRepository
  final List<CapstoneLink> _capstoneLinks = [];
  List<CapstoneLink> get capstoneLinks => _capstoneLinks;

  void fetchCapstoneLinks() async {
    final result = await HomeProvider().fetchCapstoneLinks();

    if (result.isError) {
      // Handle error accordingly, e.g., log it or show a message
    }
    _capstoneLinks.clear();
    _capstoneLinks.addAll(result.value);
    notifyListeners();
  }
}
