import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/router/app_route.dart';
import 'package:paws_connect/dependency.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/paws_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('323cc2fb-7bab-418b-954e-a578788499bd');
  debugPrint(
    'OneSignal SDK initialized: ${await OneSignal.User.getExternalId()}',
  );
  OneSignal.Notifications.requestPermission(false);
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
      builder: EasyLoading.init(),

      routerConfig: appRouter.config(),
    );
  }
}
