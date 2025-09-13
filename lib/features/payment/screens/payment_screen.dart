// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/payment/provider/payment_provider.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/supabase/client.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/button.dart';
import '../../../dependency.dart';
import '../../fundraising/repository/fundraising_repository.dart';

@RoutePage()
class PaymentScreen extends StatefulWidget implements AutoRouteWrapper {
  final int fundraisingId;
  const PaymentScreen({
    super.key,
    @PathParam('id') required this.fundraisingId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<FundraisingRepository>()),
      ],
      child: this,
    );
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
      context.read<FundraisingRepository>().fetchFundraisingById(
        widget.fundraisingId,
      );
    });
  }

  String? phoneNumber;
  final amount = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void handlePayment({
    required String name,
    required String phoneNumber,
    required String email,
    required String customerId,
    required int amount,
  }) async {
    final result = await PaymentProvider().createPayment(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      customerId: customerId,
      amount: amount,
      fundraisingId: widget.fundraisingId,
      userId: USER_ID ?? "",
    );
    if (result.isError) {
      EasyLoading.showError(result.error);
      // Handle error
    } else {
      _launchUrl(result.value);
      // Handle success
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileRepository>().userProfile;
    final fundraising = context.watch<FundraisingRepository>().fundraising;
    debugPrint('paymongo id: ${user?.paymongoId}');
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: PawsColors.success.withValues(alpha: 0.3),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: PawsColors.success,
                        size: 16,
                      ),
                      PawsText(
                        'Test Mode',
                        color: PawsColors.success,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: 5,
                  children: [
                    Icon(
                      LucideIcons.info,
                      color: PawsColors.textSecondary,
                      size: 16,
                    ),
                    PawsText(
                      'For now, we only accept GCash payments.',
                      color: PawsColors.textSecondary,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,

                  children: [
                    CircleAvatar(
                      radius: 15,
                      foregroundImage: AssetImage('assets/images/gcash.jpeg'),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PawsText('Pay with GCash'),
                        PawsText(
                          user?.phoneNumber ?? 'No phone number',
                          fontSize: 16,
                          color: PawsColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2),
                PawsTextField(
                  hint: 'Amount',
                  label: 'Amount',
                  controller: amount,
                  prefixIcon: PawsTextButton(
                    label: '₱',
                    padding: EdgeInsets.zero,
                    foregroundColor: PawsColors.textSecondary,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null) {
                      return 'Please enter a valid number';
                    }
                    final remaining =
                        (fundraising?.targetAmount ?? 0) -
                        (fundraising?.raisedAmount ?? 0);

                    if (intValue > remaining) {
                      return 'Amount exceeds remaining target amount of ${remaining.displayMoney()}';
                    }
                    if (intValue < 50) {
                      return 'Minimum amount is ₱50.00';
                    }

                    return null;
                  },
                ),
                PawsElevatedButton(
                  label: 'Proceed to Pay',
                  backgroundColor: user?.paymongoId == null
                      ? PawsColors.border
                      : PawsColors.primary,
                  onPressed: user?.paymongoId == null
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            handlePayment(
                              name: user!.username,
                              phoneNumber: user.phoneNumber,
                              email: user.email,
                              customerId: user.paymongoId!,
                              amount: amount
                                  .text
                                  .toPaymongoAmount, // Replace with actual amount
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
