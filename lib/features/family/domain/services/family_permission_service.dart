import '../entities/family_group_entity.dart';

/// Permission checks for a family member's role
enum FamilyPermission {
  /// Can read/view data
  view,

  /// Can create/edit/delete their own pet logs
  editOwn,

  /// Can view other members' logs
  viewOthers,

  /// Can create/edit/delete any member's logs
  editAll,

  /// Can manage members (invite, remove, change roles)
  manageMembers,

  /// Can manage group settings (rename, delete group)
  manageGroup,

  /// Can share/unshare pets with the group
  managePets,

  /// Can cancel invites
  manageInvites,

  /// Full control — owner only
  fullAccess,
}

/// Role-based permission matrix
///
/// Permission levels per role:
/// - owner:    all permissions
/// - admin:    view, editOwn, editAll, viewOthers, manageMembers, managePets, manageInvites, manageGroup
/// - member:   view, editOwn, viewOthers, managePets
/// - petSitter: view, editOwn, viewOthers
class FamilyPermissionService {
  /// Check if a member's role grants a specific permission
  static bool hasPermission(FamilyRole role, FamilyPermission permission) {
    switch (permission) {
      case FamilyPermission.view:
        return true;

      case FamilyPermission.editOwn:
        return _hasAnyRole(role, [FamilyRole.owner, FamilyRole.admin, FamilyRole.member, FamilyRole.petSitter]);

      case FamilyPermission.viewOthers:
        return _hasAnyRole(role, [FamilyRole.owner, FamilyRole.admin, FamilyRole.member]);

      case FamilyPermission.editAll:
        return _hasAnyRole(role, [FamilyRole.owner, FamilyRole.admin]);

      case FamilyPermission.manageMembers:
        return _hasAnyRole(role, [FamilyRole.owner, FamilyRole.admin]);

      case FamilyPermission.manageGroup:
        return role == FamilyRole.owner;

      case FamilyPermission.managePets:
        return _hasAnyRole(role, [FamilyRole.owner, FamilyRole.admin, FamilyRole.member]);

      case FamilyPermission.manageInvites:
        return _hasAnyRole(role, [FamilyRole.owner, FamilyRole.admin]);

      case FamilyPermission.fullAccess:
        return role == FamilyRole.owner;
    }
  }

  /// Helper: check if role is in the allowed list
  static bool _hasAnyRole(FamilyRole role, List<FamilyRole> allowedRoles) {
    return allowedRoles.contains(role);
  }

  /// Check if a member has ANY of the specified permissions
  static bool hasAnyPermission(
    FamilyRole role,
    List<FamilyPermission> permissions,
  ) {
    return permissions.any((p) => hasPermission(role, p));
  }

  /// Check if a member has ALL of the specified permissions
  static bool hasAllPermissions(
    FamilyRole role,
    List<FamilyPermission> permissions,
  ) {
    return permissions.every((p) => hasPermission(role, p));
  }

  /// Get the effective permissions for a role
  static Set<FamilyPermission> getEffectivePermissions(FamilyRole role) {
    return FamilyPermission.values
        .where((p) => hasPermission(role, p))
        .toSet();
  }

  /// Check if a role is higher than or equal to another
  static bool isRoleAtLeast(FamilyRole role, FamilyRole requiredRole) {
    final roles = FamilyRole.values;
    return roles.indexOf(role) <= roles.indexOf(requiredRole);
  }

  /// Check if a role can demote another role
  static bool canDemote(FamilyRole demoterRole, FamilyRole targetRole) {
    // Owner can demote anyone
    if (demoterRole == FamilyRole.owner && targetRole != FamilyRole.owner) {
      return true;
    }
    // Admin can demote member and petSitter
    if (demoterRole == FamilyRole.admin) {
      return targetRole == FamilyRole.member ||
          targetRole == FamilyRole.petSitter;
    }
    return false;
  }

  /// Check if a role can promote another role
  static bool canPromote(FamilyRole promoterRole, FamilyRole targetRole) {
    // Owner can promote to admin, member, petSitter
    if (promoterRole == FamilyRole.owner) {
      return targetRole != FamilyRole.owner;
    }
    // Admin can promote to member, petSitter
    if (promoterRole == FamilyRole.admin) {
      return targetRole == FamilyRole.member ||
          targetRole == FamilyRole.petSitter;
    }
    return false;
  }

  /// Check if a member can change their own role
  static bool canChangeOwnRole(FamilyRole role) {
    return role == FamilyRole.member;
  }

  /// Check if a member is allowed to transfer ownership
  static bool canTransferOwnership(FamilyRole role) {
    return role == FamilyRole.owner;
  }

  /// Get the minimum role required for a permission
  static FamilyRole minRoleForPermission(FamilyPermission permission) {
    switch (permission) {
      case FamilyPermission.view:
        return FamilyRole.petSitter;
      case FamilyPermission.editOwn:
        return FamilyRole.petSitter;
      case FamilyPermission.viewOthers:
        return FamilyRole.member;
      case FamilyPermission.editAll:
        return FamilyRole.admin;
      case FamilyPermission.manageMembers:
        return FamilyRole.admin;
      case FamilyPermission.manageGroup:
        return FamilyRole.owner;
      case FamilyPermission.managePets:
        return FamilyRole.member;
      case FamilyPermission.manageInvites:
        return FamilyRole.admin;
      case FamilyPermission.fullAccess:
        return FamilyRole.owner;
    }
  }

  /// Check if two members have the same role
  static bool sameRole(FamilyRole a, FamilyRole b) {
    return a == b;
  }

  /// Check if a member is the owner of a group
  static bool isGroupOwner(FamilyMemberEntity member, FamilyGroupEntity group) {
    return member.userId == group.ownerId;
  }

  /// Check if a member is an owner or admin
  static bool isGroupLeader(FamilyMemberEntity member) {
    return member.isOwner || member.isAdmin;
  }

  /// Get the role hierarchy level (lower number = higher privilege)
  static int roleLevel(FamilyRole role) {
    switch (role) {
      case FamilyRole.owner:
        return 0;
      case FamilyRole.admin:
        return 1;
      case FamilyRole.member:
        return 2;
      case FamilyRole.petSitter:
        return 3;
    }
  }
}

/// Extension for quick permission checks on FamilyMemberEntity
extension FamilyMemberPermissionExtension on FamilyMemberEntity {
  /// Check if this member can perform a specific action
  bool can(FamilyPermission permission) {
    return FamilyPermissionService.hasPermission(role, permission);
  }

  /// Check if this member has ANY of the specified permissions
  bool canAny(List<FamilyPermission> permissions) {
    return FamilyPermissionService.hasAnyPermission(role, permissions);
  }

  /// Check if this member has ALL of the specified permissions
  bool canAll(List<FamilyPermission> permissions) {
    return FamilyPermissionService.hasAllPermissions(role, permissions);
  }

  /// Check if this member's role is at least the required role
  bool isAtLeast(FamilyRole requiredRole) {
    return FamilyPermissionService.isRoleAtLeast(role, requiredRole);
  }

  /// Get the effective permissions for this member
  Set<FamilyPermission> get effectivePermissions =>
      FamilyPermissionService.getEffectivePermissions(role);

  /// Check if this member is a group leader (owner or admin)
  bool get isGroupLeader =>
      FamilyPermissionService.isGroupLeader(this);

  /// Check if this member can demote another member
  bool canDemote(FamilyMemberEntity target) {
    return FamilyPermissionService.canDemote(role, target.role);
  }

  /// Check if this member can promote another member
  bool canPromote(FamilyMemberEntity target) {
    return FamilyPermissionService.canPromote(role, target.role);
  }
}
