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


  Future<void>  _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Changed to white for light theme
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Apply border radius here
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: Theme.of(context).colorScheme.background,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          animSpeedFactor: 2,
          child: ListView(
            children: ListTile.divideTiles( // This will add a divider between list items
              color: Theme.of(context).colorScheme.background, // Divider color for light theme
              context: context,
              tiles: [
                glassmorphicContainer(
                  context: context,
                  child: SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () => navigateToSettingsDetail(context, 'Language'),
                  ),
                ),
                glassmorphicContainer(
                  context: context,
                  child: SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Dark mode',
                    onTap: () {}, // Adjust onTap according to your needs, or leave it empty if the toggle itself handles the logic.
                    trailingWidget: Switch(
                      value: _isDarkMode,
                      onChanged: (bool value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                        // Implement logic to update the theme based on _isDarkMode
                        // Example:
                        // updateTheme(_isDarkMode);
                      },                    ),
                  ),
                ),
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
                    trailingWidget: const Text('1.0.0'),                  ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface, // Custom background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners for the dialog
          ),
          title: Text(
            'Confirm Sign Out',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, // Custom text color
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out and proceed to facial recognition?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, // Custom color for button text
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BlockchainAuthentification(documentNumber: '0987654321',)),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, // Different color for the confirm button
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

  void navigateToSettingsDetail(BuildContext context, String settingsName) {
    // Navigate to the corresponding settings detail page
    // For now, just print the settings name
  }

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final IconData? trailing; // Nullable trailing icon for cases where an icon is used
  final String title;
  final VoidCallback onTap;
  final Widget? trailingWidget; // New parameter for custom trailing widget (like a toggle switch)

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.trailingWidget, // Optional widget for the trailing position
  }) : assert(trailing == null || trailingWidget == null, 'Cannot provide both a trailing icon and a trailing widget.'), // Ensure that both aren't provided simultaneously
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      // Use the provided trailing widget if it's not null; otherwise, use the provided trailing icon or a default icon.
      trailing: trailingWidget ?? (trailing != null ? Icon(trailing, color: Theme.of(context).colorScheme.primary) : Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary)),
      onTap: onTap,
    );
  }
}

