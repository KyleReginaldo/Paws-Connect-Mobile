import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/features/donation/models/donation_model.dart';

import '../../../core/config/result.dart';

class DonationProvider {
  Future<Result<List<Donation>>> fetchUserDonations(String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/users/$userId/donation'),
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
}
