import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paws_connect/core/router/app_route.dart';
import 'package:paws_connect/dependency.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/paws_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_SERVICE_ROLE'),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
      eventsPerSecond: 10,
    ),
    debug: true, // Enable debug mode for development
  );
  init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paws Connect',
      theme: PawsTheme.lightTheme,
      // darkTheme: PawsTheme.darkTheme,
      themeMode: ThemeMode.system,

      routerConfig: appRouter.config(),
    );
  }
}
