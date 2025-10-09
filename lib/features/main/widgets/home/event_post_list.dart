// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_connect/features/events/models/event_model.dart';
import 'package:provider/provider.dart';

import '../../../../core/repository/common_repository.dart';
import '../../../../core/router/app_route.gr.dart';
import '../../../../core/theme/paws_theme.dart';
import '../../../../core/widgets/text.dart';
import '../event_container.dart';

class EventPostList extends StatelessWidget {
  final OverlayPortalController overlayController;
  final List<Event> events;
  const EventPostList({
    super.key,
    required this.overlayController,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            PawsText(
              'Posted by Admin',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            GestureDetector(
              onTap: () {
                overlayController.toggle();
              },
              child: OverlayPortal(
                controller: overlayController,
                overlayChildBuilder: (context) {
                  return Positioned(
                    top: 85,
                    left: 50,
                    right: 50,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.70,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(66, 94, 85, 85),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PawsText(
                        'Events are posted by the admin to keep you informed about upcoming activities and important announcements.',
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: PawsColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: ClampingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: events.map((e) {
              return EventContainer(
                event: e,
                onTap: () => context.router.push(EventDetailRoute(id: e.id)),
                onSuggestionTap: (suggestion) {
                  context.read<CommonRepository>().getSuggestionCompletion(
                    suggestion,
                    '${e.title}, ${e.description}',
                  );
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(),
                    builder: (_) {
                      return Consumer<CommonRepository>(
                        builder: (context, value, child) {
                          final suggestionCompletion =
                              value.suggestionCompletion;
                          return Container(
                            height: MediaQuery.sizeOf(context).height * 0.70,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(),
                            width: MediaQuery.sizeOf(context).width,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PawsText(
                                    suggestion,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  SizedBox(height: 10),
                                  suggestionCompletion == null
                                      ? Center(
                                          child: LottieBuilder.asset(
                                            'assets/json/paw_loader.json',
                                            height: 64,
                                            width: 64,
                                          ),
                                        )
                                      : suggestionCompletion.isEmpty
                                      ? PawsText(
                                          'No suggestions available. Please try again later.',
                                          fontSize: 14,
                                          color: PawsColors.textSecondary,
                                        )
                                      : GptMarkdown(
                                          suggestionCompletion,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: PawsColors.textSecondary,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
