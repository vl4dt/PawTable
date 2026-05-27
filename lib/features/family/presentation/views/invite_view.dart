import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../features/family/domain/entities/invite_entity.dart';
import '../providers/invite_provider.dart';

/// Invite management screen — create, share, and manage family invites
class InviteView extends ConsumerWidget {
  final String groupId;
  final String createdById;

  const InviteView({
    super.key,
    required this.groupId,
    required this.createdById,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inviteState = ref.watch(inviteNotifierProvider);
    final notifier = ref.read(inviteNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Family'),
        actions: [
          if (inviteState.inviteToken != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Regenerate invite',
              onPressed: () async {
                final token = await notifier.createInvite(
                  groupId: groupId,
                  createdById: createdById,
                );
                if (token != null && context.mounted) {
                  _showInviteDialog(context, token, (t) => notifier.copyInviteCode(t));
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            _buildInstructions(context),
            const SizedBox(height: 24),

            // Create invite button or active invite
            if (inviteState.inviteToken == null)
              _buildCreateInviteButton(context, notifier)
            else
              _buildActiveInviteCard(context, notifier, inviteState.inviteToken!),

            const Divider(height: 40),

            // Invite settings
            _buildInviteSettings(context),

            const SizedBox(height: 24),

            // How it works
            _buildHowItWorks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_add_rounded,
                  color: PawTableColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invite Family Members',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a unique invite link or code that your family can use to join your PawTable family group.',
                        style: TextStyle(
                          fontSize: 14,
                          color: PawTableColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateInviteButton(
    BuildContext context,
    InviteNotifier notifier,
  ) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final token = await notifier.createInvite(
            groupId: groupId,
            createdById: createdById,
          );
          if (token != null && context.mounted) {
            _showInviteDialog(context, token, (t) => notifier.copyInviteCode(t));
          }
        },
        icon: const Icon(Icons.link_rounded),
        label: const Text('Create Invite Link'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          backgroundColor: PawTableColors.primary,
        ),
      ),
    );
  }

  Widget _buildActiveInviteCard(
    BuildContext context,
    InviteNotifier notifier,
    InviteToken token,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Invite code display
            Text(
              'Your invite code:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: PawTableColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: PawTableColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PawTableColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                token.code,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: PawTableColors.primaryDark,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Copy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  notifier.copyInviteCode(token);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invite code copied!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.content_copy_rounded),
                label: const Text('Copy Invite Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawTableColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Deep link
            Text(
              token.toShareLink(),
              style: TextStyle(
                fontSize: 13,
                color: PawTableColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Cancel button
            OutlinedButton(
              onPressed: () async {
                await notifier.cancelInvite(token.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite cancelled.'),
                      backgroundColor: PawTableColors.warning,
                    ),
                  );
                }
              },
              child: const Text('Cancel Invite'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invite Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PawTableColors.primaryDark,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.key_off_rounded,
                color: PawTableColors.primary),
            title: const Text('One-Time Use'),
            subtitle: const Text(
                'Invite can only be used once. Each new link generates a fresh code.'),
            trailing: const Icon(Icons.check_circle,
                color: PawTableColors.success),
          ),
        ),
        Card(
          child: ListTile(
            leading:
                Icon(Icons.timer_rounded, color: PawTableColors.primary),
            title: const Text('Expires in 7 days'),
            subtitle: const Text(
                'Invites automatically expire after 7 days for security.'),
            trailing: const Icon(Icons.check_circle,
                color: PawTableColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PawTableColors.primaryDark,
              ),
        ),
        const SizedBox(height: 12),
        _buildStep(context, 1, 'Share the invite link or code'),
        _buildStep(context, 2, 'Family member taps the link or enters the code'),
        _buildStep(context, 3, 'They join your family group automatically'),
      ],
    );
  }

  Widget _buildStep(BuildContext context, int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: PawTableColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    InviteToken token,
    void Function(InviteToken) onCopy,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Ready!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this code with your family:'),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: PawTableColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  token.code,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Or share the link:',
              style: TextStyle(
                fontSize: 13,
                color: PawTableColors.onSurfaceVariant,
              ),
            ),
            Text(
              token.toShareLink(),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              onCopy(token);
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.content_copy_rounded),
            label: const Text('Copy Code'),
          ),
        ],
      ),
    );
  }
}
