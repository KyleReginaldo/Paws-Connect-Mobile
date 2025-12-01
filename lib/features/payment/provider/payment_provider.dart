import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:paws_connect/core/extension/ext.dart';

import '../../../core/config/result.dart';
import '../../../flavors/flavor_config.dart';

class PaymentProvider {
  Future<Result<String>> createPayment({
    required String name,
    required String phoneNumber,
    required String email,
    required String customerId,
    required int amount,
    required int fundraisingId,
    required String userId,
  }) async {
    final paymentMethod = await createPaymentMethod(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      customerId: customerId,
    );
    if (paymentMethod.isError) {
      return Result.error(paymentMethod.error);
    } else {
      final paymentIntent = await createPaymentIntent(amount: amount);
      if (paymentIntent.isError) {
        return Result.error(paymentIntent.error);
      } else {
        final attachIntent = await attachPaymentIntent(
          paymentIntent: paymentIntent.value,
          paymentMethod: paymentMethod.value,
          fundraisingId: fundraisingId,
          userId: userId,
          amount: amount,
        );
        if (attachIntent.isError) {
          return Result.error(attachIntent.error);
        } else {
          return Result.success(attachIntent.value);
        }
      }
    }
  }

  Future<void> confirmDonation({
    required String donor,
    required double amount,
    required int fundraisingId,
  }) async {
    final response = await http.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}/donations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "donor": donor,
        "amount": amount,
        "fundraising": fundraisingId,
        "message": "Test donation to $fundraisingId",
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Donation confirmed successfully');
    } else {
      print('Failed to confirm donation: ${response.body}');
    }
  }
}

Future<Result<String>> createPaymentMethod({
  required String name,
  required String phoneNumber,
  required String email,
  required String customerId,
}) async {
  final response = await http.post(
    Uri.parse('https://api.paymongo.com/v1/payment_methods'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic c2tfdGVzdF9aQ0xCYldHa0pnVGtmeDVKb0FUbVY5RTE6',
    },
    body: jsonEncode({
      "data": {
        "attributes": {
          "type": "gcash",
          "billing": {"name": name, "email": email, "phone": phoneNumber},
          "customer": customerId,
          "reusable": true,
        },
      },
    }),
  );
  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    final paymentMethodId = data['data']['id'] as String;
    return Result.success(paymentMethodId);
  } else {
    final errorMessage = data['errors'][0]['detail'] as String;
    return Result.error(errorMessage);
  }
}

Future<Result<String>> createPaymentIntent({required int amount}) async {
  final response = await http.post(
    Uri.parse('https://api.paymongo.com/v1/payment_intents'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic c2tfdGVzdF9aQ0xCYldHa0pnVGtmeDVKb0FUbVY5RTE6',
    },
    body: jsonEncode({
      "data": {
        "attributes": {
          "amount": amount,
          "payment_method_allowed": ["gcash"],
          "payment_method_options": {
            "card": {"request_three_d_secure": "any"},
          },
          "currency": "PHP",
          "capture_type": "automatic",
        },
      },
    }),
  );
  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    // Payment intent created successfully
    final paymentIntentId = data['data']['id'] as String;
    print('Payment Intent ID: $paymentIntentId');
    return Result.success(paymentIntentId);
  } else {
    final errorMessage = data['errors'][0]['detail'] as String;
    print('Error creating payment intent: $errorMessage');
    return Result.error(errorMessage);
  }
}

Future<Result<String>> attachPaymentIntent({
  required String paymentIntent,
  required String paymentMethod,
  required int fundraisingId,
  required String userId,
  required int amount,
}) async {
  final response = await http.post(
    Uri.parse(
      'https://api.paymongo.com/v1/payment_intents/$paymentIntent/attach',
    ),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic c2tfdGVzdF9aQ0xCYldHa0pnVGtmeDVKb0FUbVY5RTE6',
    },
    body: jsonEncode({
      "data": {
        "attributes": {
          "payment_method": paymentMethod,
          "return_url":
              "https://paws-connect-rho.vercel.app/payment-success/$fundraisingId?donor=$userId&amount=${amount.toRealAmount}",
        },
      },
    }),
  );
  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(
      'Payment Intent $paymentIntent attached to Payment Method $paymentMethod',
    );
    return Result.success(
      data['data']['attributes']['next_action']['redirect']['url'],
    );
  } else {
    final errorMessage = data['errors'][0]['detail'] as String;
    print('Error attaching payment intent: $errorMessage');
    return Result.error(errorMessage);
  }
}
