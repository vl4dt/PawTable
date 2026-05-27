import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/family_group_entity.dart';
import '../../domain/services/family_permission_service.dart';

/// Provider that provides the current user's permission level in a family group
class FamilyPermissionState {
  final FamilyMemberEntity member;
  final FamilyGroupEntity group;
  final Set<FamilyPermission> permissions;

  const FamilyPermissionState({
    required this.member,
    required this.group,
    required this.permissions,
  });

  bool has(FamilyPermission permission) => permissions.contains(permission);
  bool canEdit() => has(FamilyPermission.editOwn);
  bool canEditAll() => has(FamilyPermission.editAll);
  bool canViewOthers() => has(FamilyPermission.viewOthers);
  bool canManageMembers() => has(FamilyPermission.manageMembers);
  bool canManageGroup() => has(FamilyPermission.manageGroup);
  bool canManagePets() => has(FamilyPermission.managePets);
  bool canManageInvites() => has(FamilyPermission.manageInvites);
  bool isLeader() => member.isGroupLeader;
  bool isOwner() => member.isOwner;

  bool canDemote(FamilyMemberEntity target) => member.canDemote(target);
  bool canPromote(FamilyMemberEntity target) => member.canPromote(target);
}

final familyPermissionProvider = Provider.family<FamilyPermissionState, ({
  String groupId,
  String userId,
})>((ref, args) {
  // This would be wired to the actual FamilyMemberEntity from the family provider
  // For now, return a default member with member role
  final member = FamilyMemberEntity(
    id: '',
    groupId: args.groupId,
    userId: args.userId,
    displayName: 'User',
    role: FamilyRole.member,
    joinedAt: DateTime.now(),
  );

  return FamilyPermissionState(
    member: member,
    group: FamilyGroupEntity(
      id: args.groupId,
      name: 'Group',
      ownerId: args.userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    permissions: FamilyPermissionService.getEffectivePermissions(member.role),
  );
});
