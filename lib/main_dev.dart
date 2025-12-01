import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paws_connect/flavors/flavor_config.dart';
import 'package:paws_connect/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: ".env.dev");
  String apiBaseUrl = "http://10.0.2.2:3000/api/v1";
  String supabaseUrl = "http://10.0.2.2:54321";
  String supabaseServiceRoleKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";
  String appName = "[DEV]Paws Connect";
  String logoUrl =
      "https://fjogjfdhtszaycqirwpm.supabase.co/storage/v1/object/public/files/logo/ic_launcher.png";
  mainCommon(
    flavor: Flavor.dev,
    apiBaseUrl: apiBaseUrl,
    supabaseUrl: supabaseUrl,
    supabaseServiceRoleKey: supabaseServiceRoleKey,
    appName: appName,
    logoUrl: logoUrl,
  );
}
