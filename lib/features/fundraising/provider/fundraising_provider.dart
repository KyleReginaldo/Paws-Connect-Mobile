import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/result.dart';
import '../models/fundraising_model.dart';

class FundraisingProvider {
  Future<Result<List<Fundraising>>> fetchFundraisings() async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASE_URL')}/fundraising'),
    );
    if (response.statusCode == 200) {
      List<Fundraising> fundraisings = [];
      final data = jsonDecode(response.body);
      data['data'].forEach((fundraisingData) {
        fundraisings.add(FundraisingMapper.fromMap(fundraisingData));
      });
      return Result.success(fundraisings);
    } else {
      return Result.error('Failed to fetch fundraisings');
    }
  }
}
