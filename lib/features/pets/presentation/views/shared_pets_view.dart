import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/shared_pet_profile_entity.dart';
import '../providers/shared_pet_profile_provider.dart';
import '../../../../features/family/domain/entities/family_group_entity.dart';

/// Shared pets view — shows all pets shared with the family group
/// with permission-aware editing capabilities
class SharedPetsView extends ConsumerStatefulWidget {
  final String groupId;
  final String currentUserId;
  final String currentUserName;
  final List<FamilyMemberEntity> members;

  const SharedPetsView({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.currentUserName,
    required this.members,
  });

  @override
  ConsumerState<SharedPetsView> createState() => _SharedPetsViewState();
}

class _SharedPetsViewState extends ConsumerState<SharedPetsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sharedPetProfileProvider.notifier).loadProfiles(
            groupId: widget.groupId,
            userId: widget.currentUserId,
            userName: widget.currentUserName,
            members: widget.members,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sharedPetProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Pets'),
        backgroundColor: PawTableColors.surface,
        foregroundColor: PawTableColors.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(sharedPetProfileProvider.notifier).refresh(
                    groupId: widget.groupId,
                    userId: widget.currentUserId,
                    userName: widget.currentUserName,
                    members: widget.members,
                  );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorState(error: state.error!)
              : _SharedPetsContent(
                  state: state,
                  groupId: widget.groupId,
                  currentUserId: widget.currentUserId,
                  currentUserName: widget.currentUserName,
                  members: widget.members,
                ),
    );
  }
}

/// Main content for shared pets
class _SharedPetsContent extends ConsumerWidget {
  final SharedPetProfileState state;
  final String groupId;
  final String currentUserId;
  final String currentUserName;
  final List<FamilyMemberEntity> members;

  const _SharedPetsContent({
    required this.state,
    required this.groupId,
    required this.currentUserId,
    required this.currentUserName,
    required this.members,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.profiles.isEmpty) {
      return const _EmptySharedPets();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(sharedPetProfileProvider.notifier)
            .refresh(
              groupId: groupId,
              userId: currentUserId,
              userName: currentUserName,
              members: members,
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(PawTokens.md),
        itemCount: state.profiles.length,
        itemBuilder: (context, index) {
          final profile = state.profiles[index];
          return _SharedPetCard(
            profile: profile,
            onTapped: () {
              // Navigate to pet detail view
              context.push('/pets/${profile.profile.petId}');
            },
            onUnshare: () =>
                _showUnshareDialog(context, ref, profile),
          );
        },
      ),
    );
  }

  void _showUnshareDialog(
    BuildContext context,
    WidgetRef ref,
    SharedPetProfileWithCapabilities profile,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unshare Pet?'),
        content: Text(
          'Remove "${profile.profile.pet.name}" from family access?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(sharedPetProfileProvider.notifier)
                  .unsharePet(profile.profile.id);
              if (success && context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pet unshared'),
                    backgroundColor: PawTableColors.warning,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.error,
            ),
            child: const Text('Unshare'),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no pets are shared
class _EmptySharedPets extends StatelessWidget {
  const _EmptySharedPets();

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
              'No Shared Pets Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              'Share a pet from the family tab\n'
              'to let family members edit it.',
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

/// Individual shared pet card
class _SharedPetCard extends StatelessWidget {
  final SharedPetProfileWithCapabilities profile;
  final VoidCallback onTapped;
  final VoidCallback onUnshare;

  const _SharedPetCard({
    required this.profile,
    required this.onTapped,
    required this.onUnshare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: PawTokens.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
      ),
      child: InkWell(
        onTap: profile.canEditLogs ? onTapped : null,
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(PawTokens.md),
          child: Row(
            children: [
              // Pet avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PawTableColors.primary
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.pets_rounded,
                    color: PawTableColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: PawTokens.md),
              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.profile.pet.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: PawTableColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Shared by ${profile.profile.sharedByName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PawTableColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Edit capabilities
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _getCapabilityBadges(context),
                    ),
                  ],
                ),
              ),
              // Actions
              if (profile.canManage)
                IconButton(
                  icon: const Icon(
                      Icons.link_off_rounded, size: 20),
                  onPressed: onUnshare,
                  tooltip: 'Unshare Pet',
                  color: PawTableColors.error,
                ),
              Icon(
                Icons.chevron_right,
                color: PawTableColors.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getCapabilityBadges(BuildContext context) {
    final caps = profile.capabilities;
    final badges = <Widget>[];

    if (caps.canFeed) {
      badges.add(_CapabilityBadge(label: 'Feed'));
    }
    if (caps.canVaccinate) {
      badges.add(_CapabilityBadge(label: 'Vaccine'));
    }
    if (caps.canMedicate) {
      badges.add(_CapabilityBadge(label: 'Meds'));
    }
    if (caps.canWeight) {
      badges.add(_CapabilityBadge(label: 'Weight'));
    }
    if (caps.canBehavior) {
      badges.add(_CapabilityBadge(label: 'Behavior'));
    }
    if (caps.canHealth) {
      badges.add(_CapabilityBadge(label: 'Health'));
    }

    return badges;
  }
}

/// Capability badge
class _CapabilityBadge extends StatelessWidget {
  final String label;
  const _CapabilityBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: PawTableColors.primary
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PawTokens.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: PawTableColors.primary,
        ),
      ),
    );
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
            const Text('⚠️',
                style: TextStyle(fontSize: 48)),
            const SizedBox(height: PawTokens.md),
            Text(
              'Failed to load shared pets',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              error,
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
