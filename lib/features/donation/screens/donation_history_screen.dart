import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/donation/repository/donation_repository.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/paws_theme.dart';
import '../../../dependency.dart';

@RoutePage()
class DonationHistoryScreen extends StatefulWidget implements AutoRouteWrapper {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<DonationRepository>(),
      child: this,
    );
  }
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonationRepository>().fetchUserDonations(USER_ID ?? "");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final donations = context.select(
      (DonationRepository bloc) => bloc.donations,
    );
    return Scaffold(
      appBar: AppBar(title: Text('Donation History')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: donations?.length ?? 0,
        itemBuilder: (context, index) {
          final donation = donations![index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              tileColor: Colors.white,

              title: PawsText(donation.fundraising),
              subtitle: PawsText(
                timeago.format(donation.donatedAt),
                fontSize: 12,
                color: Colors.grey,
              ),
              trailing: PawsText(
                donation.amount.displayMoney(),
                fontWeight: FontWeight.bold,
                color: PawsColors.success,
              ),
            ),
          );
        },
      ),
    );
  }
}
