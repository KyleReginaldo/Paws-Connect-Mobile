import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paws_connect/core/config/result.dart';
import 'package:paws_connect/core/transfer_object/address.dto.dart';

class CommonProvider {
  Future<Result<String>> addAddress(AddAddressDTO dto) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/address'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
    print('address response: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Result.success("Address added successfully");
    } else {
      return Result.error("Failed to add address: ${data['message']}");
    }
  }

  Future<Result<String>> deleteAddress(int addressId) async {
    final response = await http.delete(
      Uri.parse('${dotenv.get('BASE_URL')}/address/$addressId'),
    );
    print('delete address response: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Result.success("Address deleted successfully");
    } else {
      return Result.error("Failed to delete address: ${data['message']}");
    }
  }

  Future<Result<String>> setDefaultAddress(String userId, int addressId) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASE_URL')}/address/default'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'addressId': addressId}),
    );
    print('set default address response: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Result.success("Address set as default successfully");
    } else {
      return Result.error("Failed to set default address: ${data['message']}");
    }
  }
}
