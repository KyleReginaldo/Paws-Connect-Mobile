import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/features/adoption/repository/adoption_repository.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/app_route.gr.dart';
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
      appBar: AppBar(
        title: const Text(
          'Adoption History',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: adoptions?.length ?? 0,
        itemBuilder: (context, index) {
          final adoption = adoptions![index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () {
                context.router.push(AdoptionDetailRoute(id: adoption.id));
              },
              tileColor: Colors.white,
              leading: Stack(
                children: [
                  UserAvatar(
                    imageUrl: adoption.pets.transformedPhotos.first,
                    initials: adoption.pets.name,
                    size: 32,
                  ),
                  if (adoption.pets.adopted != null)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: PawsColors.success,
                        ),
                        child: PawsText(
                          'ADOPTED',
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
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
