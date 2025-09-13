import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/config/result.dart';
import '../models/fundraising_model.dart';

class FundraisingProvider {
  Future<Result<List<Fundraising>>> fetchFundraisings() async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/fundraising?user_role=3'),
      );
      if (response.statusCode == 200) {
        List<Fundraising> fundraisings = [];
        final data = jsonDecode(response.body);
        data['data'].forEach((fundraisingData) {
          fundraisings.add(FundraisingMapper.fromMap(fundraisingData));
        });
        return Result.success(fundraisings);
      } else {
        return Result.error(
          'Failed to fetch fundraisings. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to fetch fundraisings: ${e.toString()}');
    }
  }

  Future<Result<Fundraising>> fetchFundraisingById(int id) async {
    // Check internet connectivity first
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/fundraising/$id'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fundraising = FundraisingMapper.fromMap(data['data']);
        return Result.success(fundraising);
      } else {
        return Result.error(
          'Failed to fetch fundraisings. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.error('Failed to fetch fundraisings: ${e.toString()}');
    }
  }
}
