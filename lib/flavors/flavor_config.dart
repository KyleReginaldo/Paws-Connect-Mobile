enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseServiceRoleKey;
  final String appName;
  final String logoUrl;

  static FlavorConfig? _instance;
  FlavorConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseServiceRoleKey,
    required this.appName,
    required this.logoUrl,
  });

  factory FlavorConfig({
    required Flavor flavor,
    required String apiBaseUrl,
    required String supabaseUrl,
    required String supabaseServiceRoleKey,
    required String appName,
    required String logoUrl,
  }) {
    _instance ??= FlavorConfig._(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      supabaseUrl: supabaseUrl,
      supabaseServiceRoleKey: supabaseServiceRoleKey,
      appName: appName,
      logoUrl: logoUrl,
    );
    return _instance!;
  }

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception('FlavorConfig is not initialized');
    }
    return _instance!;
  }

  static bool isProduction() => _instance?.flavor == Flavor.prod;
  static bool isDevelopment() => _instance?.flavor == Flavor.dev;
  static bool isStaging() => _instance?.flavor == Flavor.staging;
}
