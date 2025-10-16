import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/config/result.dart';
import '../../../core/utils/network_utils.dart';
import '../../../flavors/flavor_config.dart';
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
      final uri = Uri.parse(
        '${FlavorConfig.instance.apiBaseUrl}/fundraising?user_role=3',
      );

      final response = await NetworkUtils.makeMobileOptimizedRequest(
        uri: uri,
        maxRetries: 2,
        timeout: const Duration(seconds: 25),
      );

      if (response.statusCode == 200) {
        List<Fundraising> fundraisings = [];
        final data = jsonDecode(response.body);
        data['data'].forEach((fundraisingData) {
          fundraisings.add(FundraisingMapper.fromMap(fundraisingData));
        });
        return Result.success(fundraisings);
      } else {
        final data = jsonDecode(response.body);
        return Result.error(
          data['message'] ??
              'Failed to fetch fundraisings. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch fundraisings: $e');
      return Result.error(NetworkUtils.getErrorMessage(e));
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
      final uri = Uri.parse(
        '${FlavorConfig.instance.apiBaseUrl}/fundraising/$id',
      );

      final response = await NetworkUtils.makeMobileOptimizedRequest(
        uri: uri,
        maxRetries: 2,
        timeout: const Duration(seconds: 25),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fundraising = FundraisingMapper.fromMap(data['data']);
        return Result.success(fundraising);
      } else {
        final data = jsonDecode(response.body);
        return Result.error(
          data['message'] ??
              'Failed to fetch fundraising. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch fundraising by id: $e');
      return Result.error(NetworkUtils.getErrorMessage(e));
    }
  }
}
