import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../../blockchain_back/blockchain/blockchain_authentification.dart';
import '../../utils/glassmorphismContainer.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: Theme.of(context).colorScheme.background,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          animSpeedFactor: 2,
          child: ListView(
            children: ListTile.divideTiles(
              color: Theme.of(context).colorScheme.background,
              context: context,
              tiles: [
                glassmorphicContainer(
                  context: context,
                  child: SettingsTile(
                    icon: Icons.support,
                    title: 'Help',
                    onTap: () => navigateToSettingsDetail(context, 'Help'),
                  ),
                ),
                glassmorphicContainer(
                  context: context,
                  child: SettingsTile(
                    icon: Icons.update,
                    title: 'Version',
                    onTap: () => navigateToSettingsDetail(context, 'Version'),
                    trailingWidget: const Text('1.0.0'),
                  ),
                ),
                glassmorphicContainer(
                  context: context,
                  child: SettingsTile(
                    icon: Icons.logout,
                    title: 'Sign out',
                    onTap: () => _confirmSignOut(context),
                  ),
                ),
              ],
            ).toList(),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    AwesomeDialog(
      context: context,
      customHeader: Icon(
        Icons.warning,
        size: 70,
        color: Theme.of(context).colorScheme.primary,
      ),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Confirm Sign Out',
      desc: 'Are you sure you want to sign out?',
      btnCancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cancel',
          style: TextStyle(color: Theme.of(context).colorScheme.primary), // Change cancel text color here
        ),
      ),
      btnOkOnPress: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BlockchainAuthentification(documentNumber: '0987654321')),
              (Route<dynamic> route) => false,
        );
      },
      btnOkText: 'Confirm',
      btnOkColor: Theme.of(context).colorScheme.secondary,
    ).show();
  }
}

void navigateToSettingsDetail(BuildContext context, String settingsName) {
  // Navigate to the corresponding settings detail page
  // For now, just print the settings name
  print('Navigating to $settingsName settings detail');
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final IconData? trailing;
  final String title;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.trailingWidget,
  }) : assert(trailing == null || trailingWidget == null, 'Cannot provide both a trailing icon and a trailing widget.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      trailing: trailingWidget ?? (trailing != null ? Icon(trailing, color: Theme.of(context).colorScheme.primary) : Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary)),
      onTap: onTap,
    );
  }
}
