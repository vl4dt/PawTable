import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/navigation/routes.dart';

/// Profile screen — app info, version, rate, share, about
///
/// Displays:
/// - App branding
/// - Version number
/// - Rate the app
/// - Share PawTable
/// - About section
/// - Links to settings
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App branding card
            _buildBrandingCard(context),
            const SizedBox(height: 24),

            // App info section
            _SectionHeader(title: 'App Info'),
            _buildInfoTile(
              context,
              icon: Icons.info_outline,
              title: 'About PawTable',
              subtitle: 'Version 1.0.0 (build 1)',
              onTap: () => _showAboutDialog(context),
            ),
            _buildInfoTile(
              context,
              icon: Icons.star_outline,
              title: 'Rate PawTable',
              subtitle: 'Love PawTable? Rate us on the app store!',
              onTap: () => _rateApp(context),
            ),
            _buildInfoTile(
              context,
              icon: Icons.share_outlined,
              title: 'Share PawTable',
              subtitle: 'Share PawTable with your friends and family',
              onTap: () => _shareApp(context),
            ),

            const Divider(height: 32),

            // Support section
            _SectionHeader(title: 'Support'),
            _buildInfoTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Find answers to common questions',
              onTap: () => _showFAQ(context),
            ),
            _buildInfoTile(
              context,
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Found an issue? Let us know!',
              onTap: () => _reportBug(context),
            ),
            _buildInfoTile(
              context,
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Share your ideas and suggestions',
              onTap: () => _sendFeedback(context),
            ),

            const Divider(height: 32),

            // Settings quick links
            _SectionHeader(title: 'Quick Links'),
            _buildInfoTile(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Notifications, privacy, appearance',
              onTap: () {
                context.go(AppRoutes.settings);
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.lock_outline,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => _showPrivacyPolicy(context),
            ),
            _buildInfoTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Terms and conditions of use',
              onTap: () => _showTermsOfService(context),
            ),

            const Divider(height: 32),

            // Premium section
            _SectionHeader(title: 'Upgrade'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PawTableColors.premium,
                    PawTableColors.premiumDark,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Go Premium',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock unlimited pets, advanced analytics, and priority support',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.premium);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: PawTableColors.premiumDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Upgrade Now'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // App tagline
            Text(
              'PawTable — Your Pet, At Your Table',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PawTableColors.onSurfaceMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: PawTableColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PawTableColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: PawTableColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_rounded,
              size: 56,
              color: PawTableColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PawTable',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PawTableColors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PawTableColors.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: PawTableColors.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PawTableColors.onSurfaceMuted,
            ),
      ),
      trailing:
          const Icon(Icons.chevron_right, size: 20, color: PawTableColors.onSurfaceMuted),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PawTable',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 PawTable',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'PawTable helps pet owners track feeding, medications, vaccinations, weight, and more. Built with love for pets everywhere.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening app store...')),
    );
  }

  void _shareApp(BuildContext context) {
    // In production, use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share PawTable with friends!')),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              _FAQItem(
                question: 'How do I add a new pet?',
                answer:
                    'Go to Settings > Profile > About PawTable to access your pet management.',
              ),
              SizedBox(height: 16),
              _FAQItem(
                question: 'Can I track multiple pets?',
                answer:
                    'Yes! Free users can track 1 pet, premium users get unlimited pets.',
              ),
              SizedBox(height: 16),
              _FAQItem(
                question: 'How do I cancel my subscription?',
                answer:
                    'Go to Settings > Subscription and tap Cancel Subscription.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reportBug(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please describe the bug you encountered:',
              style: TextStyle(color: PawTableColors.onSurfaceMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                const SnackBar(content: Text('Bug report sent! Thank you.')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We love hearing from you! Share your ideas:',
              style: TextStyle(color: PawTableColors.onSurfaceMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                const SnackBar(content: Text('Feedback sent! Thank you.')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'PawTable collects minimal data to provide pet care tracking features. '
            'Your data is stored locally on your device and optionally synced to the cloud.\n\n'
            'We do not sell your data to third parties.\n\n'
            'For full details, visit our website.',
            style: TextStyle(color: PawTableColors.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'By using PawTable, you agree to our terms of service. '
            'PawTable is provided "as is" without warranty.\n\n'
            'You may not use PawTable for any illegal purposes.',
            style: TextStyle(color: PawTableColors.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PawTableColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
