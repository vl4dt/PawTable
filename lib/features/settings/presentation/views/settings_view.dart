import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';

/// Settings screen — account, notifications, privacy, and app preferences
///
/// Provides:
/// - Account section (change email, delete account)
/// - Notifications (push, sounds, reminders)
/// - Privacy & data (data sharing, clear cache)
/// - Appearance (theme selection)
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Account Section
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Email',
            subtitle: 'ricr.sb@gmail.com',
            onTap: () => _showChangeEmail(context),
          ),
          _SettingsTile(
            icon: Icons.security,
            title: 'Change Password',
            onTap: () => _showChangePassword(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: PawTableColors.error),
            title: const Text('Delete Account'),
            subtitle: const Text('Permanently delete your account and all data'),
            onTap: () => _confirmDeleteAccount(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const Divider(height: 32),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          const _SettingsToggle(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Get reminders for feeding, meds, and vet visits',
          ),
          const _SettingsToggle(
            icon: Icons.volume_up_outlined,
            title: 'Sound Effects',
            subtitle: 'Play sounds for notifications and celebrations',
          ),
          const _SettingsToggle(
            icon: Icons.alarm_outlined,
            title: 'Smart Reminders',
            subtitle: 'Automatic reminders based on feeding schedule',
          ),

          const Divider(height: 32),

          // Privacy & Data Section
          _SectionHeader(title: 'Privacy & Data'),
          const _SettingsToggle(
            icon: Icons.cloud_outlined,
            title: 'Cloud Backup',
            subtitle: 'Automatically backup your pet data',
          ),
          const _SettingsToggle(
            icon: Icons.analytics_outlined,
            title: 'Usage Analytics',
            subtitle: 'Help improve PawTable with anonymous usage data',
          ),
          _SettingsTile(
            icon: Icons.clear_all_outlined,
            title: 'Clear Cache',
            subtitle: 'Free up storage by clearing cached data',
            onTap: () => _clearCache(context),
          ),

          const Divider(height: 32),

          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(
              _getThemeLabel(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PawTableColors.onSurfaceMuted,
                  ),
            ),
            trailing: Icon(
              _getThemeIcon(),
              color: PawTableColors.primary,
            ),
            onTap: () => _showThemeSelector(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          ListTile(
            leading: const Icon(Icons.format_size_outlined),
            title: const Text('Font Size'),
            subtitle: Text(
              _getFontSizeLabel(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PawTableColors.onSurfaceMuted,
                  ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right, color: PawTableColors.primary),
            onTap: () => _showFontSizeSelector(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeLabel() => 'Follow System';

  IconData _getThemeIcon() => Icons.brightness_auto;

  String _getFontSizeLabel() => 'Medium';

  void _showChangeEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _ChangeEmailDialog(),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _ChangePasswordDialog(),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your pet data, feeding logs, and health records will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.cleaning_services_rounded, color: PawTableColors.successDark),
        title: const Text('Clear Cache'),
        content: const Text('This will free up approximately 50MB of cached data. Your pet data is safe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _ThemeSelectorSheet(),
    );
  }

  void _showFontSizeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FontSizeSelectorSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PawTableColors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: PawTableColors.primary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PawTableColors.onSurfaceMuted,
                  ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: PawTableColors.onSurfaceMuted),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: PawTableColors.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PawTableColors.onSurfaceMuted,
            ),
      ),
      trailing: Switch(
        value: true,
        onChanged: (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title: ${value ? "ON" : "OFF"}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        activeThumbColor: PawTableColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ChangeEmailDialog extends StatelessWidget {
  const _ChangeEmailDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Email'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Current Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'New Email',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatelessWidget {
  const _ChangePasswordDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Current Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _ThemeSelectorSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('System Default'),
            trailing: Icon(Icons.brightness_auto, color: PawTableColors.primary),
          ),
          ListTile(
            title: const Text('Light Mode'),
            trailing: const Icon(Icons.light_mode, color: PawTableColors.primary),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: const Icon(Icons.dark_mode, color: PawTableColors.primary),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _FontSizeSelectorSheet extends StatelessWidget {
  const _FontSizeSelectorSheet();

  @override
  Widget build(BuildContext context) {
    final sizes = ['Small', 'Medium', 'Large', 'Extra Large'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: sizes.asMap().entries.map((entry) {
          final idx = entry.key;
          final size = entry.value;
          return ListTile(
            title: Text(size),
            trailing: idx == 1
                ? const Icon(Icons.check, color: PawTableColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(),
          );
        }).toList(),
      ),
    );
  }
}
