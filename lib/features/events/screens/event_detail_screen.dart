// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/features/events/repository/event_repository.dart';
import 'package:provider/provider.dart';

import '../../../dependency.dart';

@RoutePage()
class EventDetailScreen extends StatefulWidget implements AutoRouteWrapper {
  final int id;
  const EventDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EventRepository>(),
      child: this,
    );
  }
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
