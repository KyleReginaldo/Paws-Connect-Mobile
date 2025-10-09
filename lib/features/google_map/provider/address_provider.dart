import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:paws_connect/features/google_map/models/address_model.dart';

import '../../../core/config/result.dart';

class AddressProvider {
  Future<Result<Address>> fetchDefaultAddress(String userId) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/address/default?userId=$userId'),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final address = AddressMapper.fromMap(data['data']);
        return Result.success(address);
      } else {
        return Result.error('Failed to load default address');
      }
    } catch (e) {
      return Result.error('Failed to load default address');
    }
  }

  Future<Result<List<Address>>> fetchAllAddresses(String userId) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      return Result.error(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASE_URL')}/address/user/$userId'),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<Address> addresses = [];
        data['data'].forEach((address) {
          addresses.add(AddressMapper.fromMap(address));
        });
        return Result.success(addresses);
      } else {
        return Result.error('Failed to load address');
      }
    } catch (e) {
      return Result.error('Failed to load address');
    }
  }
}
