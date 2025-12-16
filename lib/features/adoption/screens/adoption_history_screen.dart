import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/ext.dart';
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
      body: adoptions != null && adoptions.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                await context.read<AdoptionRepository>().fetchUserAdoptions(
                  USER_ID ?? "",
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: adoptions.length,
                itemBuilder: (context, index) {
                  final adoption = adoptions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        context.router.push(
                          AdoptionDetailRoute(id: adoption.id),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Pet Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: UserAvatar(
                                      imageUrl:
                                          adoption.pets.transformedPhotos.first,
                                      initials: adoption.pets.name,
                                      size: 56,
                                    ),
                                  ),
                                  if (adoption.pets.adopted != null)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: PawsColors.success,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 12),
                              // Pet Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PawsText(
                                            adoption.pets.name ?? "Unnamed Pet",
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: adoption.status.color
                                                .withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: PawsText(
                                            adoption.status.capitalize(),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: adoption.status.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                        SizedBox(width: 4),
                                        PawsText(
                                          timeago.format(adoption.createdAt),
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16),
                  PawsText(
                    'No adoption history',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(height: 8),
                  PawsText(
                    'Your adoption requests will appear here',
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
    );
  }
}
