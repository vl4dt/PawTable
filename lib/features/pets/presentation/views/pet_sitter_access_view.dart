import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/pet_sitter_access_entity.dart';
import '../providers/pet_sitter_access_provider.dart';

/// Pet sitter access view — manage time-limited access for pet sitters
class PetSitterAccessView extends StatelessWidget {
  final String groupId;

  const PetSitterAccessView({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return _PetSitterAccessContent(groupId: groupId);
  }
}

/// Content area for sitter access list
class _PetSitterAccessContent extends ConsumerWidget {
  final String groupId;

  const _PetSitterAccessContent({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(petSitterAccessProvider.notifier)
          .loadActiveAccess(groupId: groupId);
    });

    final state = ref.watch(petSitterAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Sitter Access'),
        backgroundColor: PawTableColors.surface,
        foregroundColor: PawTableColors.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref
                  .read(petSitterAccessProvider.notifier)
                  .loadActiveAccess(groupId: groupId);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorState(error: state.error!)
              : _SitterAccessBody(
                  state: state,
                  groupId: groupId,
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAccessDialog(context),
        backgroundColor: PawTableColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Sitter'),
      ),
    );
  }

  void _showCreateAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateAccessDialog(
        groupId: groupId,
      ),
    );
  }
}

/// Body content for sitter access list
class _SitterAccessBody extends ConsumerWidget {
  final PetSitterAccessState state;
  final String groupId;

  const _SitterAccessBody({
    required this.state,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.activeAccess.isEmpty) {
      return const _EmptySitterAccess();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(petSitterAccessProvider.notifier)
            .loadActiveAccess(groupId: groupId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(PawTokens.md),
        itemCount: state.activeAccess.length,
        itemBuilder: (context, index) {
          final summary = state.activeAccess[index];
          return _SitterAccessCard(summary: summary);
        },
      ),
    );
  }
}

/// Empty state for sitter access
class _EmptySitterAccess extends StatelessWidget {
  const _EmptySitterAccess();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 80,
              color: PawTableColors.onSurfaceVariant,
            ),
            const SizedBox(height: PawTokens.md),
            Text(
              'No Sitter Access Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              'Add time-limited access for pet sitters\nso they can view and log care activities.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PawTableColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual sitter access card
class _SitterAccessCard extends ConsumerWidget {
  final PetSitterAccessSummary summary;

  const _SitterAccessCard({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final access = summary.access;
    final isActive = access.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: PawTokens.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Sitter avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? PawTableColors.primary.withValues(alpha: 0.15)
                        : PawTableColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pets_rounded,
                      color: isActive
                          ? PawTableColors.primary
                          : PawTableColors.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: PawTokens.md),
                // Sitter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        access.petSitterName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (access.petSitterPhone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          access.petSitterPhone!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PawTableColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? PawTableColors.primary.withValues(alpha: 0.1)
                        : PawTableColors.error.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(PawTokens.radiusSm),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Expired',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PawTableColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PawTokens.md),
            // Expiry info
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: PawTableColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${_formatDate(access.expiresAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PawTableColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: PawTableColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${access.timeRemainingText} remaining',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PawTableColors.warning,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: PawTokens.md),
            // Granted by
            Text(
              'Granted by ${access.grantedByName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: PawTableColors.onSurfaceMuted,
              ),
            ),
            // Actions
            if (isActive) ...[
              const SizedBox(height: PawTokens.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showExtendDialog(context, access),
                      child: const Text('Extend'),
                    ),
                  ),
                  const SizedBox(width: PawTokens.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showRevokeConfirmation(context, ref, access.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawTableColors.error,
                      ),
                      child: const Text('Revoke'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showExtendDialog(
    BuildContext context,
    PetSitterAccess access,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _ExtendAccessDialog(
        access: access,
      ),
    );
  }

  void _showRevokeConfirmation(
    BuildContext context,
    WidgetRef ref,
    String accessId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Sitter Access?'),
        content: const Text(
          'This will immediately revoke the pet sitter\'s access to their assigned pet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(petSitterAccessProvider.notifier)
                  .revokeAccess(accessId);
              if (success && context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sitter access revoked'),
                    backgroundColor: PawTableColors.warning,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}

/// Dialog to create new sitter access
class _CreateAccessDialog extends ConsumerStatefulWidget {
  final String groupId;
  const _CreateAccessDialog({required this.groupId});

  @override
  ConsumerState<_CreateAccessDialog> createState() =>
      _CreateAccessDialogState();
}

class _CreateAccessDialogState
    extends ConsumerState<_CreateAccessDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  SitterDuration _selectedDuration = SitterDuration.oneDay;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Pet Sitter'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sitter Name'),
            const SizedBox(height: PawTokens.xs),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Jane Smith',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: PawTokens.md),
            const Text('Phone (optional)'),
            const SizedBox(height: PawTokens.xs),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'e.g., 555-0100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: PawTokens.md),
            const Text('Email (optional)'),
            const SizedBox(height: PawTokens.xs),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'e.g., jane@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: PawTokens.md),
            const Text('Access Duration'),
            const SizedBox(height: PawTokens.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SitterDuration.values
                  .map(
                    (duration) => FilterChip(
                      label: Text(duration.label),
                      selected: _selectedDuration == duration,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDuration = duration;
                          });
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a sitter name'),
        ),
      );
      return;
    }

    final success = await ref
        .read(petSitterAccessProvider.notifier)
        .createAccess(
          petId: '', // TODO: Select pet from existing pets
          groupId: widget.groupId,
          petSitterName: name,
          petSitterPhone: _phoneController.text.trim(),
          petSitterEmail: _emailController.text.trim(),
          grantedBy: 'user-current', // TODO: Use auth provider
          grantedByName: 'Current User',
          duration: _selectedDuration,
        );

    if (success && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sitter access added'),
          backgroundColor: PawTableColors.success,
        ),
      );
    }
  }
}

/// Dialog to extend access duration
class _ExtendAccessDialog extends ConsumerStatefulWidget {
  final PetSitterAccess access;
  const _ExtendAccessDialog({required this.access});

  @override
  ConsumerState<_ExtendAccessDialog> createState() =>
      _ExtendAccessDialogState();
}

class _ExtendAccessDialogState
    extends ConsumerState<_ExtendAccessDialog> {
  SitterDuration _selectedDuration = SitterDuration.oneDay;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Extend Sitter Access'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extending access for ${widget.access.petSitterName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: PawTokens.md),
          const Text('New Duration'),
          const SizedBox(height: PawTokens.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SitterDuration.values
                .map(
                  (duration) => FilterChip(
                    label: Text(duration.label),
                    selected: _selectedDuration == duration,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDuration = duration;
                        });
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Extend'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final success = await ref
        .read(petSitterAccessProvider.notifier)
        .extendAccess(
          accessId: widget.access.id,
          duration: _selectedDuration,
        );

    if (success && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access extended'),
          backgroundColor: PawTableColors.success,
        ),
      );
    }
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: PawTokens.md),
            Text(
              'Failed to load sitter access',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
