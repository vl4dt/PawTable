import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/family_group_entity.dart';
import '../../domain/services/family_permission_service.dart';
import '../providers/family_provider.dart';

/// Family view — group creation, member management, pet sharing
class FamilyView extends ConsumerStatefulWidget {
  const FamilyView({super.key});

  @override
  ConsumerState<FamilyView> createState() => _FamilyViewState();
}

class _FamilyViewState extends ConsumerState<FamilyView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyListProvider.notifier).loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family'),
        backgroundColor: PawTableColors.surface,
        foregroundColor: PawTableColors.onBackground,
        elevation: 0,
        actions: [
          if (state.selectedGroup != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMemberDialog(context),
              tooltip: 'Add Member',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorState(error: state.error!)
              : _FamilyContent(state: state),
      floatingActionButton: state.selectedGroup == null && !state.isCreating
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateGroupDialog(context),
              backgroundColor: PawTableColors.primary,
              icon: const Icon(Icons.group_add),
              label: const Text('New Group'),
            )
          : state.selectedGroup != null
              ? FloatingActionButton.extended(
                  onPressed: () => _showSharePetDialog(context),
                  backgroundColor: PawTableColors.successDark,
                  icon: const Icon(Icons.pets),
                  label: const Text('Share Pet'),
                )
              : null,
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Family Group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter group name (e.g., "Smith Family")',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final success = await ProviderScope.containerOf(ctx, listen: false)
                  .read(familyListProvider.notifier)
                  .createGroup(name);
              if (success && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Family group created!'),
                    backgroundColor: PawTableColors.successDark,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: PawTokens.sm),
              TextField(
                controller: userIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final userId = userIdCtrl.text.trim();
              if (name.isEmpty || userId.isEmpty) return;
              final success = await ProviderScope.containerOf(ctx, listen: false)
                  .read(familyListProvider.notifier)
                  .addMember(userId: userId, displayName: name);
              if (success && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name added to the family!'),
                    backgroundColor: PawTableColors.successDark,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSharePetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share Pet with Family'),
        content: const Text('Pet sharing will be linked to the pet detail view.\nThis is a placeholder — pets can be shared via the pet detail screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Main content based on state
class _FamilyContent extends StatelessWidget {
  final FamilyGroupState state;
  const _FamilyContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.groups.isEmpty && state.selectedGroup == null) {
      return const _EmptyFamilyState();
    }

    if (state.selectedGroup != null) {
      return _GroupDetail(state: state);
    }

    return _GroupList(state: state);
  }
}

/// Empty state — no family groups
class _EmptyFamilyState extends StatelessWidget {
  const _EmptyFamilyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_rounded, size: 80, color: PawTableColors.primary),
            const SizedBox(height: PawTokens.md),
            Text(
              'No Family Groups Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PawTokens.sm),
            Text(
              'Create a family group to share pet care\nwith loved ones.',
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

/// Group list view
class _GroupList extends ConsumerWidget {
  final FamilyGroupState state;
  const _GroupList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(PawTokens.md),
      itemCount: state.groups.length,
      itemBuilder: (context, index) {
        final group = state.groups[index];
        return _GroupCard(
          group: group,
          onTap: () {
            ref.read(familyListProvider.notifier).selectGroup(group.id);
          },
        );
      },
    );
  }
}

/// Group card widget
class _GroupCard extends StatelessWidget {
  final FamilyGroupEntity group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(PawTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(PawTokens.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PawTokens.sm),
                decoration: BoxDecoration(
                  color: PawTableColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(PawTokens.radiusMd),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: PawTableColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: PawTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to manage members & shared pets',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PawTableColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: PawTableColors.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Group detail view
class _GroupDetail extends ConsumerWidget {
  final FamilyGroupState state;
  const _GroupDetail({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = state.selectedGroup!;
    final summary = state.summary;

    return CustomScrollView(
      slivers: [
        // Group header
        SliverToBoxAdapter(
          child: _GroupHeader(group: group, summary: summary),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: PawTokens.sm)),

        // Members section
        if (summary != null)
          SliverToBoxAdapter(
            child: _MembersSection(
              group: group,
              summary: summary,
            ),
          ),

        // Permission info (for debugging/education)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(PawTokens.md, 0, PawTokens.md, PawTokens.lg),
            child: Text(
              'Role permissions: Owner (full access) | Admin (manage members, pets, invites) | Member (view, edit own, share pets) | Pet Sitter (view, edit own)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PawTableColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),

        // Shared pets section
        if (summary != null && summary.sharedPetIds.isNotEmpty)
          SliverToBoxAdapter(
            child: _SharedPetsSection(
              group: group,
              summary: summary,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

/// Group header card
class _GroupHeader extends ConsumerWidget {
  final FamilyGroupEntity group;
  final FamilySummary? summary;
  const _GroupHeader({required this.group, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = this.summary;
    final maxMembers = summary?.maxMembers ?? 2;
    final memberCount = summary?.memberCount ?? 0;

    return Container(
      margin: const EdgeInsets.all(PawTokens.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            PawTableColors.primary.withValues(alpha: 0.15),
            PawTableColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        border: Border.all(color: PawTableColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PawTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PawTokens.sm),
                  decoration: BoxDecoration(
                    color: PawTableColors.primary,
                    borderRadius: BorderRadius.circular(PawTokens.radiusMd),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: PawTableColors.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: PawTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$memberCount / $maxMembers members',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: PawTableColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (summary != null && summary.members.any((m) => m.isOwner))
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: PawTableColors.error),
                    onPressed: () => _showDeleteDialog(context),
                    tooltip: 'Delete Group',
                  ),
              ],
            ),
            const SizedBox(height: PawTokens.sm),
            LinearProgressIndicator(
              value: memberCount / maxMembers,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: PawTableColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(PawTableColors.primary),
            ),
            if (memberCount >= maxMembers && (summary?.isPremium ?? false))
              Padding(
                padding: const EdgeInsets.only(top: PawTokens.sm),
                child: Text(
                  'Premium plan — ${summary!.memberCount} members',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PawTableColors.successDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final groupName = ProviderScope.containerOf(context, listen: false)
        .read(familyListProvider)
        .selectedGroup
        ?.name;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Family Group?'),
        content: Text(
          'Are you sure you want to delete "$groupName"? This will remove all members and shared pets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await ProviderScope.containerOf(context, listen: false)
                    .read(familyListProvider.notifier)
                    .deleteGroup();
                if (success) {
                  Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Family group deleted'),
                        backgroundColor: PawTableColors.error,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  final message = e is AppException
                      ? e.message
                      : 'Failed to delete group';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: PawTableColors.error,
                    ),
                  );
                }
              }
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
}

/// Members section
class _MembersSection extends ConsumerWidget {
  final FamilyGroupEntity group;
  final FamilySummary summary;
  const _MembersSection({required this.group, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: PawTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        boxShadow: PawTokens.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(PawTokens.md),
            child: Text(
              'Members (${summary.memberCount}/${summary.maxMembers})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...summary.members.map((member) => _MemberTile(
                member: member,
                canManage: summary.members.any((m) => m.can(FamilyPermission.manageMembers)),
              )),
          // Check if any member has permission to manage members
          if (summary.memberCount < summary.maxMembers &&
              summary.members.any((m) => m.can(FamilyPermission.manageMembers)))
            Padding(
              padding: const EdgeInsets.all(PawTokens.md),
              child: ElevatedButton.icon(
                onPressed: () => _showAddMemberDialog(context, ref),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawTableColors.primary.withValues(alpha: 0.1),
                  foregroundColor: PawTableColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: PawTokens.sm),
              TextField(
                controller: userIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final userId = userIdCtrl.text.trim();
              if (name.isEmpty || userId.isEmpty) return;
              final success = await ref
                  .read(familyListProvider.notifier)
                  .addMember(userId: userId, displayName: name);
              if (success && context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name added to the family!'),
                    backgroundColor: PawTableColors.successDark,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Individual member tile
class _MemberTile extends StatelessWidget {
  final FamilyMemberEntity member;
  final bool canManage;
  const _MemberTile({required this.member, this.canManage = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconData;
    switch (member.role.iconCode) {
      case 0:
        iconData = Icons.admin_panel_settings_rounded;
      case 1:
        iconData = Icons.admin_panel_settings_outlined;
      case 2:
        iconData = Icons.person_rounded;
      default:
        iconData = Icons.pets_rounded;
    }

    Color avatarColor;
    switch (member.role) {
      case FamilyRole.owner:
        avatarColor = PawTableColors.primary;
      case FamilyRole.admin:
        avatarColor = PawTableColors.info;
      default:
        avatarColor = PawTableColors.surfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PawTokens.md, vertical: 4),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(iconData, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: PawTokens.md),
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  member.role.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PawTableColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Remove button (owners can't be removed, only leaders can remove members)
          if (member.role != FamilyRole.owner && canManage)
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: PawTableColors.error),
              onPressed: () => _showRemoveMemberDialog(context, member),
            ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, FamilyMemberEntity member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text('Remove ${member.displayName} from this family group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await ProviderScope.containerOf(context, listen: false)
                    .read(familyListProvider.notifier)
                    .removeMember(member.id);
                if (success && context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.displayName} removed'),
                      backgroundColor: PawTableColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  final message = e is AppException
                      ? e.message
                      : 'Failed to remove member';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: PawTableColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Shared pets section
class _SharedPetsSection extends ConsumerWidget {
  final FamilyGroupEntity group;
  final FamilySummary summary;
  const _SharedPetsSection({required this.group, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(PawTokens.md, 0, PawTokens.md, PawTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PawTokens.radiusLg),
        boxShadow: PawTokens.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(PawTokens.md),
            child: Text(
              'Shared Pets (${summary.sharedPetIds.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...summary.sharedPetIds.map((petId) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: PawTokens.md, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.pets_rounded, color: PawTableColors.primary),
                    const SizedBox(width: PawTokens.sm),
                    Expanded(
                      child: Text(
                        'Pet #$petId',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    // Check if any member has permission to manage pets
                    if (summary.members.any((m) => m.can(FamilyPermission.managePets)))
                      IconButton(
                        icon: const Icon(Icons.link_off, size: 20),
                        onPressed: () async {
                          final success = await ProviderScope.containerOf(context, listen: false)
                              .read(familyListProvider.notifier)
                              .unsharePet(petId);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pet unshared from family'),
                                backgroundColor: PawTableColors.warning,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              )),
        ],
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
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: PawTokens.md),
            Text(
              'Failed to load family data',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
