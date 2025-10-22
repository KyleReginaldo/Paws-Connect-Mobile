import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/donation/models/donation_model.dart';

import '../../../core/config/result.dart';
import '../../../flavors/flavor_config.dart';

class DonationProvider {
  Future<Result<List<Donation>>> fetchUserDonations(String userId) async {
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/users/$userId/donation'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Donation> donations = [];
      for (var item in data['data']) {
        donations.add(DonationMapper.fromMap(item));
      }
      return Result.success(donations);
    } else {
      return Result.error('Failed to fetch user donations');
    }
  }

  Future<Result<List<DonorLeaderboard>>> fetchTopDonors() async {
    final response = await http.get(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/donations/top'),
    );
    final data = jsonDecode(response.body);
    debugPrint('Top donors response data: $data');
    if (response.statusCode == 200) {
      List<DonorLeaderboard> donors = [];
      for (var item in data['data']) {
        donors.add(DonorLeaderboardMapper.fromMap(item));
      }
      return Result.success(donors);
    } else {
      return Result.error('Failed to fetch top donations');
    }
  }
}
