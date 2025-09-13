// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/widgets/text.dart';

@RoutePage()
class NoInternetScreen extends StatelessWidget {
  final Function(bool)? onResult;
  const NoInternetScreen({super.key, this.onResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PawsText('No Internet Connection'),
            PawsText('Please check your internet connection.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Retry logic
                final hasInternet =
                    await InternetConnection().hasInternetAccess;
                debugPrint('internet status: $hasInternet');
                if (hasInternet) {
                  onResult?.call(true);
                }
              },
              child: const PawsText('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
