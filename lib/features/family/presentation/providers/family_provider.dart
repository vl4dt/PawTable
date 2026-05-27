import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/app_module.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/family_group_entity.dart';
import '../../domain/services/family_permission_service.dart';
import '../../domain/repositories/family_repository.dart';

/// Family repository provider — wired via GetIt DI
final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return getIt<FamilyRepository>();
});

// =========================================================================
// STATE
// =========================================================================

/// State for family group list
class FamilyGroupState {
  final bool isLoading;
  final String? error;
  final List<FamilyGroupEntity> groups;
  final FamilySummary? summary;
  final FamilyGroupEntity? selectedGroup;
  final bool isCreating;

  const FamilyGroupState({
    this.isLoading = false,
    this.error,
    this.groups = const [],
    this.summary,
    this.selectedGroup,
    this.isCreating = false,
  });

  FamilyGroupState copyWith({
    bool? isLoading,
    String? error,
    List<FamilyGroupEntity>? groups,
    FamilySummary? summary,
    FamilyGroupEntity? selectedGroup,
    bool? isCreating,
  }) {
    return FamilyGroupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      groups: groups ?? this.groups,
      summary: summary ?? this.summary,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

// =========================================================================
// NOTIFIER
// =========================================================================

class FamilyNotifier extends StateNotifier<FamilyGroupState> {
  final FamilyRepository _repository;

  FamilyNotifier(this._repository) : super(const FamilyGroupState());

  /// Load all family groups
  Future<void> loadGroups() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final groups = await _repository.getGroups();
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Select a group and load its summary
  Future<void> selectGroup(String groupId) async {
    try {
      final summary = await _repository.getSummary(groupId);
      state = state.copyWith(
        selectedGroup: summary.group,
        summary: summary,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Create a new family group
  Future<bool> createGroup(String name) async {
    // Use a placeholder ownerId — in production this comes from auth
    const ownerId = 'user-current';
    state = state.copyWith(isCreating: true, error: null);
    try {
      final group = await _repository.createGroup(name, ownerId);
      final updatedGroups = List<FamilyGroupEntity>.from(state.groups)
        ..add(group);
      state = state.copyWith(groups: updatedGroups, isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isCreating: false);
      return false;
    }
  }

  /// Add a member to the selected group
  /// Requires: canManageMembers
  Future<bool> addMember({
    required String userId,
    required String displayName,
    FamilyRole role = FamilyRole.member,
  }) async {
    final groupId = state.selectedGroup?.id;
    if (groupId == null) return false;

    try {
      await _repository.checkPermission(
        groupId: groupId,
        userId: 'user-current',
        permission: FamilyPermission.manageMembers,
      );

      await _repository.addMember(
        groupId: groupId,
        userId: userId,
        displayName: displayName,
        role: role,
      );
      await selectGroup(groupId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Remove a member from the selected group
  /// Requires: canManageMembers
  Future<bool> removeMember(String memberId) async {
    final groupId = state.selectedGroup?.id;
    if (groupId == null) return false;

    try {
      await _repository.checkPermission(
        groupId: groupId,
        userId: 'user-current',
        permission: FamilyPermission.manageMembers,
      );

      await _repository.removeMember(memberId);
      await selectGroup(groupId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update a member's role
  /// Requires: canManageMembers
  Future<bool> updateMemberRole(String memberId, FamilyRole newRole) async {
    final groupId = state.selectedGroup?.id;
    if (groupId == null) return false;

    try {
      await _repository.checkPermission(
        groupId: groupId,
        userId: 'user-current',
        permission: FamilyPermission.manageMembers,
      );

      final member = await _repository.getMember(memberId);
      if (member == null) return false;

      final updated = member.copyWith(role: newRole);
      await _repository.updateMember(updated);
      await selectGroup(groupId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Share a pet with the selected group
  /// Requires: canManagePets
  Future<bool> sharePet(String petId) async {
    final groupId = state.selectedGroup?.id;
    if (groupId == null) return false;

    try {
      await _repository.checkPermission(
        groupId: groupId,
        userId: 'user-current',
        permission: FamilyPermission.managePets,
      );

      await _repository.sharePet(
        petId: petId,
        groupId: groupId,
        sharedBy: 'user-current',
      );
      await selectGroup(groupId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Unshare a pet from the selected group
  /// Requires: canManagePets
  Future<bool> unsharePet(String petId) async {
    final groupId = state.selectedGroup?.id;
    if (groupId == null) return false;

    try {
      await _repository.checkPermission(
        groupId: groupId,
        userId: 'user-current',
        permission: FamilyPermission.managePets,
      );

      await _repository.unsharePet(petId, groupId);
      await selectGroup(groupId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete the selected group
  /// Requires: canManageGroup (owner only)
  Future<bool> deleteGroup() async {
    final groupId = state.selectedGroup?.id;
    if (groupId == null) return false;

    try {
      await _repository.checkPermission(
        groupId: groupId,
        userId: 'user-current',
        permission: FamilyPermission.manageGroup,
      );

      await _repository.deleteGroup(groupId);
      final updatedGroups =
          List<FamilyGroupEntity>.from(state.groups)..removeWhere((g) => g.id == groupId);
      state = state.copyWith(
        groups: updatedGroups,
        selectedGroup: null,
        summary: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final familyListProvider =
    StateNotifierProvider<FamilyNotifier, FamilyGroupState>((ref) {
  final repo = ref.watch(familyRepositoryProvider);
  return FamilyNotifier(repo);
});
