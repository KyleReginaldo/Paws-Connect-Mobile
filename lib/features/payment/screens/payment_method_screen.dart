// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/widgets/text.dart';

@RoutePage()
class PaymentMethodScreen extends StatefulWidget {
  final String paymongoId;
  const PaymentMethodScreen({super.key, required this.paymongoId});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Method',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(children: [PawsText(widget.paymongoId)]),
    );
  }
}
