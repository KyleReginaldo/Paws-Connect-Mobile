import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../dependency.dart';

@RoutePage()
class AdoptionHistoryScreen extends StatefulWidget implements AutoRouteWrapper {
  const AdoptionHistoryScreen({super.key});

  @override
  State<AdoptionHistoryScreen> createState() => _AdoptionHistoryScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<AdoptionRepository>(),
      child: this,
    );
  }
}

class _AdoptionHistoryScreenState extends State<AdoptionHistoryScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdoptionRepository>().fetchUserAdoptions(USER_ID ?? "");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final adoptions = context.select(
      (AdoptionRepository bloc) => bloc.adoptions,
    );
    return Scaffold(
      appBar: AppBar(title: PawsText('Adoption History')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: adoptions?.length ?? 0,
        itemBuilder: (context, index) {
          final adoption = adoptions![index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              tileColor: Colors.white,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(adoption.pets.photo),
              ),
              title: Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PawsText(adoption.pets.name),
                  PawsText(
                    timeago.format(adoption.createdAt),
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
              subtitle: PawsText(
                adoption.status.capitalize(),
                color: adoption.status.color,
              ),
            ),
          );
        },
      ),
    );
  }
}
