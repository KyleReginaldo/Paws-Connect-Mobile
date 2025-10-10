import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paws_connect/core/router/app_route.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:paws_connect/features/internet/internet.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/session/session_manager.dart';
import 'core/supabase/client.dart';
import 'core/theme/paws_theme.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/payment/provider/payment_provider.dart';
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
    debug: true,
  );
  Gemini.init(apiKey: 'AIzaSyCBPr2uSM7S9oC9ld2eWHytiJHOrTUc2Jg');
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('323cc2fb-7bab-418b-954e-a578788499bd');
  debugPrint(
    'OneSignal SDK initialized: ${await OneSignal.User.getExternalId()}',
  );
  OneSignal.Notifications.requestPermission(true);

  init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    // _initAppLinks();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InternetProvider(),
      child: MaterialApp.router(
        title: 'Paws Connect',
        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,
        theme: PawsTheme.lightTheme,
        // darkTheme: PawsTheme.darkTheme,
        themeMode: ThemeMode.system,
        builder: EasyLoading.init(),
        routerConfig: appRouter.config(
          deepLinkBuilder: (deepLink) async {
            final segments = deepLink.path.split('/');
            final id = segments.length > 2 ? segments[2] : null;
            String? donor = deepLink.uri.queryParameters['donor'];
            double? amount = double.tryParse(
              deepLink.uri.queryParameters['amount'].toString(),
            );
            String? invitedBy = deepLink.uri.queryParameters['invitedBy'];
            if (deepLink.path.contains('forum-invite') &&
                id != null &&
                invitedBy != null) {
              await ForumProvider().invitedMemberFromLink(
                invitedBy: invitedBy,
                forumId: int.parse(id),
                memberId: USER_ID ?? '',
              );
              return DeepLink([
                MainRoute(initialIndex: 4),
                ForumChatRoute(forumId: int.parse(id)),
                ForumSettingsRoute(forumId: int.parse(id)),
              ]);
              // do the function for inviting the member and alread accepted and then navigate to the forum chat
            }
            if (deepLink.path.contains('payment-success') &&
                id != null &&
                donor != null &&
                amount != null) {
              PaymentProvider().confirmDonation(
                donor: donor,
                amount: amount,
                fundraisingId: int.parse(id),
              );
              return DeepLink([PaymentSuccessRoute(id: int.parse(id))]);
            }
            if (deepLink.path.contains('fundraising') && id != null) {
              return DeepLink([
                MainRoute(),
                FundraisingDetailRoute(id: int.parse(id)),
              ]);
            }
            if (deepLink.path.contains('forum-chat') && id != null) {
              return DeepLink([
                MainRoute(),
                ForumChatRoute(forumId: int.parse(id)),
              ]);
            }
            if (deepLink.path.contains('signin')) {
              String? email = deepLink.uri.queryParameters['email'];
              String? password = deepLink.uri.queryParameters['password'];
              debugPrint('${DateTime.now()}: Deep link email: $email');
              debugPrint('${DateTime.now()}: Deep link password: $password');
              if (email != null && password != null) {
                final result = await AuthProvider().signIn(
                  email: email,
                  password: password,
                );
                if (result.isError) {
                  EasyLoading.showError(result.error);
                } else {
                  EasyLoading.showSuccess('Sign in successful');
                  // Preload user-related data
                  await SessionManager.bootstrapAfterSignIn(eager: false);
                  // return DeepLink([MainRoute()]);
                }
              }
            }

            return DeepLink.defaultPath;
          },
        ),
      ),
    );
  }
}
