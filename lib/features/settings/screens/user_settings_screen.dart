import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paws_connect/dependency.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../repository/user_settings_repository.dart';
import '../widgets/delete_account_dialog.dart';
import 'change_password_screen.dart';

@RoutePage()
class UserSettingsScreen extends StatefulWidget implements AutoRouteWrapper {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<UserSettingsRepository>(),
      child: this,
    );
  }
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  Future<void> _showDeleteAccountDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: sl<UserSettingsRepository>(),
        child: DeleteAccountDialog(repository: sl<UserSettingsRepository>()),
      ),
    );

    if (result == true && mounted) {
      // Account deletion was successful, navigate to auth screen
      // You might want to sign out the user and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account deleted successfully. Please restart the app.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Navigate to auth screen or restart app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(LucideIcons.lockKeyhole),
            title: const Text('Change Password'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<UserSettingsRepository>(),
                  child: const ChangePasswordScreen(),
                ),
              ),
            ),
          ),

          // ListTile(
          //   leading: const Icon(LucideIcons.phone),
          //   title: const Text('Manage Phone Number'),
          //   onTap: () {
          //     ScaffoldMessenger.of(
          //       context,
          //     ).showSnackBar(const SnackBar(content: Text('coming soon')));
          //   },
          // ),
          const Divider(),

          ListTile(
            leading: const Icon(LucideIcons.info),
            title: const Text('App Version'),
            subtitle: FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else if (snapshot.hasError) {
                  return const SizedBox.shrink();
                } else if (snapshot.hasData) {
                  final packageInfo = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 4),
                    child: PawsText(
                      packageInfo.version,
                      fontSize: 12,
                      color: PawsColors.textPrimary,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(LucideIcons.fileText),
            title: const Text('Terms & Conditions'),
            onTap: () async {
              if (await canLaunchUrl(
                Uri.parse(
                  'https://paws-connect-rho.vercel.app/terms-and-condition',
                ),
              )) {
                await launchUrl(
                  Uri.parse(
                    'https://paws-connect-rho.vercel.app/terms-and-condition',
                  ),
                );
              }
            }, // open URL
          ),
          ListTile(
            leading: const Icon(LucideIcons.fileQuestionMark),
            title: const Text('FAQ'),
            onTap: () async {
              if (await canLaunchUrl(
                Uri.parse('https://paws-connect-rho.vercel.app/faq'),
              )) {
                await launchUrl(
                  Uri.parse('https://paws-connect-rho.vercel.app/faq'),
                );
              }
            },
          ),

          const Divider(),

          ListTile(
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            leading: const Icon(LucideIcons.trash),
            title: const Text('Delete Account'),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}
