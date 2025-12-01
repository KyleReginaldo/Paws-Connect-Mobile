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
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/session/session_manager.dart';
import 'core/supabase/client.dart';
import 'core/theme/paws_theme.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/payment/provider/payment_provider.dart';
import 'firebase_options.dart';
import 'flavors/flavor_config.dart';

void mainCommon({
  required Flavor flavor,
  required String apiBaseUrl,
  required String supabaseUrl,
  required String supabaseServiceRoleKey,
  required String appName,
  required String logoUrl,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlavorConfig(
    flavor: flavor,
    apiBaseUrl: apiBaseUrl,
    supabaseUrl: supabaseUrl,
    supabaseServiceRoleKey: supabaseServiceRoleKey,
    appName: appName,
    logoUrl: logoUrl,
  );
  await Supabase.initialize(
    url: FlavorConfig.instance.supabaseUrl,
    anonKey: FlavorConfig.instance.supabaseServiceRoleKey,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
      eventsPerSecond: 10,
    ),
    debug: true,
  );
  Gemini.init(apiKey: dotenv.get('GEMINI_API_KEY'));
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
      child: Theme(
        data: PawsTheme.lightTheme,
        child: shadcn.ShadcnApp.router(
          title: FlavorConfig.instance.appName,
          debugShowCheckedModeBanner: false,
          // debugShowMaterialGrid: true,
          theme: shadcn.ThemeData(
            platform: shadcn.TargetPlatform.fuchsia,
            colorScheme: shadcn.ColorScheme(
              brightness: Brightness.light,
              primary: PawsColors.primary,
              foreground: PawsColors.textPrimary,
              card: PawsColors.surface,
              cardForeground: PawsColors.textPrimary,
              popover: PawsColors.surface,
              popoverForeground: PawsColors.textPrimary,
              secondary: PawsColors.secondary,
              primaryForeground: PawsColors.textLight,
              secondaryForeground: PawsColors.textLight,
              muted: PawsColors.disabled,
              mutedForeground: PawsColors.textSecondary,
              accent: PawsColors.accent,
              accentForeground: PawsColors.textPrimary,
              destructive: PawsColors.error,
              border: PawsColors.border,
              input: PawsColors.border,
              ring: PawsColors.primary,
              background: PawsColors.background,
              chart1: PawsColors.primary,
              chart2: PawsColors.secondary,
              chart3: PawsColors.accent,
              chart4: PawsColors.info,
              chart5: PawsColors.success,
              sidebar: PawsColors.surface,
              sidebarForeground: PawsColors.textPrimary,
              sidebarPrimary: PawsColors.primary,
              sidebarPrimaryForeground: PawsColors.textLight,
              sidebarAccent: PawsColors.accent,
              sidebarAccentForeground: PawsColors.textPrimary,
              sidebarBorder: PawsColors.border,
              sidebarRing: PawsColors.primary,
            ),
          ),
          // darkTheme: PawsTheme.darkTheme,
          themeMode: shadcn.ThemeMode.light,
          builder: EasyLoading.init(),
          routerConfig: appRouter.config(
            deepLinkBuilder: (deepLink) async {
              final segments = deepLink.path
                  .split('/')
                  .where((s) => s.isNotEmpty)
                  .toList();
              debugPrint('${DateTime.now()}: Deep link path: ${deepLink.path}');
              debugPrint('${DateTime.now()}: Deep link segments: $segments');
              debugPrint(
                '${DateTime.now()}: Deep link query: ${deepLink.uri.queryParameters}',
              );
              String? id = deepLink.path.split('/').last;
              debugPrint('${DateTime.now()}: Initial id from segments: $id');
              // For /adopt/id or /adopt/id/extra

              String? donor = deepLink.uri.queryParameters['donor'];
              double? amount = double.tryParse(
                deepLink.uri.queryParameters['amount'].toString(),
              );
              String? invitedBy = deepLink.uri.queryParameters['invitedBy'];
              debugPrint(
                '${DateTime.now()}: donor: $donor, amount: $amount, invitedBy: $invitedBy, USER_ID: $USER_ID',
              );
              if (deepLink.path.contains('forum-invite') && invitedBy != null) {
                debugPrint(
                  '${DateTime.now()}: forum-invite deep link detected',
                );
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
              }
              if (deepLink.path.contains('payment-success') &&
                  donor != null &&
                  amount != null) {
                debugPrint(
                  '${DateTime.now()}: payment-success deep link detected',
                );
                PaymentProvider().confirmDonation(
                  donor: donor,
                  amount: amount,
                  fundraisingId: int.parse(id),
                );
                return DeepLink([PaymentSuccessRoute(id: int.parse(id))]);
              }
              if (deepLink.path.contains('fundraising')) {
                debugPrint('${DateTime.now()}: fundraising deep link detected');
                return DeepLink([
                  MainRoute(),
                  FundraisingDetailRoute(id: int.parse(id)),
                ]);
              }
              if (deepLink.path.contains('forum-chat')) {
                debugPrint('${DateTime.now()}: forum-chat deep link detected');
                return DeepLink([
                  MainRoute(),
                  ForumChatRoute(forumId: int.parse(id)),
                ]);
              }
              if (deepLink.path.contains('pet-details')) {
                debugPrint('${DateTime.now()}: pet-details deep link detected');
                return DeepLink([
                  MainRoute(),
                  PetDetailRoute(id: int.parse(id)),
                ]);
              }
              if (deepLink.path.contains('adopt')) {
                debugPrint(
                  '${DateTime.now()}: adopt deep link detected, USER_ID: $USER_ID',
                );
                return DeepLink([
                  MainRoute(),
                  PetDetailRoute(id: int.parse(id)),
                  if (USER_ID != null)
                    CreateAdoptionRoute(petId: int.parse(id)),
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
                    await SessionManager.bootstrapAfterSignIn(eager: false);
                  }
                }
              }
              debugPrint(
                '${DateTime.now()}: No matching deep link, returning default path',
              );
              return DeepLink.defaultPath;
            },
          ),
        ),
      ),
    );
  }
}
