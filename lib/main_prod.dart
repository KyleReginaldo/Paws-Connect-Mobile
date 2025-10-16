import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paws_connect/flavors/flavor_config.dart';
import 'package:paws_connect/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: ".env.prod");
  String apiBaseUrl = "https://paws-connect-rho.vercel.app/api/v1";
  String supabaseUrl = "https://fjogjfdhtszaycqirwpm.supabase.co";
  String supabaseServiceRoleKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqb2dqZmRodHN6YXljcWlyd3BtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0OTcwOTc1MywiZXhwIjoyMDY1Mjg1NzUzfQ.gpjlUhaBUxoZSi5_8DOg8Uqs6STkC1QXmlZ9PaxPYeE";
  String appName = "Paws Connect";
  mainCommon(
    flavor: Flavor.dev,
    apiBaseUrl: apiBaseUrl,
    supabaseUrl: supabaseUrl,
    supabaseServiceRoleKey: supabaseServiceRoleKey,
    appName: appName,
  );
}
